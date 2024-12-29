// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IEOFeedVerifier } from "./interfaces/IEOFeedVerifier.sol";
import { IEOTwitterFeedManager } from "./interfaces/IEOTwitterFeedManager.sol";
import { InvalidAddress, CallerIsNotWhitelisted, MissingLeafInputs, InvalidInput } from "./interfaces/Errors.sol";

/**
 * @title EOTwitterFeedManager
 * @notice The EOFeedManager contract is responsible for receiving feed updates from whitelisted publishers. These
 * updates are verified using the logic in the EOFeedVerifier. Upon successful verification, the feed data is stored in
 * the EOFeedManager and made available for other smart contracts to read. Only supported feed IDs can be published to
 * the feed manager.
 */
contract EOTwitterFeedManager is IEOTwitterFeedManager, OwnableUpgradeable {
    /// @dev Map of feed id to feed (feed id => Feed)
    mapping(uint32 feedId => Feed feed) internal _feeds;

    /// @dev Map of whitelisted publishers (publisher => is whitelisted)
    mapping(address => bool) internal _whitelistedPublishers;

    /// @dev Map of supported feeds, (feed id => is supported)
    mapping(uint32 => bool) internal _supportedFeedIds;

    /// @dev feed verifier contract
    IEOFeedVerifier internal _feedVerifier;

    error FeedNotSupported(uint32 feedId);

    /// @dev Allows only whitelisted publishers to call the function
    modifier onlyWhitelisted() {
        if (!_whitelistedPublishers[msg.sender]) revert CallerIsNotWhitelisted(msg.sender);
        _;
    }

    /// @dev Allows only non-zero addresses
    modifier onlyNonZeroAddress(address addr) {
        if (addr == address(0)) revert InvalidAddress();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initialize the contract with the feed verifier address
     * @dev The feed verifier contract must be deployed first
     * @param feedVerifier Address of the feed verifier contract
     * @param owner Owner of the contract
     */
    function initialize(address feedVerifier, address owner) external onlyNonZeroAddress(feedVerifier) initializer {
        __Ownable_init(owner);
        _feedVerifier = IEOFeedVerifier(feedVerifier);
    }

    /**
     * @notice Set the feed verifier contract address
     * @param feedVerifier Address of the feed verifier contract
     */
    function setFeedVerifier(address feedVerifier) external onlyOwner onlyNonZeroAddress(feedVerifier) {
        _feedVerifier = IEOFeedVerifier(feedVerifier);
    }

    /**
     * @notice Set the supported feeds
     * @param feedIds Array of feed ids
     * @param isSupported Array of booleans indicating whether the feed is supported
     */
    function setSupportedFeeds(uint32[] calldata feedIds, bool[] calldata isSupported) external onlyOwner {
        if (feedIds.length != isSupported.length) revert InvalidInput();
        for (uint256 i = 0; i < feedIds.length; i++) {
            _supportedFeedIds[feedIds[i]] = isSupported[i];
        }
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    function whitelistPublishers(address[] calldata publishers, bool[] calldata isWhitelisted) external onlyOwner {
        if (publishers.length != isWhitelisted.length) revert InvalidInput();
        for (uint256 i = 0; i < publishers.length; i++) {
            if (publishers[i] == address(0)) revert InvalidAddress();
            _whitelistedPublishers[publishers[i]] = isWhitelisted[i];
        }
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    // Reentrancy is not an issue because _feedVerifier is set by the owner
    // slither-disable-next-line reentrancy-benign,reentrancy-events
    function updateFeed(
        IEOFeedVerifier.LeafInput calldata input,
        IEOFeedVerifier.VerificationParams calldata vParams
    )
        external
        onlyWhitelisted
    {
        bytes memory data = _feedVerifier.verify(input, vParams);
        _processVerifiedPost(data, vParams.blockNumber);
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    // Reentrancy is not an issue because _feedVerifier is set by the owner
    // slither-disable-next-line reentrancy-benign,reentrancy-events
    function updateFeeds(
        IEOFeedVerifier.LeafInput[] calldata inputs,
        IEOFeedVerifier.VerificationParams calldata vParams
    )
        external
        onlyWhitelisted
    {
        if (inputs.length == 0) revert MissingLeafInputs();

        bytes[] memory data = _feedVerifier.batchVerify(inputs, vParams);
        for (uint256 i = 0; i < data.length; i++) {
            _processVerifiedPost(data[i], vParams.blockNumber);
        }
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    function getLatestFeedPost(uint32 feedId) external view returns (Post memory) {
        if (!_supportedFeedIds[feedId]) revert FeedNotSupported(feedId);
        return _feeds[feedId].posts[_feeds[feedId].postIds[_feeds[feedId].postIds.length - 1]];
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    function getFeedPost(uint32 feedId, uint64 postId) external view returns (Post memory) {
        if (!_supportedFeedIds[feedId]) revert FeedNotSupported(feedId);
        return _feeds[feedId].posts[postId];
    }

    function getPostsAmount(uint32 feedId) external view returns (uint256) {
        return _feeds[feedId].postIds.length;
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    function getLatestFeedPosts(uint32 feedId, uint256 latestAmount) external view returns (Post[] memory) {
        if (!_supportedFeedIds[feedId]) revert FeedNotSupported(feedId);
        uint256 postIdsLength = _feeds[feedId].postIds.length;
        if (latestAmount > postIdsLength) revert InvalidInput();
        Post[] memory posts = new Post[](latestAmount);
        for (uint256 i = 0; i < latestAmount; i++) {
            posts[i] = _feeds[feedId].posts[_feeds[feedId].postIds[postIdsLength - i - 1]];
        }
        return posts;
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    function isWhitelistedPublisher(address publisher) external view returns (bool) {
        return _whitelistedPublishers[publisher];
    }

    /**
     * @inheritdoc IEOTwitterFeedManager
     */
    function isSupportedFeed(uint32 feedId) external view returns (bool) {
        return _supportedFeedIds[feedId];
    }

    /**
     * @notice Get the feed verifier contract address
     * @return Address of the feed verifier contract
     */
    function getFeedVerifier() external view returns (IEOFeedVerifier) {
        return _feedVerifier;
    }

    /**
     * @notice Process the verified rate, check and save it
     * @param data Verified rate data, abi encoded (uint16 feedId, uint256 rate, uint256 timestamp)
     * @param blockNumber eoracle chain block number
     */
    function _processVerifiedPost(bytes memory data, uint256 blockNumber) internal {
        LeafData memory leafData = abi.decode(data, (LeafData));
        PostData memory postData = abi.decode(leafData.data, (PostData));
        if (!_supportedFeedIds[leafData.feedId]) revert FeedNotSupported(leafData.feedId);

        Post storage post = _feeds[leafData.feedId].posts[postData.postId];
        if (post.timestampCreated == 0) {
            _feeds[leafData.feedId].postIds.push(postData.postId);
        }
        post.eoracleBlockNumber = blockNumber;
        if (postData.action == PostAction.Creation) {
            PostCreation memory postCreation = abi.decode(postData.content, (PostCreation));
            post.content = postCreation.content;
            post.timestampCreated = postCreation.timestamp;
        } else if (postData.action == PostAction.UpdateContent) {
            PostUpdateContent memory postUpdateContent = abi.decode(postData.content, (PostUpdateContent));
            post.content = postUpdateContent.content;
            post.timestampUpdatedContent = postUpdateContent.timestamp;
        } else if (postData.action == PostAction.UpdateStatistics) {
            PostUpdateStatistics memory postUpdateStatistics = abi.decode(postData.content, (PostUpdateStatistics));
            post.replies = postUpdateStatistics.replies;
            post.bookmarks = postUpdateStatistics.bookmarks;
            post.reposts = postUpdateStatistics.reposts;
            post.likes = postUpdateStatistics.likes;
            post.views = postUpdateStatistics.views;
            post.timestampUpdatedStatistics = postUpdateStatistics.timestamp;
        } else if (postData.action == PostAction.Deletion) {
            PostDeletion memory postDeletion = abi.decode(postData.content, (PostDeletion));
            post.timestampDeleted = postDeletion.timestamp;
        }
        emit FeedPostUpdated(leafData.feedId, postData.postId, post);
    }

    // slither-disable-next-line unused-state,naming-convention
    // solhint-disable-next-line ordering
    uint256[50] private __gap;
}
