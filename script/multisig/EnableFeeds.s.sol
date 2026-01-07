// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { SetSupportedFeedsTimelocked } from "../timelocked/SetSupportedFeedsTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/EnableFeeds.s.sol \
    --sig "run(bool,bool,uint256[],string,string)" \
    true \
    true \
    <feedIds> \
    "sepolia" \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
/// @title EnableFeeds
/// @notice Script to enable feeds via multisig
/// @author eOracle
contract EnableFeeds is ExecuteAny {
    using stdJson for string;

    /// @notice Main run function to enable feeds via multisig
    /// @param send Whether to send the transaction
    /// @param isExecution Whether to execute (true) or schedule (false)
    /// @param feedIds Array of feed IDs to enable
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

        SetSupportedFeedsTimelocked setSupportedFeedsTimelocked = new SetSupportedFeedsTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = setSupportedFeedsTimelocked.execute(isExecution, false, feedIds, true, seed);
        run(send, multisig, chainAlias, targets, txns);
    }
}
