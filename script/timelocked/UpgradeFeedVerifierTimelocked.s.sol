// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { EOFeedVerifier } from "../../src/EOFeedVerifier.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/UpgradeFeedVerifierTimelocked.s.sol \
    --sig "run(bool,string)" \
    false \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract UpgradeFeedVerifierTimelocked is Script, TimelockBase {
    using stdJson for string;

    bool internal isExecutionMode;
    TimelockController public timelock;

    function run(bool isExecution, string memory seed) external {
        vm.startBroadcast();
        execute(isExecution, true, seed);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution, string memory seed) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, seed);
        vm.stopBroadcast();
    }

    function execute(bool isExecution, bool send, string memory seed) public returns (bytes memory) {
        isExecutionMode = isExecution;

        string memory config = EOJsonUtils.initOutputConfig();
        address proxyAddress = config.readAddress(".feedVerifier");
        timelock = TimelockController(payable(config.readAddress(".timelock")));
        address admin = Upgrades.getAdminAddress(proxyAddress);

        address implementationAddress;
        if (isExecutionMode) {
            implementationAddress = config.readAddress(".feedVerifierImplementation");
        } else {
            implementationAddress = address(new EOFeedVerifier());
            string memory outputConfigJson =
                EOJsonUtils.OUTPUT_CONFIG.serialize("feedVerifierImplementation", implementationAddress);
            EOJsonUtils.writeConfig(outputConfigJson);
        }
        bytes memory initData;
        bytes memory data = abi.encodeCall(
            ProxyAdmin(admin).upgradeAndCall,
            (ITransparentUpgradeableProxy(payable(proxyAddress)), implementationAddress, initData)
        );
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(admin), data, seed);
        return txn;
    }
}
