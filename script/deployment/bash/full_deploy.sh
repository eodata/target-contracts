#!/bin/bash

set -euo pipefail

# Check required environment variables
required_vars=(
    "PRIVATE_KEY"
    "OWNER_PRIVATE_KEY"
    "RPC_URL"
    "EORACLE_CHAIN_ID"
    "PROXY_ADMIN_OWNER"
    "TARGET_CONTRACTS_OWNER"
    "PUBLISHERS"
    "SUPPORTED_FEED_IDS"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "Error: Required environment variable $var is not set"
        exit 1
    fi
done

# Set default values for optional variables
USE_PRECOMPILED_MODEXP=${USE_PRECOMPILED_MODEXP:-false}
BROADCAST_MODE=${BROADCAST_MODE:-broadcast} # Can be 'broadcast', 'dry-run'
# Validate USE_PRECOMPILED_MODEXP is boolean
if [[ "${USE_PRECOMPILED_MODEXP}" != "true" && "${USE_PRECOMPILED_MODEXP}" != "false" ]]; then
    echo "Error: USE_PRECOMPILED_MODEXP must be either 'true' or 'false'"
    exit 1
fi

# Validate BROADCAST_MODE
if [[ "${BROADCAST_MODE}" != "broadcast" && "${BROADCAST_MODE}" != "dry-run" ]]; then
    echo "Error: BROADCAST_MODE must be either 'broadcast', 'dry-run'"
    exit 1
fi

# Set ALLOWED_SENDERS based on EORACLE_CHAIN_ID
case $EORACLE_CHAIN_ID in
    42420)
        ALLOWED_SENDERS='["0x4E70004b01987B4fd7DAcab348F0B39E9AE26110"]'
        echo "Using predefined ALLOWED_SENDERS for EORACLE_CHAIN_ID 42420"
        ;;
    42421)
        ALLOWED_SENDERS='["0x6B0BE2aaD42612803c9Fc389A3806EF21E8cbDb6"]'
        echo "Using predefined ALLOWED_SENDERS for EORACLE_CHAIN_ID 42421"
        ;;
    *)
        if [ -z "${ALLOWED_SENDERS:-}" ]; then
            echo "Error: ALLOWED_SENDERS must be set for EORACLE_CHAIN_ID $EORACLE_CHAIN_ID"
            exit 1
        fi
        ;;
esac

# Get chain ID from RPC URL
CHAIN_ID=$(cast chain-id --rpc-url $RPC_URL)
echo "Detected Chain ID: $CHAIN_ID"

# Create config directory if it doesn't exist
CONFIG_DIR="script/config/$CHAIN_ID/$EORACLE_CHAIN_ID"
mkdir -p "$CONFIG_DIR"

# Read and parse the feed IDs
IFS=',' read -ra FEED_IDS <<< "$SUPPORTED_FEED_IDS"
FEED_IDS_JSON="[$(echo "${FEED_IDS[@]}" | tr ' ' ',')]"

# Generate feeds data array from AssetsList.json
ASSETS_LIST_PATH="script/config/AssetsList.json"
if [ ! -f "$ASSETS_LIST_PATH" ]; then
    echo "Error: AssetsList.json not found at $ASSETS_LIST_PATH"
    exit 1
fi

# Create a jq filter to select feeds based on the provided feed IDs
JQ_FILTER=".supportedFeedsData | map(select(.feedId | tostring | IN(\$feed_ids[])))"

# Generate the feeds data array using jq
SUPPORTED_FEEDS_DATA=$(jq --argjson feed_ids "$FEED_IDS_JSON" "$JQ_FILTER" "$ASSETS_LIST_PATH")

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

# Set up broadcast flags based on BROADCAST_MODE
case $BROADCAST_MODE in
    "broadcast")
        BROADCAST_FLAG="--broadcast"
        echo "Running in broadcast mode - will submit transactions"
        ;;
    "dry-run")
        BROADCAST_FLAG=""
        echo "Running in dry-run mode - will simulate transactions"
        ;;
esac

# Run the deployment
echo "Starting deployment..."
forge script script/deployment/DeployAll.s.sol:DeployAll \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    $BROADCAST_FLAG \
    --legacy \
    --slow \
    --gas-estimate-multiplier 200

echo "Deployment completed"