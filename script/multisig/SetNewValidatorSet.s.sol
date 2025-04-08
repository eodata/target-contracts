// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { SetNewValidatorSetTimelocked } from "../timelocked/SetNewValidatorSetTimelocked.s.sol";
import { IEOFeedVerifier } from "../../src/interfaces/IEOFeedVerifier.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/SetNewValidatorSet.s.sol \
    --sig "run(bool,bool,string,(address,uint256[2],uint256[4],uint256)[],string)" \
    true \
    true \
    "sepolia" \
    <newValidatorSet> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract SetNewValidatorSet is ExecuteAny {
    using stdJson for string;

    function run(
        bool send,
        bool isExecution,
        string memory chainAlias,
        IEOFeedVerifier.Validator[] calldata newValidatorSet,
        string memory seed
    )
        external
    {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        SetNewValidatorSetTimelocked setNewValidatorSetTimelocked = new SetNewValidatorSetTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = setNewValidatorSetTimelocked.execute(isExecution, false, newValidatorSet, seed);
        run(send, multisig, chainAlias, targets, txns);
    }
}
