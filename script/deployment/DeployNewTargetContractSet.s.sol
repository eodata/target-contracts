// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { PauserRegistry } from "eigenlayer-contracts/permissions/PauserRegistry.sol";
import { FeedVerifierDeployer } from "./base/DeployFeedVerifier.s.sol";
import { FeedManagerDeployer } from "./base/DeployFeedManager.s.sol";
import { BLS } from "src/common/BLS.sol";
import { IBLS } from "src/interfaces/IBLS.sol";
import { IEOFeedVerifier } from "src/interfaces/IEOFeedVerifier.sol";
import { EOJsonUtils } from "script/utils/EOJsonUtils.sol";

// Deployment command: FOUNDRY_PROFILE="deployment" forge script script/deployment/DeployNewTargetContractSet.s.sol
// --rpc-url $RPC_URL --private-key $DEPLOYER_PRIVATE_KEY -vvv --slow --verify --broadcast
contract DeployNewTargetContractSet is FeedVerifierDeployer, FeedManagerDeployer {
    using stdJson for string;

    function run() external {
        vm.startBroadcast();
        execute(msg.sender);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom)
        public
        returns (address bls, address feedVerifierProxy, address feedManagerProxy)
    {
        vm.startBroadcast(broadcastFrom);
        (bls, feedVerifierProxy, feedManagerProxy) = execute(broadcastFrom);
        vm.stopBroadcast();
    }

    function execute(address broadcastFrom)
        public
        returns (address bls, address feedVerifierProxy, address feedManagerProxy)
    {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();

        require(configStructured.targetChainId == block.chainid, "Wrong chain id for this config.");

        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");

        bls = address(new BLS());
        EOJsonUtils.OUTPUT_CONFIG.serialize("bls", bls);

        address pauserRegistry = address(
            new PauserRegistry(configStructured.pauserRegistry.pausers, configStructured.pauserRegistry.unpauser)
        );
        EOJsonUtils.OUTPUT_CONFIG.serialize("pauserRegistry", pauserRegistry);

        /*//////////////////////////////////////////////////////////////////////////
                                        EOFeedVerifier
        //////////////////////////////////////////////////////////////////////////*/
        feedVerifierProxy = deployFeedVerifier(timelock, broadcastFrom, IBLS(bls));
        EOJsonUtils.OUTPUT_CONFIG.serialize("feedVerifier", feedVerifierProxy);

        address implementationAddress = Upgrades.getImplementationAddress(feedVerifierProxy);
        EOJsonUtils.OUTPUT_CONFIG.serialize("feedVerifierImplementation", implementationAddress);

        /*//////////////////////////////////////////////////////////////////////////
                                        EOFeedManager
        //////////////////////////////////////////////////////////////////////////*/
        feedManagerProxy = deployFeedManager(timelock, feedVerifierProxy, broadcastFrom, pauserRegistry, broadcastFrom);

        // set feedManager in feedVerifier
        IEOFeedVerifier(feedVerifierProxy).setFeedManager(feedManagerProxy);

        EOJsonUtils.OUTPUT_CONFIG.serialize("feedManager", feedManagerProxy);

        implementationAddress = Upgrades.getImplementationAddress(feedManagerProxy);
        string memory outputConfigJson =
            EOJsonUtils.OUTPUT_CONFIG.serialize("feedManagerImplementation", implementationAddress);
        EOJsonUtils.writeConfig(outputConfigJson);
    }
}
