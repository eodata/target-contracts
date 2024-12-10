// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { EOFeedFactoryBeacon } from "../../../src/adapters/factories/EOFeedFactoryBeacon.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TransferOwnershipTimelocked is Script {
    using stdJson for string;

    struct LocalVars {
        address feedManager;
        address feedVerifier;
        address feedRegistryAdapter;
        address timelock;
        address[] targets;
        bytes[] payloads;
        uint256[] values;
        bytes32 salt;
        bytes32 predecessor;
        uint256 delay;
        bool isExecutionMode;
    }

    LocalVars public vars;

    function run(bool isExecution, address to) external {
        vars.isExecutionMode = isExecution;
        vm.startBroadcast();
        execute(to);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution, address to) public {
        vars.isExecutionMode = isExecution;
        vm.startBroadcast(broadcastFrom);
        execute(to);
        vm.stopBroadcast();
    }

    function execute(address to) public {
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        vars.feedManager = outputConfig.readAddress(".feedManager");
        vars.feedVerifier = outputConfig.readAddress(".feedVerifier");
        vars.feedRegistryAdapter = outputConfig.readAddress(".feedRegistryAdapter");
        vars.timelock = outputConfig.readAddress(".timelock");

        vars.payloads.push(abi.encodeCall(OwnableUpgradeable(vars.feedManager).transferOwnership, (to)));
        vars.targets.push(vars.feedManager);
        vars.values.push(0);

        vars.payloads.push(abi.encodeCall(OwnableUpgradeable(vars.feedVerifier).transferOwnership, (to)));
        vars.targets.push(vars.feedVerifier);
        vars.values.push(0);

        vars.payloads.push(abi.encodeCall(OwnableUpgradeable(vars.feedRegistryAdapter).transferOwnership, (to)));
        vars.targets.push(vars.feedRegistryAdapter);
        vars.values.push(0);

        address beacon = EOFeedFactoryBeacon(vars.feedRegistryAdapter).getBeacon();
        vars.payloads.push(abi.encodeCall(UpgradeableBeacon(beacon).transferOwnership, (to)));
        vars.targets.push(beacon);
        vars.values.push(0);

        // schedule or execute
        TimelockController timelock = TimelockController(payable(vars.timelock));
        vars.salt = keccak256(abi.encode("transferOwnership"));
        vars.delay = timelock.getMinDelay();

        if (vars.isExecutionMode) {
            timelock.executeBatch(vars.targets, vars.values, vars.payloads, vars.predecessor, vars.salt);
        } else {
            timelock.scheduleBatch(vars.targets, vars.values, vars.payloads, vars.predecessor, vars.salt, vars.delay);
        }
        delete vars;
    }
}
