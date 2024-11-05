#!/bin/bash

# ANSI escape codes for text color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BOLD="\033[1m"
RESET="\033[0m"

# eOracle Chain ID mappings
get_eoracle_chain_id() {
    local chain=$1
    case $chain in
        "mainnet") echo "42420" ;;
        "testnet") echo "42421" ;;
        *) echo "" ;;
    esac
}

usage() {
    echo "Usage: $0 --rpc-url <uri> --chain <mainnet|testnet> --deployer-private-key <key> --proxy-admin-owner <address> --target-contracts-owner <address> --publishers <json-array> --feed-ids <comma-separated-ids> [--use-precompiled-modexp] [--dry-run]"
    exit 1
}

# Default values
dry_run=true
USE_PRECOMPILED_MODEXP=false
chain="mainnet"

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rpc-url)
            TARGET_RPC_URL=${2}
            shift 2
            ;;
        --chain)
            chain=${2}
            shift 2
            ;;
        --deployer-private-key)
            DEPLOYER_PRIVATE_KEY=${2}
            shift 2
            ;;
        --proxy-admin-owner)
            PROXY_ADMIN_OWNER=${2}
            shift 2
            ;;
        --target-contracts-owner)
            TARGET_CONTRACTS_OWNER=${2}
            shift 2
            ;;
        --publishers)
            PUBLISHERS=${2}
            shift 2
            ;;
        --feed-ids)
            SUPPORTED_FEED_IDS=${2}
            shift 2
            ;;
        --use-precompiled-modexp)
            USE_PRECOMPILED_MODEXP=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown parameter passed: $1${RESET}"
            usage
            ;;
    esac
done

# Validate chain parameter and set eOracle chain ID
case $chain in
    mainnet|testnet)
        EORACLE_CHAIN_ID=$(get_eoracle_chain_id $chain)
        ;;
    *)
        echo -e "${RED}Invalid chain specified: $chain. Must be one of: mainnet, testnet${RESET}"
        usage
        ;;
esac

# Set ALLOWED_SENDERS based on EORACLE_CHAIN_ID
case $EORACLE_CHAIN_ID in
    42420)
        ALLOWED_SENDERS='["0x4E70004b01987B4fd7DAcab348F0B39E9AE26110"]'
        echo -e "${GREEN}Using predefined ALLOWED_SENDERS for EORACLE_CHAIN_ID 42420${RESET}"
        ;;
    42421)
        ALLOWED_SENDERS='["0x6B0BE2aaD42612803c9Fc389A3806EF21E8cbDb6"]'
        echo -e "${GREEN}Using predefined ALLOWED_SENDERS for EORACLE_CHAIN_ID 42421${RESET}"
        ;;
    *)
        echo -e "${RED}Error: Unsupported EORACLE_CHAIN_ID $EORACLE_CHAIN_ID${RESET}"
        exit 1
        ;;
esac

# Get chain ID from RPC URL
CHAIN_ID=$(cast chain-id --rpc-url $TARGET_RPC_URL)
echo "Detected Chain ID: $CHAIN_ID"

# Create config directory if it doesn't exist
CONFIG_DIR="script/config/$CHAIN_ID/$EORACLE_CHAIN_ID"
mkdir -p "$CONFIG_DIR"

# Read and parse the feed IDs
IFS=',' read -ra FEED_IDS <<< "$SUPPORTED_FEED_IDS"
FEED_IDS_JSON="[$(echo "${FEED_IDS[@]}" | tr ' ' ',')]"
echo "FEED_IDS_JSON ${FEED_IDS_JSON}"

# Generate feeds data array from AssetsList.json
ASSETS_LIST_PATH="script/config/AssetsList.json"
if [ ! -f "$ASSETS_LIST_PATH" ]; then
    echo "Error: AssetsList.json not found at $ASSETS_LIST_PATH"
    exit 1
fi

# Create a jq filter to select feeds based on the provided feed IDs
JQ_FILTER=".supportedFeedsData | map(select(.feedId | IN(\$feed_ids[])))"

# Generate the feeds data array using jq
SUPPORTED_FEEDS_DATA=$(jq --argjson feed_ids "${FEED_IDS_JSON}" "$JQ_FILTER" "$ASSETS_LIST_PATH")
echo "SUPPORTED_FEEDS_DATA ${SUPPORTED_FEEDS_DATA}"

# Generate config file
cat > "$CONFIG_DIR/targetContractSetConfig.json" << EOF
{
  "usePrecompiledModexp": $USE_PRECOMPILED_MODEXP,
  "proxyAdminOwner": "$PROXY_ADMIN_OWNER",
  "targetContractsOwner": "$TARGET_CONTRACTS_OWNER",
  "eoracleChainId": $EORACLE_CHAIN_ID,
  "targetChainId": $CHAIN_ID,
  "publishers": $PUBLISHERS,
  "allowedSenders": $ALLOWED_SENDERS,
  "supportedFeedIds": $FEED_IDS_JSON,
  "supportedFeedsData": $SUPPORTED_FEEDS_DATA
}
EOF

# Format the config file
npx prettier --write "$CONFIG_DIR/targetContractSetConfig.json" --ignore-path ''

echo "Generated config file at $CONFIG_DIR/targetContractSetConfig.json"

# Set up broadcast flag based on dry_run
if [ "${dry_run}" = "true" ]; then
    BROADCAST_FLAG=""
    echo -e "${YELLOW}Running in dry-run mode - will simulate transactions${RESET}"
else
    BROADCAST_FLAG="--broadcast"
    echo -e "${GREEN}Running in broadcast mode - will submit transactions${RESET}"
fi

# Run the deployment
echo -e "${BOLD}Starting deployment...${RESET}"
result=$(forge script script/deployment/DeployAll.s.sol:DeployAll \
    --rpc-url $TARGET_RPC_URL \
    --private-key $DEPLOYER_PRIVATE_KEY \
    --legacy \
    --slow $BROADCAST_FLAG \
    --gas-estimate-multiplier 200 -vvvv)
rc=$?

if [ $rc -ne 0 ]; then
    echo -e "${RED}Error: Deployment failed${RESET}\nOutput: $result"
    exit 1
fi

if [ "${dry_run}" = "true" ]; then
    echo -e "${GREEN}Dry run deployment simulation complete${RESET}"
    echo -e "${BOLD}Config file generated at:${RESET} ${YELLOW}$CONFIG_DIR/targetContractSetConfig.json${RESET}"
else
    echo -e "${GREEN}Deployment complete${RESET}"
    echo -e "${BOLD}Config file generated at:${RESET} ${YELLOW}$CONFIG_DIR/targetContractSetConfig.json${RESET}"
fi