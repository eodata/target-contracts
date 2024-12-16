// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "script/utils/EOJsonUtils.sol";

// timelock usage
// cast send <timelock_address> "schedule(address,uint256,bytes,bytes32,bytes32,uint256)"
// <target_address> <value> <data=cast calldata func params> <predecessor> <salt> <delay>

contract DeployTimelock is Script {
    using stdJson for string;

    function run() external {
        run(vm.addr(vm.envUint("PRIVATE_KEY")));
    }

    function run(address broadcastFrom) public {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();
        EOJsonUtils.initOutputConfig();

        vm.startBroadcast(broadcastFrom);
        TimelockController timelock = new TimelockController(
            configStructured.timelock.minDelay,
            configStructured.timelock.proposers,
            configStructured.timelock.executors,
            address(0)
        );

        vm.stopBroadcast();
        string memory outputConfigJson = EOJsonUtils.OUTPUT_CONFIG.serialize("timelock", address(timelock));
        EOJsonUtils.writeConfig(outputConfigJson);
    }
}
