#!/bin/sh
# This script generates a markdown table of feed addresses for each
# configured network. For every feed it outputs the address, decimals,
# deviation threshold, heartbeat and notes. Notes include the v1 address
# when available as well as any hard coded warnings for specific feeds.
#
# Example usage:
#   From repo root: `sh script/utils/generate_feed_addresses.sh > docs/deployments.md`

base_dir="script/config/"

# Return additional hard coded notes for a feed
additional_note() {
  case "$1" in
    "BTC/USD") echo "High risk: Liquidity is low across all markets. Consider carefully before integrating" ;;
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

find "$base_dir" -path "*/42420/targetContractAddresses.json" | while read addr_file; do
  chain_id=$(basename "$(dirname "$(dirname "$addr_file")")")
  network=$(get_network_name "$chain_id")
  config_file="$(dirname "$addr_file")/targetContractSetConfig.json"
  v1_file="$(dirname "$addr_file")/targetContractAddresses_v1.json"

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

done
