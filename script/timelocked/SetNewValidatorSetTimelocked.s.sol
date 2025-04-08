// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedVerifier } from "../../src/EOFeedVerifier.sol";
import { IEOFeedVerifier } from "../../src/interfaces/IEOFeedVerifier.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/SetNewValidatorSetTimelocked.s.sol \
    --sig "run(bool,(address,uint256[2],uint256[4],uint256)[],string)" \
    false \
    <newValidatorSet> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract SetNewValidatorSetTimelocked is Script, TimelockBase {
    using stdJson for string;

    bool public isExecutionMode;

    EOFeedVerifier public feedVerifier;
    TimelockController public timelock;

    function run(bool isExecution, IEOFeedVerifier.Validator[] calldata newValidatorSet, string memory seed) external {
        vm.startBroadcast();
        execute(isExecution, true, newValidatorSet, seed);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(
        address broadcastFrom,
        bool isExecution,
        IEOFeedVerifier.Validator[] calldata newValidatorSet,
        string memory seed
    )
        public
    {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, newValidatorSet, seed);
        vm.stopBroadcast();
    }

    function execute(
        bool isExecution,
        bool send,
        IEOFeedVerifier.Validator[] calldata newValidatorSet,
        string memory seed
    )
        public
        returns (bytes memory)
    {
        isExecutionMode = isExecution;
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedVerifier = EOFeedVerifier(outputConfig.readAddress(".feedVerifier"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        bytes memory data = abi.encodeCall(feedVerifier.setNewValidatorSet, (newValidatorSet));
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(feedVerifier), data, seed);

        return txn;
    }
}
