// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { EOFeedFactoryBeacon } from "../../src/adapters/factories/EOFeedFactoryBeacon.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { TimelockBase } from "./TimelockBase.sol";
import { EOFeedManager } from "../../src/EOFeedManager.sol";
import { EOFeedAdapterOldCompatible } from "../../src/adapters/EOFeedAdapterOldCompatible.sol";

contract UpgradeFeedManagerAndAdaptersTimelocked is Script, TimelockBase {
    using stdJson for string;

    struct LocalVars {
        address feedManager;
        address admin;
        address feedRegistryAdapter;
        address bls;
        address implementationAddress;
        TimelockController timelock;
        string outputConfig;
        bytes initData;
        bytes payload;
        address[] targets;
        bytes[] payloads;
        uint256[] values;
        bytes32 salt;
        bytes32 predecessor;
        uint256 delay;
    }

    LocalVars public vars;

    function run(bool isExecution) external {
        vm.startBroadcast();
        execute(isExecution, true);
        vm.stopBroadcast();
    }

    function execute(bool isExecution, bool send) public returns (bytes memory) {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();
        vars.outputConfig = EOJsonUtils.initOutputConfig();
        vars.feedManager = vars.outputConfig.readAddress(".feedManager");
        vars.feedRegistryAdapter = vars.outputConfig.readAddress(".feedRegistryAdapter");
        vars.bls = vars.outputConfig.readAddress(".bls");
        vars.timelock = TimelockController(payable(vars.outputConfig.readAddress(".timelock")));
        vars.admin = Upgrades.getAdminAddress(vars.feedManager);

        // 1. Upgrade feed manager
        if (isExecution) {
            vars.implementationAddress = vars.outputConfig.readAddress(".feedManagerImplementation");
        } else {
            vars.implementationAddress = address(new EOFeedManager());
            string memory outputConfigJson =
                EOJsonUtils.OUTPUT_CONFIG.serialize("feedManagerImplementation", vars.implementationAddress);
            EOJsonUtils.writeConfig(outputConfigJson);
        }

        vars.payload = abi.encodeCall(
            ProxyAdmin(vars.admin).upgradeAndCall,
            (ITransparentUpgradeableProxy(payable(vars.feedManager)), vars.implementationAddress, vars.initData)
        );

        vars.payloads.push(vars.payload);
        vars.targets.push(vars.admin);
        vars.values.push(0);

        // 2. Set pauser registry
        address pauserRegistry = vars.outputConfig.readAddress(".pauserRegistry");
        vars.payload = abi.encodeCall(EOFeedManager(vars.feedManager).setPauserRegistry, (pauserRegistry));
        vars.payloads.push(vars.payload);
        vars.targets.push(vars.feedManager);
        vars.values.push(0);

        // 3. Set feed deployer
        address feedDeployer = configStructured.feedDeployer;
        vars.payload = abi.encodeCall(EOFeedManager(vars.feedManager).setFeedDeployer, (feedDeployer));
        vars.payloads.push(vars.payload);
        vars.targets.push(vars.feedManager);
        vars.values.push(0);

        // 4. Set feed verifier
        address feedVerifier = vars.outputConfig.readAddress(".feedVerifier");
        vars.payload = abi.encodeCall(EOFeedManager(vars.feedManager).setFeedVerifier, (feedVerifier));
        vars.payloads.push(vars.payload);
        vars.targets.push(vars.feedManager);
        vars.values.push(0);

        // 5. Upgrade beacon proxy
        if (isExecution) {
            vars.implementationAddress = vars.outputConfig.readAddress(".feedAdapterImplementation");
        } else {
            vars.implementationAddress = address(new EOFeedAdapterOldCompatible());
            string memory outputConfigJson =
                EOJsonUtils.OUTPUT_CONFIG.serialize("feedAdapterImplementation", vars.implementationAddress);
            EOJsonUtils.writeConfig(outputConfigJson);
        }
        address beacon = EOFeedFactoryBeacon(vars.feedRegistryAdapter).getBeacon();
        vars.payload = abi.encodeCall(UpgradeableBeacon(beacon).upgradeTo, (vars.implementationAddress));
        vars.payloads.push(vars.payload);
        vars.targets.push(beacon);
        vars.values.push(0);

        // schedule or execute
        bytes memory txn = callTimelockBatch(
            vars.timelock, isExecution, send, vars.targets, vars.payloads, vars.values, "feedManagerUpgrade"
        );

        delete vars;
        return txn;
    }
}
