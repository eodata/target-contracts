#!/bin/bash
# This script processes JSON files within a specified directory structure to extract and display information about EOFeedManager and EOFeedAdapter deployments in the documentation.
#
# Example usage:
# 1. From repo's root directory, run `sh script/utils/generate_feed_addresses.sh > docs/deployments.md`
# 2. Copy content docs/deployments.md to documentation

# Define the base directory
base_dir="script/config/"

# Default options
target_chain_id=42420
check_contracts=false

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --target-chain-id)
      target_chain_id="$2"
      shift 2
      ;;
    --check-contracts)
      check_contracts=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Initialize temporary files
feed_manager_file=$(mktemp)
feed_adapter_file=$(mktemp)

# Initialize header for EOFeedManager Deployments table
echo "## EOFeedManager Deployments" > $feed_manager_file
echo "| Network | Address | Supported Symbols |" >> $feed_manager_file
echo "| ------- | ------- | ----------------- |" >> $feed_manager_file

# Initialize header for EOFeedAdapter Deployments table
echo "## EOFeedAdapter Deployments" > $feed_adapter_file
echo "| Network | Symbol | Address |" >> $feed_adapter_file
echo "| ------- | ------ | ------- |" >> $feed_adapter_file

# Fetch chain list data
chain_data=$(curl -s https://chainid.network/chains.json)

# Function to get network name from chain ID
get_network_name() {
  local chain_id=$1
  echo "$chain_data" | jq -r --arg chain_id "$chain_id" '.[] | select(.chainId == ($chain_id | tonumber)) | .name'
}

# Function to get RPC URL from chain ID
get_network_rpc() {
  local chain_id=$1
  echo "$chain_data" | jq -r --arg chain_id "$chain_id" '.[] | select(.chainId == ($chain_id | tonumber)) | .rpc[0]'
}

# Check if contract bytecode exists at an address
check_contract() {
  local rpc_url=$1
  local address=$2
  local label=$3
  local code=$(curl -s -X POST -H 'Content-Type: application/json' --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$address\",\"latest\"],\"id\":1}" $rpc_url | jq -r '.result')
  if [ "$code" == "0x" ]; then
    echo "Missing contract at $address ($label)" >&2
  fi
}

# Function to extract data from JSON files
extract_data_from_json() {
  local file_path=$1
  local chain_id=$(basename $(dirname $(dirname $file_path)))
  local network=$(get_network_name $chain_id)

  local feed_manager=$(jq -r '.feedManager' $file_path)
  local feeds=$(jq -r '.feeds' $file_path)

  if [ "$check_contracts" = true ]; then
    local rpc_url=$(get_network_rpc $chain_id)
    if [ -n "$rpc_url" ] && [ "$rpc_url" != "null" ]; then
      check_contract "$rpc_url" "$feed_manager" "feedManager on $network"
      echo "$feeds" | jq -r 'to_entries[] | .value' | while read addr; do
        check_contract "$rpc_url" "$addr" "feed on $network"
      done
    else
      echo "No RPC URL found for chain $chain_id; skipping contract checks" >&2
    fi
  fi

  # Append to EOFeedManager Deployments
  local symbols=$(echo "$feeds" | jq -r 'keys | join(", ")')
  echo "| $network | $feed_manager | $symbols |" >> $feed_manager_file

  # Append to EOFeedAdapter Deployments
  echo "$feeds" | jq -r 'to_entries[] | "| '"$network"' | \(.key) | \(.value) |"' >> $feed_adapter_file
}

# Walk through the directory structure
find "$base_dir" -path "*/${target_chain_id}/targetContractAddresses.json" | while read file; do
  extract_data_from_json "$file"
done

# Output the tables
cat $feed_manager_file
echo
cat $feed_adapter_file

# Cleanup temporary files
rm $feed_manager_file
rm $feed_adapter_file
