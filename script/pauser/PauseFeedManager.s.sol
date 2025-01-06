// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../src/EOFeedManager.sol";

contract PauseFeedManager is Script {
    using stdJson for string;

    function run() public {
        string memory outputConfig = EOJsonUtils.getOutputConfig();
        EOFeedManager feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));

        vm.startBroadcast();
        feedManager.pause();
        vm.stopBroadcast();
    }
}
