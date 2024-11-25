// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";

contract TransferOwnershipToTimelock is Script {
    using stdJson for string;

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
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        address feedManager = outputConfig.readAddress(".feedManager");
        address feedVerifier = outputConfig.readAddress(".feedVerifier");
        address feedRegistryAdapter = outputConfig.readAddress(".feedRegistryAdapter");
        address timelock = outputConfig.readAddress(".timelock");

        OwnableUpgradeable(feedManager).transferOwnership(timelock);
        OwnableUpgradeable(feedVerifier).transferOwnership(timelock);
        OwnableUpgradeable(feedRegistryAdapter).transferOwnership(timelock);
    }
}
