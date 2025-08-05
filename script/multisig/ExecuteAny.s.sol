// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { BatchScript } from "forge-safe/BatchScript.sol";

/*
Usage: (add --broadcast)
forge script script/ExecuteAny.s.sol \
    --sig "run(bool,address,bytes,string)" \
    false \
    0xTargetAddress \
    "0x00" \
    "holesky" \
    --rpc-url $RPC_URL \
    -vvvv
*/
/// @notice Script to execute any transactions via Gnosis Safe
contract ExecuteAny is BatchScript {
    modifier setChainModifier(string memory chainAlias) {
        vm.setEnv("WALLET_TYPE", "local");
        vm.setEnv("CHAIN", chainAlias);
        _;
    }

    /// @notice The main script entrypoint
    /// @param send If true, will execute the transaction. If false, will simulate
    /// @param multisig Address of the multisig
    /// @param chainAlias Chain alias
    /// @param targets Array of target addresses
    /// @param txns Array of calldata of the transactions to execute
    function run(
        bool send,
        address multisig,
        string memory chainAlias,
        address[] memory targets,
        bytes[] memory txns
    )
        public
        setChainModifier(chainAlias)
        isBatch(multisig)
    {
        require(targets.length == txns.length, "Parameters length mismatch");

        for (uint256 i = 0; i < targets.length; i++) {
            addToBatch(targets[i], 0, txns[i]);
        }
        // Execute batch
        executeBatch(send);
    }
}
