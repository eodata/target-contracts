// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { TimelockController } from "openzeppelin-contracts/contracts/governance/TimelockController.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

// usage:
// forge script script/timelocked/CancelTimelockedTransaction.s.sol:CancelTimelockedTransaction
// <transactionId>
// --sig 'run(bool)'
// --rpc-url $RPC_URL
// --broadcast
// --private-key $CANCELER_PRIVATE_KEY

contract CancelTimelockedTransaction is Script {
    using stdJson for string;

    function run(bytes32 transactionId) external {
        vm.startBroadcast();
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        TimelockController timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));
        timelock.cancel(transactionId);
        vm.stopBroadcast();
    }
}
