// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedVerifier } from "../../src/EOFeedVerifier.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/SetBLSTimelocked.s.sol \
    --sig "run(bool,address,string)" \
    false \
    <newBLSAddress> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract SetBLSTimelocked is Script, TimelockBase {
    using stdJson for string;

    bool public isExecutionMode;

    EOFeedVerifier public feedVerifier;
    TimelockController public timelock;

    function run(bool isExecution, address newBLS, string memory seed) external {
        vm.startBroadcast();
        execute(isExecution, true, newBLS, seed);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution, address newBLS, string memory seed) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, newBLS, seed);
        vm.stopBroadcast();
    }

    function execute(bool isExecution, bool send, address newBLS, string memory seed) public returns (bytes memory) {
        isExecutionMode = isExecution;
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedVerifier = EOFeedVerifier(outputConfig.readAddress(".feedVerifier"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        bytes memory data = abi.encodeCall(feedVerifier.setBLS, (newBLS));
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(feedVerifier), data, seed);

        return txn;
    }
}
