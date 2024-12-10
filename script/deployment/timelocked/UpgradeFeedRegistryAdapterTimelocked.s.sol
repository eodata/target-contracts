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

contract UpgradeFeedRegistryAdapterTimelocked is Script {
    using stdJson for string;

    bool internal isExecutionMode;
    TimelockController public timelock;

    function run(bool isExecution) external {
        isExecutionMode = isExecution;
        vm.startBroadcast();
        execute();
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution) public {
        isExecutionMode = isExecution;
        vm.startBroadcast(broadcastFrom);
        execute();
        vm.stopBroadcast();
    }

    function execute() public {
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
        callTimelock(address(admin), data);
    }

    function callTimelock(address target, bytes memory data) internal {
        bytes32 salt = keccak256(abi.encode("feedRegistryAdapter"));
        bytes32 predecessor;
        uint256 delay = timelock.getMinDelay();

        if (isExecutionMode) {
            timelock.execute(target, 0, data, predecessor, salt);
        } else {
            timelock.schedule(target, 0, data, predecessor, salt, delay);
        }
    }
}
