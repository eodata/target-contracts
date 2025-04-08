// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { RemoveFeedAdapterTimelocked } from "../timelocked/RemoveFeedAdapterTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/RemoveFeedAdapter.s.sol \
    --sig "run(bool,bool,string,address,address,string)" \
    true \
    true \
    "sepolia" \
    <base> \
    <quote> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract RemoveFeedAdapter is ExecuteAny {
    using stdJson for string;

    function run(
        bool send,
        bool isExecution,
        string memory chainAlias,
        address base,
        address quote,
        string memory seed
    )
        external
    {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        RemoveFeedAdapterTimelocked removeFeedAdapterTimelocked = new RemoveFeedAdapterTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = removeFeedAdapterTimelocked.execute(isExecution, false, base, quote, seed);
        run(send, multisig, chainAlias, targets, txns);
    }
}
