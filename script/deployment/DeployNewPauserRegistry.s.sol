// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "script/utils/EOJsonUtils.sol";
import { Script } from "forge-std/Script.sol";
import { PauserRegistry } from "eigenlayer-contracts/permissions/PauserRegistry.sol";

// Deployment command: FOUNDRY_PROFILE="deployment" forge script script/deployment/DeployNewBLS.s.sol
// --rpc-url $RPC_URL --private-key $DEPLOYER_PRIVATE_KEY -vvv --slow --verify --broadcast
contract DeployNewBLS is Script {
    using stdJson for string;

    function run() external {
        execute(msg.sender);
    }

    function execute(address broadcastFrom) public {
        vm.startBroadcast(broadcastFrom);

        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();

        require(configStructured.targetChainId == block.chainid, "Wrong chain id for this config.");

        require(
            configStructured.eoracleChainId == vm.envUint("EORACLE_CHAIN_ID"), "Wrong EORACLE_CHAIN_ID for this config."
        );

        require(configStructured.targetChainId == block.chainid, "Wrong chain id for this config.");

        require(
            configStructured.eoracleChainId == vm.envUint("EORACLE_CHAIN_ID"), "Wrong EORACLE_CHAIN_ID for this config."
        );

        address pauserRegistry = address(
            new PauserRegistry(configStructured.pauserRegistry.pausers, configStructured.pauserRegistry.unpauser)
        );

        EOJsonUtils.initOutputConfig();
        string memory outputConfigJson = EOJsonUtils.OUTPUT_CONFIG.serialize("pauserRegistry", pauserRegistry);
        EOJsonUtils.writeConfig(outputConfigJson);

        vm.stopBroadcast();
    }
}
