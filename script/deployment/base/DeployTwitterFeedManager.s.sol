// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { EOTwitterFeedManager } from "src/EOTwitterFeedManager.sol";

abstract contract TwitterFeedManagerDeployer is Script {
    function deployTwitterFeedManager(
        address proxyAdmin,
        address feedVerifier,
        address owner
    )
        internal
        returns (address proxyAddr)
    {
        bytes memory initData = abi.encodeCall(EOTwitterFeedManager.initialize, (feedVerifier, owner));

        proxyAddr = Upgrades.deployTransparentProxy("EOTwitterFeedManager.sol", proxyAdmin, initData);
    }
}

contract DeployTwitterFeedManager is TwitterFeedManagerDeployer {
    function run(address proxyAdmin, address feedVerifier, address owner) external returns (address proxyAddr) {
        return deployTwitterFeedManager(proxyAdmin, feedVerifier, owner);
    }
}
