// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { UpgradeFeedVerifierTimelocked } from "../deployment/timelocked/UpgradeFeedVerifierTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/UpgradeFeedVerifier.s.sol \
    --sig "run(bool,bool,string)" \
    true \
    true \  
    "sepolia" \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract UpgradeFeedVerifier is ExecuteAny {
    using stdJson for string;

    function run(bool send, bool isExecution, string memory chainAlias) external {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        UpgradeFeedVerifierTimelocked upgradeFeedVerifierTimelocked = new UpgradeFeedVerifierTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = upgradeFeedVerifierTimelocked.execute(isExecution, false);
        run(send, multisig, chainAlias, targets, txns);
    }
}
