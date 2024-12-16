// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { EOFeedRegistryAdapter } from "../../../src/adapters/EOFeedRegistryAdapter.sol";
import { TimelockBase } from "./TimelockBase.sol";

contract UpgradeFeedRegistryAdapterTimelocked is Script, TimelockBase {
    using stdJson for string;

    bool internal isExecutionMode;
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

        string memory config = EOJsonUtils.initOutputConfig();
        address proxyAddress = config.readAddress(".feedRegistryAdapter");
        timelock = TimelockController(payable(config.readAddress(".timelock")));
        address admin = Upgrades.getAdminAddress(proxyAddress);

        address implementationAddress;
        if (isExecutionMode) {
            implementationAddress = config.readAddress(".feedRegistryAdapterImplementation");
        } else {
            implementationAddress = address(new EOFeedRegistryAdapter());
            string memory outputConfigJson =
                EOJsonUtils.OUTPUT_CONFIG.serialize("feedRegistryAdapterImplementation", implementationAddress);
            EOJsonUtils.writeConfig(outputConfigJson);
        }
        bytes memory initData;
        bytes memory data = abi.encodeCall(
            ProxyAdmin(admin).upgradeAndCall,
            (ITransparentUpgradeableProxy(payable(proxyAddress)), implementationAddress, initData)
        );
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(admin), data, "feedRegistryAdapter");
        return txn;
    }
}
