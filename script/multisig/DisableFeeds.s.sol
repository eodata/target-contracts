// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { DisableFeedsTimelocked } from "../timelocked/DisableFeedsTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/DisableFeeds.s.sol \
    --sig "run(bool,bool,uint256[],string,string)" \
    true \
    true \
    <feedIds> \
    "sepolia" \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
/// @title DisableFeeds
/// @notice Script to disable feeds via multisig
/// @author eOracle
contract DisableFeeds is ExecuteAny {
    using stdJson for string;

    /// @notice Main run function to disable feeds via multisig
    /// @param send Whether to send the transaction
    /// @param isExecution Whether to execute (true) or schedule (false)
    /// @param feedIds Array of feed IDs to disable
    /// @param chainAlias Chain alias for the multisig
    /// @param seed Seed for transaction salt
    function run(
        bool send,
        bool isExecution,
        uint256[] calldata feedIds,
        string calldata chainAlias,
        string calldata seed
    )
        external
    {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        DisableFeedsTimelocked disableFeedsTimelocked = new DisableFeedsTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = disableFeedsTimelocked.execute(isExecution, false, feedIds, seed);
        run(send, multisig, chainAlias, targets, txns);
    }
}
