// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IEOFeedVerifier } from "./IEOFeedVerifier.sol";

interface IEOTwitterFeedManager {
    struct Feed {
        mapping(uint64 postId => Post) posts;
        uint64[] postIds;
    }

    struct Post {
        uint32 timestampCreated;
        uint32 timestampUpdatedContent;
        uint32 timestampUpdatedStatistics;
        uint32 timestampDeleted;
        uint32 replies; // 4 bytes
        uint32 bookmarks; // 4 bytes
        uint32 reposts; // 4 bytes
        uint32 likes; // 4 bytes
        uint32 views; // 4 bytes
        string content;
        uint256 eoracleBlockNumber;
    }

    struct LeafData {
        uint32 feedId; // 32 bytes
        bytes data; // encoded Post
    }

    struct PostData {
        uint64 postId;
        PostAction action; // 4 bytes
        bytes content; // encoded Post
    }

    enum PostAction {
        Creation,
        UpdateContent,
        UpdateStatistics,
        Deletion
    }

    struct PostCreation {
        string content;
        uint32 timestamp; // 4 bytes - timestamp of the post creation
    }

    struct PostUpdateContent {
        string content;
        uint32 timestamp; // 4 bytes - timestamp of the content update
    }

    struct PostUpdateStatistics {
        uint32 replies; // 4 bytes
        uint32 bookmarks; // 4 bytes
        uint32 reposts; // 4 bytes
        uint32 likes; // 4 bytes
        uint32 views; // 4 bytes
        uint32 timestamp; // 4 bytes - timestamp of the fetched statistics
    }

    struct PostDeletion {
        uint32 timestamp; // 4 bytes - timestamp of the post deletion
    }

    /**
     * @dev Event emitted when a feed post is updated
     * @param feedId Feed id
     * @param postId Post id
     * @param post Post data
     */
    event FeedPostUpdated(uint32 indexed feedId, uint64 indexed postId, Post post);

    /**
     * @notice Update the price for a feed
     * @param input A merkle leaf containing price data and its merkle proof
     * @param vParams Verification parameters
     */
    function updateFeed(
        IEOFeedVerifier.LeafInput calldata input,
        IEOFeedVerifier.VerificationParams calldata vParams
    )
        external;

    /**
     * @notice Update the price for multiple feeds
     * @param inputs Array of leafs to prove the price feeds
     * @param vParams Verification parameters
     */
    function updateFeeds(
        IEOFeedVerifier.LeafInput[] calldata inputs,
        IEOFeedVerifier.VerificationParams calldata vParams
    )
        external;

    /**
     * @notice Set the whitelisted publishers
     * @param publishers Array of publisher addresses
     * @param isWhitelisted Array of booleans indicating whether the publisher is whitelisted
     */
    function whitelistPublishers(address[] memory publishers, bool[] memory isWhitelisted) external;

    /**
     * @notice Get the latest feed post
     * @param feedId Feed id
     * @return Post struct
     */
    function getLatestFeedPost(uint32 feedId) external view returns (Post memory);

    /**
     * @notice Get the feed post
     * @param feedId Feed id
     * @param postId Post id
     * @return Post struct
     */
    function getFeedPost(uint32 feedId, uint64 postId) external view returns (Post memory);

    /**
     * @notice Get several(latestAmount) latest feed posts
     * @param feedId Feed id
     * @param latestAmount Amount of latest posts to get
     * @return Array of Post structs
     */
    function getLatestFeedPosts(uint32 feedId, uint256 latestAmount) external view returns (Post[] memory);

    /**
     * @notice Check if a publisher is whitelisted
     * @param publisher Address of the publisher
     * @return Boolean indicating whether the publisher is whitelisted
     */
    function isWhitelistedPublisher(address publisher) external view returns (bool);

    /**
     * @notice Check if a feed is supported
     * @param feedId feed Id to check
     * @return Boolean indicating whether the feed is supported
     */
    function isSupportedFeed(uint32 feedId) external view returns (bool);
}
