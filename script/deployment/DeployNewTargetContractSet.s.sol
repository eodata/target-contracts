// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { PauserRegistry } from "eigenlayer-contracts/permissions/PauserRegistry.sol";
import { FeedVerifierDeployer } from "./base/DeployFeedVerifier.s.sol";
import { FeedManagerDeployer } from "./base/DeployFeedManager.s.sol";
import { BN256G2 } from "../../src/common/BN256G2.sol";
import { BN256G2v1 } from "../../src/common/BN256G2v1.sol";
import { BLS } from "src/common/BLS.sol";
import { IBN256G2 } from "src/interfaces/IBN256G2.sol";
import { IBLS } from "src/interfaces/IBLS.sol";
import { IEOFeedVerifier } from "src/interfaces/IEOFeedVerifier.sol";
import { EOJsonUtils } from "script/utils/EOJsonUtils.sol";

// Deployment command: FOUNDRY_PROFILE="deployment" forge script script/deployment/DeployNewTargetContractSet.s.sol
// --rpc-url $RPC_URL --private-key $DEPLOYER_PRIVATE_KEY -vvv --slow --verify --broadcast
contract DeployNewTargetContractSet is FeedVerifierDeployer, FeedManagerDeployer {
    using stdJson for string;

    function run() external {
        run(vm.addr(vm.envUint("DEPLOYER_PRIVATE_KEY")));
    }

    function run(address broadcastFrom)
        public
        returns (address bls, address bn256G2, address feedVerifierProxy, address feedManagerProxy)
    {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();

        require(configStructured.targetChainId == block.chainid, "Wrong chain id for this config.");

        require(
            configStructured.eoracleChainId == vm.envUint("EORACLE_CHAIN_ID"), "Wrong EORACLE_CHAIN_ID for this config."
        );

        vm.startBroadcast(broadcastFrom);

        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");

        if (configStructured.usePrecompiledModexp) {
            bn256G2 = address(new BN256G2v1());
        } else {
            bn256G2 = address(new BN256G2());
        }
        EOJsonUtils.OUTPUT_CONFIG.serialize("bn256G2", bn256G2);

        bls = address(new BLS());
        EOJsonUtils.OUTPUT_CONFIG.serialize("bls", bls);

        address pauserRegistry = address(
            new PauserRegistry(configStructured.pauserRegistry.pausers, configStructured.pauserRegistry.unpauser)
        );
        EOJsonUtils.OUTPUT_CONFIG.serialize("pauserRegistry", pauserRegistry);

        /*//////////////////////////////////////////////////////////////////////////
                                        EOFeedVerifier
        //////////////////////////////////////////////////////////////////////////*/
        feedVerifierProxy = deployFeedVerifier(
            timelock,
            broadcastFrom,
            IBLS(bls),
            IBN256G2(bn256G2),
            configStructured.eoracleChainId,
            configStructured.allowedSenders
        );
        EOJsonUtils.OUTPUT_CONFIG.serialize("feedVerifier", feedVerifierProxy);

        address implementationAddress = Upgrades.getImplementationAddress(feedVerifierProxy);
        EOJsonUtils.OUTPUT_CONFIG.serialize("feedVerifierImplementation", implementationAddress);

        /*//////////////////////////////////////////////////////////////////////////
                                        EOFeedManager
        //////////////////////////////////////////////////////////////////////////*/
        feedManagerProxy = deployFeedManager(timelock, feedVerifierProxy, broadcastFrom, pauserRegistry);

        // set feedManager in feedVerifier
        IEOFeedVerifier(feedVerifierProxy).setFeedManager(feedManagerProxy);

        vm.stopBroadcast();
        EOJsonUtils.OUTPUT_CONFIG.serialize("feedManager", feedManagerProxy);

        implementationAddress = Upgrades.getImplementationAddress(feedManagerProxy);
        string memory outputConfigJson =
            EOJsonUtils.OUTPUT_CONFIG.serialize("feedManagerImplementation", implementationAddress);
        EOJsonUtils.writeConfig(outputConfigJson);
    }
}
