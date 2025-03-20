// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IEOFeedManager } from "../interfaces/IEOFeedManager.sol";
import { EOFeedFactoryClone } from "./factories/EOFeedFactoryClone.sol";
import { EOFeedRegistryAdapterBase } from "./EOFeedRegistryAdapterBase.sol";

/**
 * @title EOFeedRegistryAdapterClone
 * @author eOracle
 * @notice The adapter of EOFeedManager contract for CL FeedRegistry
 * @dev This contract uses the clone pattern for deploying EOFeedAdapter instances
 */
// solhint-disable no-empty-blocks

contract EOFeedRegistryAdapterClone is EOFeedRegistryAdapterBase, EOFeedFactoryClone {
    /**
     * @notice Initialize the contract
     * @param feedManager The feed manager address
     * @param feedAdapterImplementation The feedAdapter implementation address
     * @param owner Owner of the contract
     */
    function initialize(
        address feedManager,
        address feedAdapterImplementation,
        address owner
    )
        external
        virtual
        override
        initializer
        onlyNonZeroAddress(feedManager)
        onlyNonZeroAddress(feedAdapterImplementation)
    {
        __Ownable_init(owner);
        __EOFeedFactory_init(feedAdapterImplementation, owner);
        _feedManager = IEOFeedManager(feedManager);
        emit FeedManagerSet(feedManager);
    }
}
