// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../../src/EOFeedManager.sol";

contract SetupCoreContractsTimelocked is Script {
    using stdJson for string;

    uint16[] public feedIds;
    bool[] public feedBools;
    address[] public publishers;
    bool[] public publishersBools;

    EOFeedManager public feedManager;
    TimelockController public timelock;

    function run() external {
        vm.startBroadcast();
        execute();
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom) public {
        vm.startBroadcast(broadcastFrom);
        execute();
        vm.stopBroadcast();
    }

    function execute() public {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();

        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        // Set supported feedIds in FeedManager which are not set yet
        _updateSupportedFeeds(configStructured);

        // Set publishers in FeedManager which are not set yet
        _updateWhiteListedPublishers(configStructured);
    }

    function _updateSupportedFeeds(EOJsonUtils.Config memory _configData) internal {
        uint16 feedId;

        for (uint256 i = 0; i < _configData.supportedFeedIds.length; i++) {
            feedId = uint16(_configData.supportedFeedIds[i]);
            if (!feedManager.isSupportedFeed(feedId)) {
                feedIds.push(feedId);
                feedBools.push(true);
            }
        }
        if (feedIds.length > 0) {
            bytes memory data = abi.encodeCall(feedManager.setSupportedFeeds, (feedIds, feedBools));
            callTimelock(address(feedManager), data);
        }
    }

    function _updateWhiteListedPublishers(EOJsonUtils.Config memory _configData) internal {
        for (uint256 i = 0; i < _configData.publishers.length; i++) {
            if (!feedManager.isWhitelistedPublisher(_configData.publishers[i])) {
                publishers.push(_configData.publishers[i]);
                publishersBools.push(true);
            }
        }
        if (publishers.length > 0) {
            bytes memory data = abi.encodeCall(feedManager.whitelistPublishers, (publishers, publishersBools));
            callTimelock(address(feedManager), data);
        }
    }

    function callTimelock(address target, bytes memory data) internal {
        bool isExecution = vm.envOr("IS_EXECUTION", false);
        bytes32 salt = keccak256(abi.encode("feeds"));
        bytes32 predecessor;
        uint256 delay = timelock.getMinDelay();

        if (isExecution) {
            timelock.execute(target, 0, data, predecessor, salt);
        } else {
            timelock.schedule(target, 0, data, predecessor, salt, delay);
        }
    }
}
