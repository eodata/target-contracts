// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { WhitelistPublishersTimelocked } from "../timelocked/WhitelistPublishersTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/WhitelistPublishers.s.sol \
    --sig "run(bool,bool,string)" \
    true \
    true \
    "sepolia" \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract WhitelistPublishers is ExecuteAny {
    using stdJson for string;

    function run(bool send, bool isExecution, string memory chainAlias) external {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        WhitelistPublishersTimelocked whitelistPublishersTimelocked = new WhitelistPublishersTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = whitelistPublishersTimelocked.execute(isExecution, false);
        run(send, multisig, chainAlias, targets, txns);
    }
}
