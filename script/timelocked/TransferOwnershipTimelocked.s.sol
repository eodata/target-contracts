// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { EOFeedFactoryBeacon } from "../../src/adapters/factories/EOFeedFactoryBeacon.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/TransferOwnershipTimelocked.s.sol \
    --sig "run(bool,address,string)" \
    false \
    <to> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract TransferOwnershipTimelocked is Script, TimelockBase {
    using stdJson for string;

    struct LocalVars {
        address feedManager;
        address feedVerifier;
        address feedRegistryAdapter;
        address timelock;
        address[] targets;
        bytes[] payloads;
        uint256[] values;
        bytes32 predecessor;
        uint256 delay;
    }

    bool public isExecutionMode;

    LocalVars public vars;

    function run(bool isExecution, address to, string memory seed) external {
        vm.startBroadcast();
        execute(isExecution, true, to, seed);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution, address to, string memory seed) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, to, seed);
        vm.stopBroadcast();
    }

    function execute(bool isExecution, bool send, address to, string memory seed) public returns (bytes memory) {
        isExecutionMode = isExecution;

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
        vars.delay = timelock.getMinDelay();

        bytes memory txn =
            callTimelockBatch(timelock, isExecutionMode, send, vars.targets, vars.payloads, vars.values, seed);

        delete vars;
        return txn;
    }
}
