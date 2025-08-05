// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { ResetFeedTimestampsTimelocked } from "../timelocked/ResetFeedTimestampsTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/ResetFeedTimestamps.s.sol \
    --sig "run(bool,bool,string,uint256[],string)" \
    true \
    true \
    "sepolia" \
    <feedIds> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract ResetFeedTimestamps is ExecuteAny {
    using stdJson for string;

    function run(
        bool send,
        bool isExecution,
        string memory chainAlias,
        uint256[] calldata feedIds,
        string memory seed
    )
        external
    {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        ResetFeedTimestampsTimelocked resetFeedTimestampsTimelocked = new ResetFeedTimestampsTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = resetFeedTimestampsTimelocked.execute(isExecution, false, feedIds, seed);
        run(send, multisig, chainAlias, targets, txns);
    }
}
