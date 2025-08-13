#!/bin/bash
# This script generates a markdown table of feed addresses for a single
# configured chain. For every feed it outputs the address, decimals,
# deviation threshold, heartbeat and notes. Notes include the v1 address
# when available as well as any hard coded warnings for specific feeds.
#
# Example usage:
#   From repo root: `bash script/utils/generate_feed_addresses.sh --chain-id 42161 > docs/deployments.md`

usage() {
  echo "Usage: $0 --chain-id <chain_id> [--target-set-id <id>] [--rpc <rpc_url>] [--explorer <url>] [--check-contracts]" >&2
  exit 1
}

chain_id=""
target_set_id="42420"
rpc_override=""
explorer_override=""
check_contracts=false

while [ $# -gt 0 ]; do
  case "$1" in
    --chain-id)
      chain_id="$2"
      shift 2
      ;;
    --target-set-id)
      target_set_id="$2"
      shift 2
      ;;
    --rpc)
      rpc_override="$2"
      shift 2
      ;;
    --explorer)
      explorer_override="$2"
      shift 2
      ;;
    --check-contracts)
      check_contracts=true
      shift 1
      ;;
    *)
      echo "Unknown parameter: $1" >&2
      usage
      ;;
  esac
done

if [ -z "$chain_id" ]; then
  usage
fi

base_dir="script/config/"


addr_dir="$base_dir/$chain_id/$target_set_id"
addr_file="$addr_dir/targetContractAddresses.json"
config_file="$addr_dir/targetContractSetConfig.json"
v1_file="$addr_dir/targetContractAddresses_v1.json"

if [ ! -f "$addr_file" ]; then
  echo "No feed data found for chain $chain_id (set $target_set_id)" >&2
  exit 1
fi

# Return additional hard coded notes for a feed
additional_note() {
  case "$1" in
    "SOV/USD") echo "High risk: Liquidity is low across all markets. Consider carefully before integrating" ;;
    *) echo "" ;;
  esac
}

# Fetch chain list data once if needed
chain_data=""
if [ -z "$rpc_override" ] || [ -z "$explorer_override" ]; then
  chain_data=$(curl -s https://chainid.network/chains.json)
fi

get_explorer_url() {
  cid=$1
  url=""
  if [ -n "$chain_data" ]; then
    url=$(echo "$chain_data" | jq -r --arg chain_id "$cid" '.[] | select(.chainId == ($chain_id | tonumber)) | .explorers[0].url // empty')
  fi
  echo "$url"
}

get_rpc_url() {
  cid=$1
  url=""
  if [ -n "$chain_data" ]; then
    url=$(echo "$chain_data" | jq -r --arg chain_id "$cid" '.[] | select(.chainId == ($chain_id | tonumber)) | .rpc[] | select(startswith("https://") and (index("${") | not))' | head -n 1)
  fi
  echo "$url"
}

default_dev=$(jq -r '.deviationThreshold' "$config_file")

explorer_url="$explorer_override"
if [ -z "$explorer_url" ]; then
  explorer_url=$(get_explorer_url "$chain_id")
fi
rpc_url="$rpc_override"
if [ -z "$rpc_url" ]; then
  rpc_url=$(get_rpc_url "$chain_id")
fi
chainlist_url="https://chainlist.org/chain/$chain_id"

feed_names=()
addresses=()
decimals_list=()

echo "# Price Feeds"
echo
echo "Compatible with AggregatorV3Interface."
echo
echo "| Feed | Address | Decimals | Deviation | Heartbeat | Notes |"
echo "| ---- | ------- | -------- | --------- | --------- | ----- |"

while read entry; do
  feed_name=$(echo "$entry" | base64 --decode | jq -r '.key')
  address=$(echo "$entry" | base64 --decode | jq -r '.value')

  feed_data=$(jq -r --arg desc "$feed_name" '.supportedFeedsData[] | select(.description == $desc) | @base64' "$config_file")
  decimals=$(echo "$feed_data" | base64 --decode | jq -r '.outputDecimals')
  deviation=$(echo "$feed_data" | base64 --decode | jq -r '.deviationThreshold')
  if [ -z "$deviation" ] || [ "$deviation" = "null" ]; then
    deviation=$default_dev
  fi
  deviation="${deviation}%"
  heartbeat="24 hours"

  note=""
  if [ -f "$v1_file" ]; then
    v1_addr=$(jq -r --arg f "$feed_name" '.feeds[$f] // empty' "$v1_file" | tr -d '\r')
    if [ -n "$v1_addr" ]; then
      note="V1 address: $v1_addr"
    fi
  fi

  extra_note=$(additional_note "$feed_name")
  if [ -n "$extra_note" ]; then
    if [ -n "$note" ]; then
      note="$note, $extra_note"
    else
      note="$extra_note"
    fi
  fi

  if [ -n "$explorer_url" ]; then
    address_link="<a href=\"$explorer_url/address/$address\" target=\"_blank\">$address</a>"
  else
    address_link="$address"
  fi

  echo "| $feed_name | $address_link | $decimals | $deviation | $heartbeat | $note |"

  feed_names+=("$feed_name")
  addresses+=("$address")
  decimals_list+=("$decimals")

  if [ -n "$v1_addr" ]; then
    feed_names+=("$feed_name (v1)")
    addresses+=("$v1_addr")
    decimals_list+=("$decimals")
  fi
done < <(jq -r '.feeds | to_entries[] | @base64' "$addr_file")
echo
echo "# Links"
if [ -n "$explorer_url" ]; then
  echo "- <a href=\"$explorer_url\" target=\"_blank\">Explorer: $explorer_url</a>"
else
  echo "- Explorer:"
fi
if [ -n "$rpc_url" ]; then
  echo "- <a href=\"$rpc_url\" target=\"_blank\">RPC: $rpc_url</a>"
else
  echo "- RPC:"
fi
echo "- <a href=\"$chainlist_url\" target=\"_blank\">ChainList: $chainlist_url</a>"

if [ "$check_contracts" = true ]; then
  if [ -z "$rpc_url" ]; then
    echo "RPC URL required for contract checks" >&2
  else
    echo
    echo "# Contract Checks"
    for i in "${!addresses[@]}"; do
      name="${feed_names[$i]}"
      addr="${addresses[$i]}"
      exp_dec="${decimals_list[$i]}"

      on_chain_dec=$(cast c "$addr" 'decimals()' -r "$rpc_url" 2>/dev/null)
      on_chain_desc=$(cast c "$addr" 'description()' -r "$rpc_url" 2>/dev/null)
      latest_ans=$(cast c "$addr" 'latestAnswer()' -r "$rpc_url" 2>/dev/null)
      latest_ts=$(cast c "$addr" 'latestTimestamp()' -r "$rpc_url" 2>/dev/null)

      if [ -n "$latest_ans" ] && [ -n "$exp_dec" ]; then
        human_ans=$(python3 - <<'PY'
import sys
x=int(sys.argv[1])
dec=int(sys.argv[2])
print(x/10**dec)
PY
 "$latest_ans" "$exp_dec")
      else
        human_ans=""
      fi

      if [ -n "$latest_ts" ]; then
        human_ts=$(date -d "@$latest_ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      else
        human_ts=""
      fi

      if [ -n "$on_chain_dec" ] && [ "$on_chain_dec" != "$exp_dec" ]; then
        echo "Warning: decimals mismatch for $name (expected $exp_dec got $on_chain_dec)" >&2
      fi
      if [ -n "$on_chain_desc" ] && [ "$on_chain_desc" != "$name" ]; then
        echo "Warning: description mismatch for $name (on-chain: $on_chain_desc)" >&2
      fi

      echo "$name | $addr | $on_chain_dec | $human_ans | $human_ts"
    done
  fi
fi
