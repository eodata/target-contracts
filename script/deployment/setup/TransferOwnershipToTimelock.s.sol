// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { EOFeedFactoryBeacon } from "../../../src/adapters/factories/EOFeedFactoryBeacon.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../../src/EOFeedManager.sol";
import { EOFeedRegistryAdapter } from "../../../src/adapters/EOFeedRegistryAdapter.sol";

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
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();

        address feedManager = outputConfig.readAddress(".feedManager");
        address feedVerifier = outputConfig.readAddress(".feedVerifier");
        address feedRegistryAdapter = outputConfig.readAddress(".feedRegistryAdapter");
        address timelock = outputConfig.readAddress(".timelock");

        EOFeedManager(feedManager).setFeedDeployer(configStructured.feedDeployer);
        EOFeedRegistryAdapter(feedRegistryAdapter).setFeedDeployer(configStructured.feedDeployer);

        OwnableUpgradeable(feedManager).transferOwnership(timelock);
        OwnableUpgradeable(feedVerifier).transferOwnership(timelock);
        OwnableUpgradeable(feedRegistryAdapter).transferOwnership(timelock);
        UpgradeableBeacon(EOFeedFactoryBeacon(feedRegistryAdapter).getBeacon()).transferOwnership(timelock);

        ProxyAdmin admin = ProxyAdmin(Upgrades.getAdminAddress(feedManager));
        if (admin.owner() != timelock) {
            admin.transferOwnership(timelock);
        }
        admin = ProxyAdmin(Upgrades.getAdminAddress(feedVerifier));
        if (admin.owner() != timelock) {
            admin.transferOwnership(timelock);
        }
        admin = ProxyAdmin(Upgrades.getAdminAddress(feedRegistryAdapter));
        if (admin.owner() != timelock) {
            admin.transferOwnership(timelock);
        }
    }
}
