// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../../src/EOFeedManager.sol";

contract SetupCoreContracts is Script {
    using stdJson for string;

    address[] public publishers;
    bool[] public publishersBools;

    EOFeedManager public feedManager;

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

        // Set publishers in FeedManager which are not set yet
        _updateWhiteListedPublishers(configStructured);
    }

    function _updateWhiteListedPublishers(EOJsonUtils.Config memory _configData) internal {
        for (uint256 i = 0; i < _configData.publishers.length; i++) {
            if (!feedManager.isWhitelistedPublisher(_configData.publishers[i])) {
                publishers.push(_configData.publishers[i]);
                publishersBools.push(true);
            }
        }
        if (publishers.length > 0) {
            feedManager.whitelistPublishers(publishers, publishersBools);
        }
    }
}
