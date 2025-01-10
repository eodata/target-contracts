# IEOTwitterFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/badb6375447660efebd9adbe5de6f290257bb3a9/src/interfaces/IEOTwitterFeedManager.sol)

## Functions

### updateFeed

Update the price for a feed

```solidity
function updateFeed(
    IEOFeedVerifier.LeafInput calldata input,
    IEOFeedVerifier.VerificationParams calldata vParams
)
    external;
```

**Parameters**

| Name      | Type                                 | Description                                              |
| --------- | ------------------------------------ | -------------------------------------------------------- |
| `input`   | `IEOFeedVerifier.LeafInput`          | A merkle leaf containing price data and its merkle proof |
| `vParams` | `IEOFeedVerifier.VerificationParams` | Verification parameters                                  |

### updateFeeds

Update the price for multiple feeds

```solidity
function updateFeeds(
    IEOFeedVerifier.LeafInput[] calldata inputs,
    IEOFeedVerifier.VerificationParams calldata vParams
)
    external;
```

**Parameters**

| Name      | Type                                 | Description                             |
| --------- | ------------------------------------ | --------------------------------------- |
| `inputs`  | `IEOFeedVerifier.LeafInput[]`        | Array of leafs to prove the price feeds |
| `vParams` | `IEOFeedVerifier.VerificationParams` | Verification parameters                 |

### whitelistPublishers

Set the whitelisted publishers

```solidity
function whitelistPublishers(address[] memory publishers, bool[] memory isWhitelisted) external;
```

**Parameters**

| Name            | Type        | Description                                                       |
| --------------- | ----------- | ----------------------------------------------------------------- |
| `publishers`    | `address[]` | Array of publisher addresses                                      |
| `isWhitelisted` | `bool[]`    | Array of booleans indicating whether the publisher is whitelisted |

### getLatestFeedPost

Get the latest feed post

```solidity
function getLatestFeedPost(uint256 feedId) external view returns (Post memory);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | Feed id     |

**Returns**

| Name     | Type   | Description |
| -------- | ------ | ----------- |
| `<none>` | `Post` | Post struct |

### getFeedPost

Get the feed post

```solidity
function getFeedPost(uint256 feedId, uint64 postId) external view returns (Post memory);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | Feed id     |
| `postId` | `uint64`  | Post id     |

**Returns**

| Name     | Type   | Description |
| -------- | ------ | ----------- |
| `<none>` | `Post` | Post struct |

### getLatestFeedPosts

Get several(latestAmount) latest feed posts

```solidity
function getLatestFeedPosts(uint256 feedId, uint256 latestAmount) external view returns (Post[] memory);
```

**Parameters**

| Name           | Type      | Description                   |
| -------------- | --------- | ----------------------------- |
| `feedId`       | `uint256` | Feed id                       |
| `latestAmount` | `uint256` | Amount of latest posts to get |

**Returns**

| Name     | Type     | Description           |
| -------- | -------- | --------------------- |
| `<none>` | `Post[]` | Array of Post structs |

### isWhitelistedPublisher

Check if a publisher is whitelisted

```solidity
function isWhitelistedPublisher(address publisher) external view returns (bool);
```

**Parameters**

| Name        | Type      | Description              |
| ----------- | --------- | ------------------------ |
| `publisher` | `address` | Address of the publisher |

**Returns**

| Name     | Type   | Description                                             |
| -------- | ------ | ------------------------------------------------------- |
| `<none>` | `bool` | Boolean indicating whether the publisher is whitelisted |

### isSupportedFeed

Check if a feed is supported

```solidity
function isSupportedFeed(uint256 feedId) external view returns (bool);
```

**Parameters**

| Name     | Type      | Description      |
| -------- | --------- | ---------------- |
| `feedId` | `uint256` | feed Id to check |

**Returns**

| Name     | Type   | Description                                      |
| -------- | ------ | ------------------------------------------------ |
| `<none>` | `bool` | Boolean indicating whether the feed is supported |

## Events

### FeedPostUpdated

_Event emitted when a feed post is updated_

```solidity
event FeedPostUpdated(uint256 indexed feedId, uint64 indexed postId, Post post);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | Feed id     |
| `postId` | `uint64`  | Post id     |
| `post`   | `Post`    | Post data   |

## Structs

### Feed

```solidity
struct Feed {
    mapping(uint64 postId => Post) posts;
    uint64[] postIds;
}
```

### Post

```solidity
struct Post {
    uint256 eoracleBlockNumber;
    string content;
    uint32 timestampCreated;
    uint32 timestampUpdatedContent;
    uint32 timestampUpdatedStatistics;
    uint32 replies;
    uint32 bookmarks;
    uint32 reposts;
    uint32 likes;
    uint32 views;
    uint32 timestampDeleted;
}
```

### LeafData

```solidity
struct LeafData {
    uint256 feedId;
    bytes data;
}
```

### PostData

```solidity
struct PostData {
    bytes content;
    uint64 postId;
    PostAction action;
}
```

### PostCreation

```solidity
struct PostCreation {
    string content;
    uint32 timestamp;
}
```

### PostUpdateContent

```solidity
struct PostUpdateContent {
    string content;
    uint32 timestamp;
}
```

### PostUpdateStatistics

```solidity
struct PostUpdateStatistics {
    uint32 replies;
    uint32 bookmarks;
    uint32 reposts;
    uint32 likes;
    uint32 views;
    uint32 timestamp;
}
```

### PostDeletion

```solidity
struct PostDeletion {
    uint32 timestamp;
}
```

## Enums

### PostAction

```solidity
enum PostAction {
    Creation,
    UpdateContent,
    UpdateStatistics,
    Deletion
}
```
