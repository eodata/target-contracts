// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { UpgradeFeedRegistryAdapterTimelocked } from "../timelocked/UpgradeFeedRegistryAdapterTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/UpgradeFeedRegistryAdapter.s.sol \
    --sig "run(bool,bool,string,string)" \
    true \
    true \  
    "sepolia" \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract UpgradeFeedRegistryAdapter is ExecuteAny {
    using stdJson for string;

    function run(bool send, bool isExecution, string memory chainAlias, string memory seed) external {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        UpgradeFeedRegistryAdapterTimelocked upgradeFeedRegistryAdapterTimelocked =
            new UpgradeFeedRegistryAdapterTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = upgradeFeedRegistryAdapterTimelocked.execute(isExecution, false, seed);
        run(send, multisig, chainAlias, targets, txns);
    }
}
