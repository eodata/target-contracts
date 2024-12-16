// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { stdJson } from "forge-std/Script.sol";
import { ExecuteAny } from "./ExecuteAny.s.sol";
import { TransferOwnershipTimelocked } from "../deployment/timelocked/TransferOwnershipTimelocked.s.sol";
import { EOJsonUtils } from "../utils/EOJsonUtils.sol";

/*
Usage: (add --broadcast)
forge script script/multisig/TransferOwnership.s.sol \
    --sig "run(bool,bool,string,address)" \
    true \
    true \  
    "sepolia" \
    <to> \
    --rpc-url $RPC_URL \
    -vvvv
*/
contract TransferOwnership is ExecuteAny {
    using stdJson for string;

    function run(bool send, bool isExecution, string memory chainAlias, address to) external {
        string memory outputConfig = EOJsonUtils.initOutputConfig();
        address timelock = outputConfig.readAddress(".timelock");
        address multisig = outputConfig.readAddress(".multisig");

        TransferOwnershipTimelocked transferOwnershipTimelocked = new TransferOwnershipTimelocked();
        address[] memory targets = new address[](1);
        targets[0] = timelock;
        bytes[] memory txns = new bytes[](1);
        txns[0] = transferOwnershipTimelocked.execute(isExecution, false, to);
        run(send, multisig, chainAlias, targets, txns);
    }
}
