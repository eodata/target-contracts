#!/bin/bash
# This script generates a markdown table of feed addresses for a single
# configured chain. For every feed it outputs the address, decimals,
# deviation threshold, heartbeat and notes. Notes include the v1 address
# when available as well as any hard coded warnings for specific feeds.
#
# Example usage:
#   From repo root: `bash script/utils/generate_feed_addresses.sh --target-chain-id 42161 > docs/deployments.md`

usage() {
  echo "Usage: $0 --target-chain-id <target_chain_id> [--rpc <rpc_url>] [--explorer <url>] [--check-contracts]" >&2
  exit 1
}

target_chain_id=""
eochain="42420"
rpc_override=""
explorer_override=""
check_contracts=false

while [ $# -gt 0 ]; do
  case "$1" in
    --target-chain-id)
      target_chain_id="${2}"
      shift 2
      ;;
    --rpc)
      rpc_override="${2}"
      shift 2
      ;;
    --explorer)
      explorer_override="${2}"
      shift 2
      ;;
    --check-contracts)
      check_contracts=true
      shift 1
      ;;
    *)
      echo "Unknown parameter: ${1}" >&2
      usage
      ;;
  esac
done

if [ -z "${target_chain_id}" ]; then
  usage
fi

base_dir="script/config/"

addr_dir="${base_dir}/${target_chain_id}/$eochain"
addr_file="${addr_dir}/targetContractAddresses.json"
config_file="${addr_dir}/targetContractSetConfig.json"
v1_file="${addr_dir}/targetContractAddresses_v1.json"

if [ ! -f "$addr_file" ]; then
  echo "No feed data found for chain ${target_chain_id} (set ${eochain})" >&2
  exit 1
fi

# Return additional hard coded notes for a feed
additional_note() {
  case "$1" in
    "SOV/USD") echo "High risk: Liquidity is low across all markets. Consider carefully before integrating" ;;
    "sFRAX/FRAX") echo "Fundamental exchange Rate" ;;
    "sfrxETH/frxETH") echo "Fundamental exchange Rate" ;;
    "stETH/ETH") echo "Fundamental exchange Rate" ;;
    "rETH/ETH") echo "Fundamental exchange Rate" ;;
    "cbETH/ETH") echo "Fundamental exchange Rate" ;;
    "ETHx/ETH") echo "Fundamental exchange Rate" ;;
    "ankrETH/ETH") echo "Fundamental exchange Rate" ;;
    "oETH/ETH") echo "Fundamental exchange Rate" ;;
    "osETH/ETH") echo "Fundamental exchange Rate" ;;
    "swETH/ETH") echo "Fundamental exchange Rate" ;;
    "wBETH/ETH") echo "Fundamental exchange Rate" ;;
    "lsETH/ETH") echo "Fundamental exchange Rate" ;;
    "mETH/ETH") echo "Fundamental exchange Rate" ;;
    "ezETH/ETH") echo "Fundamental exchange Rate" ;;
    "weETH/ETH") echo "Fundamental exchange Rate" ;;
    "pufETH/ETH") echo "Fundamental exchange Rate" ;;
    "ynETH/ETH") echo "Fundamental exchange Rate" ;;
    "uniETH/ETH") echo "Fundamental exchange Rate" ;;
    "rswETH/ETH") echo "Fundamental exchange Rate" ;;
    "weETHs/ETH") echo "Fundamental exchange Rate" ;;
    "swBTC/BTC") echo "Fundamental exchange Rate" ;;
    "eBTC/BTC") echo "Fundamental exchange Rate" ;;
    "STONE/ETH") echo "Fundamental exchange Rate" ;;
    "rsETH/ETH") echo "Fundamental exchange Rate" ;;
    "pufEUSD/USD") echo "Fundamental exchange Rate" ;;
    "STONE/USD") echo "Fundamental exchange Rate" ;;
    "wstETH/ETH") echo "Fundamental exchange Rate" ;;
    "stETH/USD") echo "Fundamental exchange Rate" ;;
    "ezETH/USD") echo "Fundamental exchange Rate" ;;
    "weETH/USD") echo "Fundamental exchange Rate" ;;
    "uniETH/USD") echo "Fundamental exchange Rate" ;;
    "pufEUSD/USD") echo "Fundamental exchange Rate" ;;
    "rsETH/USD") echo "Fundamental exchange Rate" ;;
    "wstETH/USD") echo "Fundamental exchange Rate" ;;
    "SolvBTCBBN/USD") echo "Fundamental exchange Rate" ;;
    "uniBTC/USD") echo "Fundamental exchange Rate" ;;
    "wBTC/USD") echo "Fundamental exchange Rate" ;;
    "wOETH/USD") echo "Fundamental exchange Rate" ;;
    "inwstETH/USD") echo "Fundamental exchange Rate" ;;
    "LBTC/USD") echo "Fundamental exchange Rate" ;;
    "sUSDe/USDe") echo "Fundamental exchange Rate" ;;
    "eBTC/USD") echo "Fundamental exchange Rate" ;;
    "LBTC/BTC") echo "Fundamental exchange Rate" ;;
    "wUSDM/USDM") echo "Fundamental exchange Rate" ;;
    "xUSD/USD") echo "Fundamental exchange Rate" ;;
    "yUSD/USD") echo "Fundamental exchange Rate" ;;
    "xSolvBTC/USD") echo "Fundamental exchange Rate" ;;
    "wsrUSD/USD") echo "Fundamental exchange Rate" ;;
    "uSDC/USDC") echo "Fundamental exchange Rate" ;;
    "xETH/ETH") echo "Fundamental exchange Rate" ;;
    "xBTC/BTC") echo "Fundamental exchange Rate" ;;
    "xUSD/USDC") echo "Fundamental exchange Rate" ;;
    *) echo "" ;;
  esac
}

# Fetch chain list data once if needed
chain_data=""
if [ -z "${rpc_override}" ] || [ -z "${explorer_override}" ]; then
  chain_data=$(curl -s https://chainid.network/chains.json)
fi

get_explorer_url() {
  cid=${1}
  url=""
  if [ -n "${chain_data}" ]; then
    url=$(echo "${chain_data}" | jq -r --arg target_chain_id "${cid}" '.[] | select(.chainId == ($target_chain_id | tonumber)) | .explorers[0].url // empty')
  fi
  echo ${url}
}

get_rpc_url() {
  cid=${1}
  url=""
  if [ -n "${chain_data}" ]; then
    url=$(echo "${chain_data}" | jq -r --arg target_chain_id "${cid}" '.[] | select(.chainId == ($target_chain_id | tonumber)) | .rpc[] | select(startswith("https://") and (index("${") | not))' | head -n 1)
  fi
  echo ${url}
}

default_dev=$(jq -r '.deviationThreshold' "${config_file}")

explorer_url="${explorer_override}"
if [ "${explorer_url}" = "" ]; then
  explorer_url=$(get_explorer_url "${target_chain_id}")
fi

rpc_url="${rpc_override}"
if [ "${rpc_url}" = "" ]; then
  rpc_url=$(get_rpc_url "${target_chain_id}")
fi

chainlist_url="https://chainlist.org/chain/${target_chain_id}"

feed_names=()
addresses=()
decimals_list=()
v1_feeds=()

output_file="/tmp/chain-${target_chain_id}.md"
echo "" > "${output_file}"
echo "# Price Feeds" | tee "${output_file}"
echo | tee -a "${output_file}"
echo "Compatible with AggregatorV3Interface." | tee -a "${output_file}"
echo | tee -a "${output_file}"
echo "| Feed | Address | Decimals | Deviation | Heartbeat | Notes |" | tee -a "${output_file}"
echo "| ---- | ------- | -------- | --------- | --------- | ----- |" | tee -a "${output_file}"

while read entry; do
  feed_name=$(echo "${entry}" | base64 --decode | jq -r '.key')
  address=$(echo "${entry}" | base64 --decode | jq -r '.value')

  feed_data=$(jq -r --arg desc "${feed_name}" '.supportedFeedsData[] | select(.description == $desc) | @base64' "${config_file}")
  decimals=$(echo "${feed_data}" | base64 --decode | jq -r '.outputDecimals')
  deviation=$(echo "${feed_data}" | base64 --decode | jq -r '.deviationThreshold')
  if [ -z "${deviation}" ] || [ "${deviation}" = "null" ]; then
    deviation=${default_dev}
  fi
  deviation="${deviation}%"
  heartbeat="24 hours"

  note=""
  extra_note=$(additional_note "${feed_name}")
  if [ -n "${extra_note}" ]; then
    note="${extra_note}"
  fi

  if [ "${explorer_url}" != "" ]; then
    address_link="<a href=\"${explorer_url}/address/${address}\" target=\"_blank\">${address}</a>"
  else
    address_link="${address}"
  fi

  echo "| ${feed_name} | ${address_link} | ${decimals} | ${deviation} | ${heartbeat} | ${note} |" | tee -a "${output_file}"

  feed_names+=("${feed_name}")
  addresses+=("${address}")
  decimals_list+=("${decimals}")

  # Store V1 address for separate table
  if [ -f "${v1_file}" ]; then
    v1_addr=$(jq -r --arg f "${feed_name}" '.feeds[$f] // empty' "${v1_file}" | tr -d '\r')
    if [ -n "${v1_addr}" ]; then
      v1_feeds+=("${feed_name}|${v1_addr}|${decimals}|${deviation}|${heartbeat}|${note}")
    fi
  fi
done < <(jq -r '.feeds | to_entries[] | @base64' "${addr_file}")

# adding the factoryFeeds addresses
while read entry; do
  feed_name=$(echo "${entry}" | base64 --decode | jq -r '.key')
  address=$(echo "${entry}" | base64 --decode | jq -r '.value')

  decimals=$(cast c "${address}" 'decimals()' -r "${rpc_url}" | cast 2d 2>/dev/null)
  deviation="--"
  heartbeat="--"

  note=""
  extra_note=$(additional_note "${feed_name}")
  if [ -n "${extra_note}" ]; then
    note="${extra_note}"
  fi

  if [ "${explorer_url}" != "" ]; then
    address_link="<a href=\"${explorer_url}/address/${address}\" target=\"_blank\">${address}</a>"
  else
    address_link="${address}"
  fi

  echo "| ${feed_name} | ${address_link} | ${decimals} | ${deviation} | ${heartbeat} | ${note} |" | tee -a "${output_file}"

  feed_names+=("${feed_name}")
  addresses+=("${address}")
  decimals_list+=("${decimals}")

  # Store V1 address for separate table (if exists)
  if [ -f "${v1_file}" ]; then
    v1_addr=$(jq -r --arg f "${feed_name}" '.feeds[$f] // empty' "${v1_file}" | tr -d '\r')
    if [ -n "${v1_addr}" ]; then
      v1_feeds+=("${feed_name}|${v1_addr}|${decimals}|${deviation}|${heartbeat}|${note}")
    fi
  fi
done < <(jq -r '.factoryFeeds | to_entries[] | @base64' "${addr_file}")

# Add V1 addresses table if any exist
if [ ${#v1_feeds[@]} -gt 0 ]; then
  echo | tee -a "${output_file}"
  echo "<details>" | tee -a "${output_file}"
  echo "<summary><strong>V1 Addresses (Legacy)</strong></summary>" | tee -a "${output_file}"
  echo | tee -a "${output_file}"
  echo "| Feed | V1 Address | Decimals | Deviation | Heartbeat | Notes |" | tee -a "${output_file}"
  echo "| ---- | ----------- | -------- | --------- | --------- | ----- |" | tee -a "${output_file}"
  
  for v1_feed in "${v1_feeds[@]}"; do
    IFS='|' read -r feed_name v1_addr decimals deviation heartbeat note <<< "${v1_feed}"
    
    if [ "${explorer_url}" != "" ]; then
      v1_address_link="<a href=\"${explorer_url}/address/${v1_addr}\" target=\"_blank\">${v1_addr}</a>"
    else
      v1_address_link="${v1_addr}"
    fi
    
    echo "| ${feed_name} | ${v1_address_link} | ${decimals} | ${deviation} | ${heartbeat} | ${note} |" | tee -a "${output_file}"
  done
  
  echo "</details>" | tee -a "${output_file}"
fi

echo | tee -a "${output_file}"
echo "# Links" | tee -a "${output_file}"
if [ "${explorer_url}" != "" ]; then
  echo "- Explorer: <a href=\"${explorer_url}\" target=\"_blank\">${explorer_url}</a>" | tee -a "${output_file}"
fi

if [ "${rpc_url}" != "" ]; then
  echo "- RPC: <a href=\"${rpc_url}\" target=\"_blank\">${rpc_url}</a>" | tee -a "${output_file}"
fi

echo "- Chainlist: <a href=\"${chainlist_url}\" target=\"_blank\">${chainlist_url}</a>" | tee -a "${output_file}"

if [ "${check_contracts}" = true ]; then
  if [ "${rpc_url}" = "" ]; then
    echo "RPC URL required for contract checks" >&2
  else
    echo
    echo "# Contract Checks ${#addresses[@]} "
    for i in "${!addresses[@]}"; do
      name="${feed_names[$i]}"
      addr="${addresses[$i]}"
      exp_dec="${decimals_list[$i]}"

      on_chain_dec=$(cast c "${addr}" 'decimals()' -r "${rpc_url}" | cast 2d 2>/dev/null)
      on_chain_desc=$(cast c "${addr}" 'description()' -r "${rpc_url}" | xxd -r -p 2>/dev/null | head -c -1 2>/dev/null)
      latest_ans=$(cast c "${addr}" 'latestAnswer()' -r "${rpc_url}" | cast 2d 2>/dev/null)
      latest_ts=$(cast c "${addr}" 'latestTimestamp()' -r "${rpc_url}" | cast 2d 2>/dev/null)

      if [ -n "${latest_ans}" ] && [ -n "${exp_dec}" ]; then
        human_ans=$(awk -v ans="${latest_ans}" -v dec="${exp_dec}" 'BEGIN { printf "%.3f", ans / (10 ^ dec) }')
      else
        human_ans=""
      fi

      if [ -n "${latest_ts}" ]; then
        human_ts=$(date -r "${latest_ts}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      else
        human_ts=""
      fi

      if [ -n "${on_chain_dec}" ] && [ "${on_chain_dec}" != "${exp_dec}" ]; then
        echo "Warning: decimals mismatch for ${name} (${addr}) (expected ${exp_dec} got ${on_chain_dec})" >&2
      fi
      if [ -n "${on_chain_desc}" ] && [ "${on_chain_desc}" != "${name}" ]; then
        echo "Warning: description mismatch for ${name} (${addr}) (on-chain: ${on_chain_desc})" >&2
      fi

      printf "%-30s | %s | %2s | %10s | %s\n" "${name}" "${addr}" "${on_chain_dec}" "${human_ans}" "${human_ts}"
    done
  fi
fi

echo "Output file: cat ${output_file}"
