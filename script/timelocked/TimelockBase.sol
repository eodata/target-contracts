// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimelockBase {
    function callTimelock(
        TimelockController timelock,
        bool isExecutionMode,
        bool send,
        address target,
        bytes memory data,
        string memory seed
    )
        internal
        returns (bytes memory)
    {
        bytes32 salt = keccak256(abi.encode(seed));
        bytes32 predecessor;
        uint256 delay = timelock.getMinDelay();

        bytes memory txn = isExecutionMode
            ? abi.encodeCall(timelock.execute, (target, 0, data, predecessor, salt))
            : abi.encodeCall(timelock.schedule, (target, 0, data, predecessor, salt, delay));

        if (send) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = address(timelock).call(txn);
            if (!success) {
                revert("Transaction failed");
            }
        }
        return txn;
    }

    function callTimelockBatch(
        TimelockController timelock,
        bool isExecutionMode,
        bool send,
        address[] memory targets,
        bytes[] memory payloads,
        uint256[] memory values,
        string memory seed
    )
        internal
        returns (bytes memory)
    {
        // schedule or execute
        bytes32 salt = keccak256(abi.encode(seed));
        uint256 delay = timelock.getMinDelay();
        bytes32 predecessor;

        bytes memory txn;
        if (isExecutionMode) {
            txn = abi.encodeCall(timelock.executeBatch, (targets, values, payloads, predecessor, salt));
        } else {
            txn = abi.encodeCall(timelock.scheduleBatch, (targets, values, payloads, predecessor, salt, delay));
        }

        if (send) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = address(timelock).call(txn);
            if (!success) {
                revert("Transaction failed");
            }
        }

        return txn;
    }
}
