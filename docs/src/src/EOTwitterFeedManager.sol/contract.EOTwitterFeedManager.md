# EOTwitterFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/badb6375447660efebd9adbe5de6f290257bb3a9/src/EOTwitterFeedManager.sol)

**Inherits:** [IEOTwitterFeedManager](/src/interfaces/IEOTwitterFeedManager.sol/interface.IEOTwitterFeedManager.md),
OwnableUpgradeable

The EOFeedManager contract is responsible for receiving feed updates from whitelisted publishers. These updates are
verified using the logic in the EOFeedVerifier. Upon successful verification, the feed data is stored in the
EOFeedManager and made available for other smart contracts to read. Only supported feed IDs can be published to the feed
manager.

## State Variables

### \_feeds

_Map of feed id to feed (feed id => Feed)_

```solidity
mapping(uint256 feedId => Feed feed) internal _feeds;
```

### \_whitelistedPublishers

_Map of whitelisted publishers (publisher => is whitelisted)_

```solidity
mapping(address => bool) internal _whitelistedPublishers;
```

### \_supportedFeedIds

_Map of supported feeds, (feed id => is supported)_

```solidity
mapping(uint256 => bool) internal _supportedFeedIds;
```

### \_feedVerifier

_feed verifier contract_

```solidity
IEOFeedVerifier internal _feedVerifier;
```

### \_\_gap

```solidity
uint256[50] private __gap;
```

## Functions

### onlyWhitelisted

_Allows only whitelisted publishers to call the function_

```solidity
modifier onlyWhitelisted();
```

### onlyNonZeroAddress

_Allows only non-zero addresses_

```solidity
modifier onlyNonZeroAddress(address addr);
```

### constructor

```solidity
constructor();
```

### initialize

Initialize the contract with the feed verifier address

_The feed verifier contract must be deployed first_

```solidity
function initialize(address feedVerifier, address owner) external onlyNonZeroAddress(feedVerifier) initializer;
```

**Parameters**

| Name           | Type      | Description                           |
| -------------- | --------- | ------------------------------------- |
| `feedVerifier` | `address` | Address of the feed verifier contract |
| `owner`        | `address` | Owner of the contract                 |

### setFeedVerifier

Set the feed verifier contract address

```solidity
function setFeedVerifier(address feedVerifier) external onlyOwner onlyNonZeroAddress(feedVerifier);
```

**Parameters**

| Name           | Type      | Description                           |
| -------------- | --------- | ------------------------------------- |
| `feedVerifier` | `address` | Address of the feed verifier contract |

### setSupportedFeeds

Set the supported feeds

```solidity
function setSupportedFeeds(uint256[] calldata feedIds, bool[] calldata isSupported) external onlyOwner;
```

**Parameters**

| Name          | Type        | Description                                                |
| ------------- | ----------- | ---------------------------------------------------------- |
| `feedIds`     | `uint256[]` | Array of feed ids                                          |
| `isSupported` | `bool[]`    | Array of booleans indicating whether the feed is supported |

### whitelistPublishers

Set the whitelisted publishers

```solidity
function whitelistPublishers(address[] calldata publishers, bool[] calldata isWhitelisted) external onlyOwner;
```

**Parameters**

| Name            | Type        | Description                                                       |
| --------------- | ----------- | ----------------------------------------------------------------- |
| `publishers`    | `address[]` | Array of publisher addresses                                      |
| `isWhitelisted` | `bool[]`    | Array of booleans indicating whether the publisher is whitelisted |

### updateFeed

Update the price for a feed

```solidity
function updateFeed(
    IEOFeedVerifier.LeafInput calldata input,
    IEOFeedVerifier.VerificationParams calldata vParams
)
    external
    onlyWhitelisted;
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
    external
    onlyWhitelisted;
```

**Parameters**

| Name      | Type                                 | Description                             |
| --------- | ------------------------------------ | --------------------------------------- |
| `inputs`  | `IEOFeedVerifier.LeafInput[]`        | Array of leafs to prove the price feeds |
| `vParams` | `IEOFeedVerifier.VerificationParams` | Verification parameters                 |

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

### getPostsAmount

```solidity
function getPostsAmount(uint256 feedId) external view returns (uint256);
```

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

### getFeedVerifier

Get the feed verifier contract address

```solidity
function getFeedVerifier() external view returns (IEOFeedVerifier);
```

**Returns**

| Name     | Type              | Description                           |
| -------- | ----------------- | ------------------------------------- |
| `<none>` | `IEOFeedVerifier` | Address of the feed verifier contract |

### \_processVerifiedPost

Process the verified rate, check and save it

```solidity
function _processVerifiedPost(bytes memory data, uint256 blockNumber) internal;
```

**Parameters**

| Name          | Type      | Description                                                                      |
| ------------- | --------- | -------------------------------------------------------------------------------- |
| `data`        | `bytes`   | Verified rate data, abi encoded (uint16 feedId, uint256 rate, uint256 timestamp) |
| `blockNumber` | `uint256` | eoracle chain block number                                                       |

## Errors

### FeedNotSupported

```solidity
error FeedNotSupported(uint256 feedId);
```
