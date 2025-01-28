// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IEOFeedManager } from "../interfaces/IEOFeedManager.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IEOFeedAdapter } from "./interfaces/IEOFeedAdapter.sol";
import { IEOFeedRegistryAdapter } from "./interfaces/IEOFeedRegistryAdapter.sol";
import { EOFeedFactoryBase } from "./factories/EOFeedFactoryBase.sol";
import {
    InvalidAddress,
    FeedAlreadyExists,
    BaseQuotePairExists,
    FeedNotSupported,
    FeedDoesNotExist,
    NotFeedDeployer,
    NotLatestRound
} from "../interfaces/Errors.sol";

/**
 * @title EOFeedRegistryAdapterBase
 * @author eOracle
 * @notice base contract which is adapter of EOFeedManager contract for CL FeedManager
 */
abstract contract EOFeedRegistryAdapterBase is OwnableUpgradeable, EOFeedFactoryBase, IEOFeedRegistryAdapter {
    /// @dev Feed manager contract
    IEOFeedManager internal _feedManager;

    /// @dev Map of feed id to feed adapter (feed id => IEOFeedAdapter)
    mapping(uint256 => IEOFeedAdapter) internal _feedAdapters;

    /// @dev Map of feed adapter to enabled status (feed adapter => is enabled)
    mapping(address => bool) internal _feedEnabled;

    /// @dev Map of token addresses to feed ids (base => quote => feed id)
    mapping(address => mapping(address => uint256)) internal _tokenAddressesToFeedIds;

    /* ============ Events ============ */

    /**
     * @dev Event emitted when the feed manager is set
     * @param feedManager The feed manager address
     */
    event FeedManagerSet(address indexed feedManager);

    /**
     * @dev Event emitted when a feed adapter is deployed
     * @param feedId The feed id
     * @param feedAdapter The feed adapter address
     * @param base The base asset address
     * @param quote The quote asset address
     */
    event FeedAdapterDeployed(uint256 indexed feedId, address indexed feedAdapter, address base, address quote);

    /* ============ Modifiers ============ */

    /// @dev Allows only non-zero addresses
    modifier onlyNonZeroAddress(address addr) {
        if (addr == address(0)) revert InvalidAddress();
        _;
    }

    /// @dev Allows only the feed deployer to call the function
    modifier onlyFeedDeployer() {
        if (msg.sender != _feedManager.getFeedDeployer()) revert NotFeedDeployer();
        _;
    }

    /* ============ Constructor ============ */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ============ Initializer ============ */

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
        initializer
        onlyNonZeroAddress(feedManager)
        onlyNonZeroAddress(feedAdapterImplementation)
    {
        __Ownable_init(owner);
        __EOFeedFactory_init(feedAdapterImplementation, owner);
        _feedManager = IEOFeedManager(feedManager);
        emit FeedManagerSet(feedManager);
    }

    /* ============ External Functions ============ */

    /**
     * @notice Set the feed manager
     * @param feedManager The feed manager address
     */
    function setFeedManager(address feedManager) external onlyOwner onlyNonZeroAddress(feedManager) {
        _feedManager = IEOFeedManager(feedManager);
        emit FeedManagerSet(feedManager);
    }

    /**
     * @notice deploy EOFeedAdapter
     * @param base The base asset address
     * @param quote The quote asset address
     * @param feedId The feed id
     * @param feedDescription The description of feed
     * @param inputDecimals The input decimals
     * @param outputDecimals The output decimals
     * @param feedVersion The version of the feed
     * @return IEOFeedAdapter The feed adapter
     */
    // This function can reenter through the external call to the deployed EOFeedAdapter, but the external contract is
    // being deployed by this contract, so it is considered safe
    // slither-disable-next-line reentrancy-no-eth,reentrancy-benign,reentrancy-events
    function deployEOFeedAdapter(
        address base,
        address quote,
        uint256 feedId,
        string calldata feedDescription,
        uint8 inputDecimals,
        uint8 outputDecimals,
        uint256 feedVersion
    )
        external
        onlyFeedDeployer
        returns (IEOFeedAdapter)
    {
        // check if feedId exists in feedManager contract
        if (!_feedManager.isSupportedFeed(feedId)) {
            revert FeedNotSupported(feedId);
        }

        if (address(_feedAdapters[feedId]) != address(0)) {
            revert FeedAlreadyExists();
        }
        if (_tokenAddressesToFeedIds[base][quote] != 0) {
            revert BaseQuotePairExists();
        }
        address feedAdapter = _deployEOFeedAdapter();
        IEOFeedAdapter(feedAdapter).initialize(
            address(_feedManager), feedId, inputDecimals, outputDecimals, feedDescription, feedVersion
        );

        _feedEnabled[feedAdapter] = true;
        _feedAdapters[feedId] = IEOFeedAdapter(feedAdapter);
        _tokenAddressesToFeedIds[base][quote] = feedId;

        emit FeedAdapterDeployed(feedId, feedAdapter, base, quote);

        return IEOFeedAdapter(feedAdapter);
    }

    /**
     * @notice Remove the feedAdapter
     * @param base The base asset address
     * @param quote The quote asset address
     */
    function removeFeedAdapter(address base, address quote) external onlyOwner {
        uint256 feedId = _tokenAddressesToFeedIds[base][quote];
        if (feedId == 0) revert FeedDoesNotExist();
        address feedAdapter = address(_feedAdapters[feedId]);
        delete _feedEnabled[feedAdapter];
        delete _feedAdapters[feedId];
        delete _tokenAddressesToFeedIds[base][quote];
    }

    /**
     * @notice Get the feed manager
     * @return IEOFeedManager The feed manager
     */
    function getFeedManager() external view returns (IEOFeedManager) {
        return _feedManager;
    }

    /**
     * @notice Get the feedAdapter for a given id
     * @param feedId The feed id
     * @return IEOFeedAdapter The feedAdapter
     */
    function getFeedById(uint256 feedId) external view returns (IEOFeedAdapter) {
        return _feedAdapters[feedId];
    }

    /**
     * @notice Get the decimals for a given base/quote pair
     * @dev Calls the decimals function from the feedAdapter itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return uint8 The decimals
     */
    function decimals(address base, address quote) external view returns (uint8) {
        return _feedAdapters[_tokenAddressesToFeedIds[base][quote]].decimals();
    }

    /**
     * @notice Get the description for a given base/quote pair
     * @dev Calls the description function from the feedAdapter itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return string The description
     */
    function description(address base, address quote) external view returns (string memory) {
        return _feedAdapters[_tokenAddressesToFeedIds[base][quote]].description();
    }

    /**
     * @notice Get the version for a given base/quote pair
     * @dev Calls the version function from the feedAdapter itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return uint256 The version
     */
    function version(address base, address quote) external view returns (uint256) {
        return _feedAdapters[_tokenAddressesToFeedIds[base][quote]].version();
    }

    /**
     * @notice Get the latest round data for a given base/quote pair
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return roundId The roundId
     * @return answer The answer
     * @return startedAt The startedAt
     * @return updatedAt The updatedAt
     * @return answeredInRound The answeredInRound
     */
    function latestRoundData(
        address base,
        address quote
    )
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        IEOFeedManager.PriceFeed memory feedData =
            _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]);
        return (
            uint80(feedData.eoracleBlockNumber),
            int256(feedData.value),
            feedData.timestamp,
            feedData.timestamp,
            uint80(feedData.eoracleBlockNumber)
        );
    }

    /**
     * @notice Get the round data for a given base/quote pair
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
     * @dev Reverts if the roundId is not the latest one
     * @param base The base asset address
     * @param quote The quote asset address
     * @param roundId The roundId - only latest round is supported
     * @return roundId The roundId
     * @return answer The answer
     * @return startedAt The startedAt
     * @return updatedAt The updatedAt
     * @return answeredInRound The answeredInRound
     */
    function getRoundData(
        address base,
        address quote,
        uint80 roundId
    )
        external
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        IEOFeedManager.PriceFeed memory feedData =
            _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]);
        if (roundId != feedData.eoracleBlockNumber) revert NotLatestRound();
        return (
            uint80(feedData.eoracleBlockNumber),
            int256(feedData.value),
            feedData.timestamp,
            feedData.timestamp,
            uint80(feedData.eoracleBlockNumber)
        );
    }

    /**
     * @notice Get the latest price for a given base/quote pair
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return int256 The latest price
     */
    function latestAnswer(address base, address quote) external view returns (int256) {
        return int256(_feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]).value);
    }

    /**
     * @notice Get the latest timestamp for a given base/quote pair
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return uint256 The latest timestamp
     */
    function latestTimestamp(address base, address quote) external view returns (uint256) {
        return _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]).timestamp;
    }

    /**
     * @notice Get the answer for a given base/quote pair and round
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
     * @dev Reverts if the roundId is not the latest one
     * @param base The base asset address
     * @param quote The quote asset address
     * @param roundId The roundId - only latest round is supported
     * @return int256 The answer
     */
    function getAnswer(address base, address quote, uint256 roundId) external view returns (int256) {
        IEOFeedManager.PriceFeed memory feedData =
            _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]);
        if (roundId != feedData.eoracleBlockNumber) revert NotLatestRound();
        return int256(feedData.value);
    }

    /**
     * @notice Get the timestamp for a given base/quote pair and round
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
     * @dev Reverts if the roundId is not the latest one
     * @param base The base asset address
     * @param quote The quote asset address
     * @param roundId The roundId - only latest round is supported
     * @return uint256 The timestamp
     */
    function getTimestamp(address base, address quote, uint256 roundId) external view returns (uint256) {
        IEOFeedManager.PriceFeed memory feedData =
            _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]);
        if (roundId != feedData.eoracleBlockNumber) revert NotLatestRound();
        return feedData.timestamp;
    }

    /**
     * @notice Get the feedAdapter for a given base/quote pair
     * @param base The base asset address
     * @param quote The quote asset address
     * @return IEOFeedAdapter The feedAdapter
     */
    function getFeed(address base, address quote) external view returns (IEOFeedAdapter) {
        return _getFeed(base, quote);
    }

    /**
     * @notice Check if a feedAdapter is enabled in the storage of adapter
     * @param feedAdapter The feedAdapter address
     * @return bool True if the feedAdapter is enabled
     */
    function isFeedEnabled(address feedAdapter) external view returns (bool) {
        return _feedEnabled[feedAdapter];
    }

    /**
     * @notice Get the round feedAdapter for a given base/quote pair
     * @dev Reverts if the roundId is not the latest one
     * @param base The base asset address
     * @param quote The quote asset address
     * @param roundId The roundId - only latest round is supported
     * @return IEOFeedAdapter The feedAdapter
     */
    function getRoundFeed(address base, address quote, uint80 roundId) external view returns (IEOFeedAdapter) {
        IEOFeedManager.PriceFeed memory feedData =
            _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]);
        if (roundId != feedData.eoracleBlockNumber) revert NotLatestRound();
        return _getFeed(base, quote);
    }

    /**
     * @notice Get the latest round for a given base/quote pair
     * @dev Calls the getLatestPriceFeed function from the feed manager, not from Feed itself
     * @param base The base asset address
     * @param quote The quote asset address
     * @return uint256 The latest round
     */
    function latestRound(address base, address quote) external view returns (uint256) {
        return _feedManager.getLatestPriceFeed(_tokenAddressesToFeedIds[base][quote]).eoracleBlockNumber;
    }

    /* ============ Internal Functions ============ */

    /**
     * @notice Get the feedAdapter for a given base/quote pair
     * @param base The base asset address
     * @param quote The quote asset address
     * @return IEOFeedAdapter The feedAdapter
     */
    function _getFeed(address base, address quote) internal view returns (IEOFeedAdapter) {
        return _feedAdapters[_tokenAddressesToFeedIds[base][quote]];
    }

    /**
     * @dev Gap for future storage variables in upgradeable contract.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    // slither-disable-next-line unused-state,naming-convention
    // solhint-disable-next-line ordering
    uint256[50] private __gap;
}
