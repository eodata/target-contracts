#!/bin/bash

# ANSI escape codes for text color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BOLD="\033[1m"
RESET="\033[0m"

usage() {
    echo "Usage: $0 --rpc-url <uri> --owner-address <address> --upgrader-address <address> --eoracle-chain-id <id> --private-key <private key> [--dry-run]"
    exit 1
}

dry_run=true

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --rpc-url)
            TARGET_RPC_URL=${2}
            shift 2
            ;;
        --owner-address)
            OWNER_ADDRESS=${2}
            shift 2
            ;;
        --upgrader-address)
            UPGRADER_ADDRESS=${2}
            shift 2
            ;;
        --eoracle-chain-id)
            EORACLE_CHAIN_ID=${2}
            shift 2
            ;;
        --private-key)
            DEPLOYER_PRIVATE_KEY=${2}
            shift 2
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [ -z "$TARGET_RPC_URL" ] || [ -z "$OWNER_ADDRESS" ] || [ -z "$UPGRADER_ADDRESS" ] || [ -z "$EORACLE_CHAIN_ID" ] || [ -z "$DEPLOYER_PRIVATE_KEY" ]; then
    usage
fi

if [ "${dry_run}" = "true" ]; then
    echo "Running in dry run mode - no transactions will be broadcast"
fi

# Function to transfer ownership
transfer_ownership() {
    local contract_name=$1
    local new_owner=$2
    local contract_address=$3
    local private_key=$4
    local rpc_url=$5
    local dry_run=$6
    
    if [ -z "$contract_address" ] || [ "$contract_address" = "null" ] || [ "$contract_address" = '""' ]; then
        return
    fi

    echo -e "${BOLD}Transferring ownership of ${YELLOW}$contract_name${RESET}${BOLD} at $contract_address${RESET}"
    
    # Get current owner
    result=$(cast call $contract_address "owner()" --rpc-url $rpc_url)
    rc=$?
    if [ $rc -ne 0 ]; then
        echo -e "${RED}Error: Failed to get current owner for $contract_name${RESET}\nOutput: $result"
        exit 1
    fi
    current_owner=$result
    
    if [ ! -z "$current_owner" ]; then
        echo -e "Current owner: ${YELLOW}$current_owner${RESET}"
        if [ "${dry_run}" = "true" ]; then
            echo -e "${YELLOW}DRY RUN: Simulating ownership transfer...${RESET}"
            result=$(cast call --trace $contract_address "transferOwnership(address)" $new_owner --rpc-url $rpc_url --private-key $private_key)
            rc=$?
            if [ $rc -ne 0 ] || [[ $result =~ "Revert" ]]; then
                echo -e "${RED}Error: Dry run failed for $contract_name ownership transfer${RESET}\nOutput: $result"
                exit 1
            fi
            echo -e "${GREEN}DRY RUN: Ownership transfer simulation successful${RESET}"
        else
            result=$(cast send $contract_address "transferOwnership(address)" $new_owner --rpc-url $rpc_url --private-key $private_key)
            rc=$?
            if [ $rc -ne 0 ]; then
                echo -e "${RED}Error: Failed to transfer ownership for $contract_name${RESET}\nOutput: $result"
                exit 1
            fi
            echo -e "${GREEN}Successfully transferred ownership of $contract_name${RESET}"
        fi
    fi
}

# Function to transfer proxy admin ownership
transfer_proxy_admin_ownership() {
    local contract_name=$1
    local new_owner=$2
    local contract_address=$3
    local private_key=$4
    local rpc_url=$5
    local dry_run=$6
    
    if [ -z "$contract_address" ] || [ "$contract_address" = "null" ] || [ "$contract_address" = '""' ]; then
        return
    fi

    echo -e "${BOLD}Transferring proxy admin ownership of ${YELLOW}$contract_name${RESET}${BOLD} at $contract_address${RESET}"
    
    # Get proxy admin address
    result=$(cast adm $contract_address --rpc-url $rpc_url)
    rc=$?
    if [ $rc -ne 0 ]; then
        echo -e "${RED}Error: Failed to get proxy admin for $contract_name${RESET}\nOutput: $result"
        exit 1
    fi
    proxy_admin=$result
    
    if [ ! -z "$proxy_admin" ]; then
        echo -e "Proxy admin: ${YELLOW}$proxy_admin${RESET}"
        # Get current proxy admin owner
        result=$(cast call $proxy_admin "owner()" --rpc-url $rpc_url)
        rc=$?
        if [ $rc -ne 0 ]; then
            echo -e "${RED}Error: Failed to get current proxy admin owner for $contract_name${RESET}\nOutput: $result"
            exit 1
        fi
        current_owner=$result
        
        if [ ! -z "$current_owner" ]; then
            echo -e "Current proxy admin owner: ${YELLOW}$current_owner${RESET}"
            if [ "${dry_run}" = "true" ]; then
                echo -e "${YELLOW}DRY RUN: Simulating proxy admin ownership transfer...${RESET}"
                result=$(cast call --trace $proxy_admin "transferOwnership(address)" $new_owner --rpc-url $rpc_url --private-key $private_key)
                rc=$?
                if [ $rc -ne 0 ] || [[ $result =~ "Revert" ]]; then
                    echo -e "${RED}Error: Dry run failed for $contract_name proxy admin ownership transfer${RESET}\nOutput: $result"
                    exit 1
                fi
                echo -e "${GREEN}DRY RUN: Proxy admin ownership transfer simulation successful${RESET}"
            else
                result=$(cast send $proxy_admin "transferOwnership(address)" $new_owner --rpc-url $rpc_url --private-key $private_key)
                rc=$?
                if [ $rc -ne 0 ]; then
                    echo -e "${RED}Error: Failed to transfer proxy admin ownership for $contract_name${RESET}\nOutput: $result"
                    exit 1
                fi
                echo -e "${GREEN}Successfully transferred proxy admin ownership of $contract_name${RESET}"
            fi
        fi
    fi
}

# Get chain ID
CHAIN_ID=$(cast chain-id -r $TARGET_RPC_URL)
echo "Chain ID: $CHAIN_ID"

CONFIG_FILE="script/config/$CHAIN_ID/$EORACLE_CHAIN_ID/targetContractAddresses.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error${RESET}: No config file ${CONFIG_FILE} found for chain ID ${CHAIN_ID}"
    exit 1
fi

echo "Using config file: $CONFIG_FILE"

# Read contract addresses from config file
FEED_MANAGER=$(jq -r '.feedManager' $CONFIG_FILE)
FEED_VERIFIER=$(jq -r '.feedVerifier' $CONFIG_FILE)
FEED_REGISTRY_ADAPTER=$(jq -r '.feedRegistryAdapter' $CONFIG_FILE)

# Transfer contract ownerships
# transfer_ownership "Feed Manager" $OWNER_ADDRESS $FEED_MANAGER $DEPLOYER_PRIVATE_KEY $TARGET_RPC_URL $dry_run
# transfer_ownership "Feed Verifier" $OWNER_ADDRESS $FEED_VERIFIER $DEPLOYER_PRIVATE_KEY $TARGET_RPC_URL $dry_run
# transfer_ownership "Feed Registry Adapter" $OWNER_ADDRESS $FEED_REGISTRY_ADAPTER $DEPLOYER_PRIVATE_KEY $TARGET_RPC_URL $dry_run

# Transfer proxy admin ownerships
transfer_proxy_admin_ownership "Feed Manager" $UPGRADER_ADDRESS $FEED_MANAGER $DEPLOYER_PRIVATE_KEY $TARGET_RPC_URL $dry_run
# transfer_proxy_admin_ownership "Feed Verifier" $UPGRADER_ADDRESS $FEED_VERIFIER $DEPLOYER_PRIVATE_KEY $TARGET_RPC_URL $dry_run
# transfer_proxy_admin_ownership "Feed Registry Adapter" $UPGRADER_ADDRESS $FEED_REGISTRY_ADAPTER $DEPLOYER_PRIVATE_KEY $TARGET_RPC_URL $dry_run

echo -e "${GREEN}Ownership transfer complete${RESET}"
