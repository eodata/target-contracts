#!/bin/sh
# This script generates a markdown table of feed addresses for a single
# configured chain. For every feed it outputs the address, decimals,
# deviation threshold, heartbeat and notes. Notes include the v1 address
# when available as well as any hard coded warnings for specific feeds.
#
# Example usage:
#   From repo root: `sh script/utils/generate_feed_addresses.sh 42161 > docs/deployments.md`

if [ $# -lt 1 ]; then
  echo "Usage: $0 <chain_id> [target_set_id]" >&2
  exit 1
fi

base_dir="script/config/"
chain_id="$1"
target_set_id="${2:-42420}"

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
    "BTC/USD"|"SOV/USD") echo "High risk: Liquidity is low across all markets. Consider carefully before integrating" ;;
    "ETH/USD") echo "exists in Bob" ;;
    *) echo "" ;;
  esac
}

# Fetch chain list data once
chain_data=$(curl -s https://chainid.network/chains.json)

get_network_name() {
  chain_id=$1
  name=""
  if [ -n "$chain_data" ]; then
    name=$(echo "$chain_data" | jq -r --arg chain_id "$chain_id" '.[] | select(.chainId == ($chain_id | tonumber)) | .name')
  fi
  if [ -z "$name" ] || [ "$name" = "null" ]; then
    name="Chain $chain_id"
  fi
  echo "$name"
}

network=$(get_network_name "$chain_id")
default_dev=$(jq -r '.deviationThreshold' "$config_file")

echo "## $network"
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
