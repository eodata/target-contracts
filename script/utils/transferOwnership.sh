#!/bin/bash

# Default to dry run mode
dry_run=true

# Check if required environment variables are set
if [ -z "$TARGET_RPC_URL" ] || [ -z "$OWNER_ADDRESS" ] || [ -z "$UPGRADER_ADDRESS" ] || [ -z "$EORACLE_CHAIN_ID" ] || [ -z "$DEPLOYER_PRIVATE_KEY" ]; then
    echo "Error: Required environment variables not set"
    echo "Please set TARGET_RPC_URL, OWNER_ADDRESS, UPGRADER_ADDRESS, EORACLE_CHAIN_ID, and DEPLOYER_PRIVATE_KEY"
    exit 1
fi

# Add after line 4 (after dry_run=true):
if [ "${dry_run}" = "true" ]; then
    echo "Running in dry run mode - no transactions will be broadcast"
fi

# Get chain ID
CHAIN_ID=$(cast chain-id -r $TARGET_RPC_URL)
echo "Chain ID: $CHAIN_ID"

# Function to get config file path
get_config_file() {
    local chain_id=$1
    local config_file="script/config/$chain_id/$EORACLE_CHAIN_ID/targetContractAddresses.json"
    if [ -f "$config_file" ]; then
        echo "$config_file"
        return 0
    fi
    echo ""
}

# Get config file path
CONFIG_FILE=$(get_config_file $CHAIN_ID)

if [ -z "$CONFIG_FILE" ]; then
    echo "Error: No config file found for chain ID $CHAIN_ID"
    exit 1
fi

echo "Using config file: $CONFIG_FILE"

# Function to transfer ownership
transfer_ownership() {
    local contract=$1
    local new_owner=$2
    local address=$3
    
    if [ -z "$address" ] || [ "$address" = "null" ] || [ "$address" = '""' ]; then
        return
    fi

    echo "Transferring ownership of $contract at $address to $new_owner"
    
    # Get current owner
    current_owner=$(cast call $address "owner()" --rpc-url $TARGET_RPC_URL || echo "")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get current owner for $contract"
        exit 1
    fi
    
    if [ ! -z "$current_owner" ]; then
        echo "Current owner: $current_owner"
        if [ "${dry_run}" = "true" ]; then
            echo "DRY RUN: Simulating ownership transfer..."
            if ! cast call --trace $address "transferOwnership(address)" $new_owner --rpc-url $TARGET_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY; then
                echo "Error: Dry run failed for $contract ownership transfer"
                exit 1
            fi
            echo "DRY RUN: Ownership transfer simulation successful"
        else
            if ! cast send $address "transferOwnership(address)" $new_owner --rpc-url $TARGET_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY; then
                echo "Error: Failed to transfer ownership for $contract"
                exit 1
            fi
        fi
    fi
}

# Function to transfer proxy admin ownership
transfer_proxy_admin_ownership() {
    local contract=$1
    local new_owner=$2
    local address=$3
    
    if [ -z "$address" ] || [ "$address" = "null" ] || [ "$address" = '""' ]; then
        return
    fi

    echo "Transferring proxy admin ownership of $contract at $address"
    
    # Get proxy admin address
    proxy_admin=$(cast adm $address --rpc-url $TARGET_RPC_URL || echo "")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get proxy admin for $contract"
        exit 1
    fi
    
    if [ ! -z "$proxy_admin" ]; then
        echo "Proxy admin: $proxy_admin"
        # Get current proxy admin owner
        current_owner=$(cast call $proxy_admin "owner()" --rpc-url $TARGET_RPC_URL || echo "")
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get current proxy admin owner for $contract"
            exit 1
        fi
        
        if [ ! -z "$current_owner" ]; then
            echo "Current proxy admin owner: $current_owner"
            if [ "${dry_run}" = "true" ]; then
                echo "DRY RUN: Simulating proxy admin ownership transfer..."
                if ! cast call --trace $proxy_admin "transferOwnership(address)" $new_owner --rpc-url $TARGET_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY; then
                    echo "Error: Dry run failed for $contract proxy admin ownership transfer"
                    exit 1
                fi
                echo "DRY RUN: Proxy admin ownership transfer simulation successful"
            else
                if ! cast send $proxy_admin "transferOwnership(address)" $new_owner --rpc-url $TARGET_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --broadcast; then
                    echo "Error: Failed to transfer proxy admin ownership for $contract"
                    exit 1
                fi
            fi
        fi
    fi
}

# Read contract addresses from config file
FEED_MANAGER=$(jq -r '.feedManager' $CONFIG_FILE)
FEED_VERIFIER=$(jq -r '.feedVerifier' $CONFIG_FILE)
FEED_REGISTRY_ADAPTER=$(jq -r '.feedRegistryAdapter' $CONFIG_FILE)

# Transfer contract ownerships
transfer_ownership "Feed Manager" $OWNER_ADDRESS $FEED_MANAGER
transfer_ownership "Feed Verifier" $OWNER_ADDRESS $FEED_VERIFIER
transfer_ownership "Feed Registry Adapter" $OWNER_ADDRESS $FEED_REGISTRY_ADAPTER

# Transfer proxy admin ownerships
transfer_proxy_admin_ownership "Feed Manager" $UPGRADER_ADDRESS $FEED_MANAGER
transfer_proxy_admin_ownership "Feed Verifier" $UPGRADER_ADDRESS $FEED_VERIFIER
transfer_proxy_admin_ownership "Feed Registry Adapter" $UPGRADER_ADDRESS $FEED_REGISTRY_ADAPTER

echo "Ownership transfer complete"
