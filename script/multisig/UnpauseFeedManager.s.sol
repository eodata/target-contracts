// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../src/EOFeedManager.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/UnpauseFeedManager.s.sol \
    --sig "run(bool,string)" \
    true \
    "sepolia" \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract UnpauseFeedManager is ExecuteAny {
    using stdJson for string;

    function run(bool send, string memory chainAlias) external {
        string memory outputConfig = EOJsonUtils.getOutputConfig();
        EOFeedManager feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        address multisig = outputConfig.readAddress(".multisig");

        address[] memory targets = new address[](1);
        targets[0] = address(feedManager);
        bytes[] memory txns = new bytes[](1);
        txns[0] = abi.encodeCall(feedManager.unpause, ());
        run(send, multisig, chainAlias, targets, txns);
    }
}
