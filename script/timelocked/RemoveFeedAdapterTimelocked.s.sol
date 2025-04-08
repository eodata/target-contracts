// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";
import { EOFeedRegistryAdapterBase } from "../../src/adapters/EOFeedRegistryAdapterBase.sol";
import { TimelockBase } from "./TimelockBase.sol";

/*
Usage: (add --broadcast)
forge script script/timelocked/RemoveFeedAdapterTimelocked.s.sol \
    --sig "run(bool,address,address,string)" \
    false \
    <base> \
    <quote> \
    <seed> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract RemoveFeedAdapterTimelocked is Script, TimelockBase {
    using stdJson for string;

    bool public isExecutionMode;

    EOFeedRegistryAdapterBase public feedRegistryAdapter;
    TimelockController public timelock;

    function run(bool isExecution, address base, address quote, string memory seed) external {
        vm.startBroadcast();
        execute(isExecution, true, base, quote, seed);
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution, address base, address quote, string memory seed) public {
        vm.startBroadcast(broadcastFrom);
        execute(isExecution, true, base, quote, seed);
        vm.stopBroadcast();
    }

    function execute(
        bool isExecution,
        bool send,
        address base,
        address quote,
        string memory seed
    )
        public
        returns (bytes memory)
    {
        isExecutionMode = isExecution;
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedRegistryAdapter = EOFeedRegistryAdapterBase(outputConfig.readAddress(".feedRegistryAdapter"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        bytes memory data = abi.encodeCall(feedRegistryAdapter.removeFeedAdapter, (base, quote));
        bytes memory txn = callTimelock(timelock, isExecutionMode, send, address(feedRegistryAdapter), data, seed);

        return txn;
    }
}
