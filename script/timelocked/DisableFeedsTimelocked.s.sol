// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../src/EOFeedManager.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/DisableFeedsTimelocked.s.sol \
    --sig "run(bool,uint256[],string)" \
    false \
    <feedIds> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
/// @title DisableFeedsTimelocked
/// @notice Script to disable feeds via timelock
/// @author eOracle
contract DisableFeedsTimelocked is Script, TimelockBase {
    using stdJson for string;

    /// @notice Execution mode flag
    bool public isExecutionMode;

    /// @notice Feed manager contract
    EOFeedManager public feedManager;
    /// @notice Timelock controller contract
    TimelockController public timelock;

    /// @notice Main run function to disable feeds
    /// @param isExecution Whether to execute (true) or schedule (false)
    /// @param feedIds Array of feed IDs to disable
    /// @param seed Seed for transaction salt
    function run(bool isExecution, uint256[] calldata feedIds, string calldata seed) external {
        vm.startBroadcast();
        execute(isExecution, true, feedIds, seed);
        vm.stopBroadcast();
    }

    /// @notice Run function for testing purposes
    /// @param broadcastFrom Address to broadcast from
    /// @param isExecution Whether to execute (true) or schedule (false)
    /// @param feedIds Array of feed IDs to disable
    /// @param seed Seed for transaction salt
    function run(address broadcastFrom, bool isExecution, uint256[] calldata feedIds, string calldata seed) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, feedIds, seed);
        vm.stopBroadcast();
    }

    /// @notice Execute the disable feeds operation
    /// @param isExecution Whether to execute (true) or schedule (false)
    /// @param send Whether to send the transaction
    /// @param feedIds Array of feed IDs to disable
    /// @param seed Seed for transaction salt
    /// @return Transaction bytes
    function execute(
        bool isExecution,
        bool send,
        uint256[] calldata feedIds,
        string calldata seed
    )
        public
        returns (bytes memory)
    {
        isExecutionMode = isExecution;
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        // Create bool array with all false values to disable all provided feeds
        bool[] memory isSupported = new bool[](feedIds.length);

        bytes memory data = abi.encodeCall(feedManager.setSupportedFeeds, (feedIds, isSupported));
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(feedManager), data, seed);

        return txn;
    }
}
