// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../src/EOFeedManager.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/ResetFeedTimestampsTimelocked.s.sol \
    --sig "run(bool,uint256[],string)" \
    false \
    <feedIds> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract ResetFeedTimestampsTimelocked is Script, TimelockBase {
    using stdJson for string;

    bool public isExecutionMode;

    EOFeedManager public feedManager;
    TimelockController public timelock;

    function run(bool isExecution, uint256[] calldata feedIds, string memory seed) external {
        vm.startBroadcast();
        execute(isExecution, true, feedIds, seed);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution, uint256[] calldata feedIds, string memory seed) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, feedIds, seed);
        vm.stopBroadcast();
    }

    function execute(
        bool isExecution,
        bool send,
        uint256[] calldata feedIds,
        string memory seed
    )
        public
        returns (bytes memory)
    {
        isExecutionMode = isExecution;
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        bytes memory data = abi.encodeCall(feedManager.resetFeedTimestamps, (feedIds));
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(feedManager), data, seed);

        return txn;
    }
}
