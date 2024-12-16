// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { EOFeedManager } from "src/EOFeedManager.sol";

abstract contract FeedManagerDeployer is Script {
    function deployFeedManager(
        address proxyAdmin,
        address feedVerifier,
        address owner,
        address pauserRegistry
    )
        internal
        returns (address proxyAddr)
    {
        bytes memory initData = abi.encodeCall(EOFeedManager.initialize, (feedVerifier, owner, pauserRegistry));

        proxyAddr = Upgrades.deployTransparentProxy("EOFeedManager.sol", proxyAdmin, initData);
    }
}

contract DeployFeedManager is FeedManagerDeployer {
    function run(
        address proxyAdmin,
        address feedVerifier,
        address owner,
        address pauserRegistry
    )
        external
        returns (address proxyAddr)
    {
        return deployFeedManager(proxyAdmin, feedVerifier, owner, pauserRegistry);
    }
}
