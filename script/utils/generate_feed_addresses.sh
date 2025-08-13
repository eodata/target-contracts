#!/bin/sh
# This script generates a markdown table of feed addresses for a single
# configured chain. For every feed it outputs the address, decimals,
# deviation threshold, heartbeat and notes. Notes include the v1 address
# when available as well as any hard coded warnings for specific feeds.
#
# Example usage:
#   From repo root: `sh script/utils/generate_feed_addresses.sh --targetchain-id 42161 > docs/deployments.md`

usage() {
  echo "Usage: $0 --target-chain-id <target_chain_id> [--rpc <rpc_url>] [--explorer <url>]" >&2
  exit 1
}

target_chain_id=""
eochain="42420"
rpc_override=""
explorer_override=""

while [ $# -gt 0 ]; do
  case "$1" in
    --target-chain-id)
      target_chain_id="$2"
      shift 2
      ;;
    --target-set-id)
      eochain="$2"
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
    *)
      echo "Unknown parameter: $1" >&2
      usage
      ;;
  esac
done

if [ -z "$target_chain_id" ]; then
  usage
fi

base_dir="script/config/"

addr_dir="$base_dir/$target_chain_id/$eochain"
addr_file="$addr_dir/targetContractAddresses.json"
config_file="$addr_dir/targetContractSetConfig.json"
v1_file="$addr_dir/targetContractAddresses_v1.json"

if [ ! -f "$addr_file" ]; then
  echo "No feed data found for chain $target_chain_id (set $eochain)" >&2
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
    url=$(echo "$chain_data" | jq -r --arg target_chain_id "$cid" '.[] | select(.chainId == ($target_chain_id | tonumber)) | .explorers[0].url // empty')
  fi
  echo $url
}

get_rpc_url() {
  cid=$1
  url=""
  if [ -n "$chain_data" ]; then
    url=$(echo "$chain_data" | jq -r --arg target_chain_id "$cid" '.[] | select(.chainId == ($target_chain_id | tonumber)) | .rpc[] | select(startswith("https://") and (index("${") | not))' | head -n 1)
  fi
  echo $url
}

default_dev=$(jq -r '.deviationThreshold' "$config_file")

echo "# Price Feeds"
echo
echo "Compatible with AggregatorV3Interface."
echo
echo "| Feed | Address | Decimals | Deviation | Heartbeat | Notes |"
echo "| ---- | ------- | -------- | --------- | --------- | ----- |"

jq -r '.feeds | to_entries[] | @base64' "$addr_file" | while read entry; do
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
    v1_addr=$(jq -r --arg f "$feed_name" '.feeds[$f] // empty' "$v1_file")
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

  echo "| $feed_name | $address | $decimals | $deviation | $heartbeat | $note |"
done

echo

explorer_url="${explorer_override}"
if [ "${explorer_url}" = "" ]; then
  explorer_url=$(get_explorer_url "${target_chain_id}")
fi
rpc_url="${rpc_override}"
if [ "${rpc_url}" = "" ]; then
  rpc_url=$(get_rpc_url "${target_chain_id}")
fi
chainlist_url="https://chainlist.org/chain/${target_chain_id}"

echo "# Links"
if [ -n "${explorer_url}" ]; then
  echo '- Explorer: <a href='${explorer_url}' target="_blank">'${explorer_url}'</a>'
fi
if [ -n "${rpc_url}" ]; then
  echo '- RPC: <a href='${rpc_url}' target="_blank">'${rpc_url}'</a>'
fi
echo '- Chainlist: <a href='${chainlist_url}' target="_blank">'${chainlist_url}'</a>'
