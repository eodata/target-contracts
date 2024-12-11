// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../../src/EOFeedManager.sol";
import { TimelockBase } from "./TimelockBase.sol";

contract WhitelistPublishersTimelocked is Script, TimelockBase {
    using stdJson for string;

    address[] public publishers;
    bool[] public publishersBools;

    bool public isExecutionMode;

    EOFeedManager public feedManager;
    TimelockController public timelock;

    function run(bool isExecution) external {
        vm.startBroadcast();
        execute(isExecution, true);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true);
        vm.stopBroadcast();
    }

    function execute(bool isExecution, bool send) public returns (bytes memory) {
        isExecutionMode = isExecution;
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();

        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        // Set publishers in FeedManager which are not set yet
        for (uint256 i = 0; i < configStructured.publishers.length; i++) {
            if (!feedManager.isWhitelistedPublisher(configStructured.publishers[i])) {
                publishers.push(configStructured.publishers[i]);
                publishersBools.push(true);
            }
        }
        if (publishers.length == 0) revert("No publishers to whitelist");
        bytes memory data = abi.encodeCall(feedManager.whitelistPublishers, (publishers, publishersBools));
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(feedManager), data, "publishers");

        delete publishers;
        delete publishersBools;

        return txn;
    }
}
