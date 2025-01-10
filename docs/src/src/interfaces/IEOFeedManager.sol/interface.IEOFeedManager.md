# IEOFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/badb6375447660efebd9adbe5de6f290257bb3a9/src/interfaces/IEOFeedManager.sol)

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

Whitelist or remove publishers

```solidity
function whitelistPublishers(address[] calldata publishers, bool[] calldata isWhitelisted) external;
```

**Parameters**

| Name            | Type        | Description                                                               |
| --------------- | ----------- | ------------------------------------------------------------------------- |
| `publishers`    | `address[]` | Array of publisher addresses                                              |
| `isWhitelisted` | `bool[]`    | Array of booleans indicating whether each publisher should be whitelisted |

### getLatestPriceFeed

Get the latest price for a feed

```solidity
function getLatestPriceFeed(uint256 feedId) external view returns (PriceFeed memory);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | Feed id     |

**Returns**

| Name     | Type        | Description      |
| -------- | ----------- | ---------------- |
| `<none>` | `PriceFeed` | PriceFeed struct |

### getLatestPriceFeeds

Get the latest price feeds for multiple feeds

```solidity
function getLatestPriceFeeds(uint256[] calldata feedIds) external view returns (PriceFeed[] memory);
```

**Parameters**

| Name      | Type        | Description       |
| --------- | ----------- | ----------------- |
| `feedIds` | `uint256[]` | Array of feed ids |

**Returns**

| Name     | Type          | Description                |
| -------- | ------------- | -------------------------- |
| `<none>` | `PriceFeed[]` | Array of PriceFeed structs |

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

### getFeedDeployer

Get the feed deployer

```solidity
function getFeedDeployer() external view returns (address);
```

**Returns**

| Name     | Type      | Description                  |
| -------- | --------- | ---------------------------- |
| `<none>` | `address` | Address of the feed deployer |

## Events

### RateUpdated

_Event emitted when a price feed is updated_

```solidity
event RateUpdated(uint256 indexed feedId, uint256 rate, uint256 timestamp);
```

**Parameters**

| Name        | Type      | Description          |
| ----------- | --------- | -------------------- |
| `feedId`    | `uint256` | Feed id              |
| `rate`      | `uint256` | Price feed value     |
| `timestamp` | `uint256` | Price feed timestamp |

### SymbolReplay

_Event emitted when a price feed is replayed_

```solidity
event SymbolReplay(uint256 indexed feedId, uint256 rate, uint256 timestamp, uint256 latestTimestamp);
```

**Parameters**

| Name              | Type      | Description                 |
| ----------------- | --------- | --------------------------- |
| `feedId`          | `uint256` | Feed id                     |
| `rate`            | `uint256` | Price feed value            |
| `timestamp`       | `uint256` | Price feed timestamp        |
| `latestTimestamp` | `uint256` | Latest price feed timestamp |

### FeedDeployerSet

_Event emitted when the feed deployer is set_

```solidity
event FeedDeployerSet(address indexed feedDeployer);
```

**Parameters**

| Name           | Type      | Description                  |
| -------------- | --------- | ---------------------------- |
| `feedDeployer` | `address` | Address of the feed deployer |

### FeedVerifierSet

_Event emitted when the feed verifier is set_

```solidity
event FeedVerifierSet(address indexed feedVerifier);
```

**Parameters**

| Name           | Type      | Description                  |
| -------------- | --------- | ---------------------------- |
| `feedVerifier` | `address` | Address of the feed verifier |

### PauserRegistrySet

_Event emitted when the pauser registry is set_

```solidity
event PauserRegistrySet(address indexed pauserRegistry);
```

**Parameters**

| Name             | Type      | Description                    |
| ---------------- | --------- | ------------------------------ |
| `pauserRegistry` | `address` | Address of the pauser registry |

### SupportedFeedsUpdated

_Event emitted when the supported feeds are updated_

```solidity
event SupportedFeedsUpdated(uint256 indexed feedId, bool isSupported);
```

**Parameters**

| Name          | Type      | Description                                      |
| ------------- | --------- | ------------------------------------------------ |
| `feedId`      | `uint256` | Feed id                                          |
| `isSupported` | `bool`    | Boolean indicating whether the feed is supported |

## Structs

### PriceFeed

_Price feed structure_

```solidity
struct PriceFeed {
    uint256 value;
    uint256 timestamp;
    uint256 eoracleBlockNumber;
}
```

**Properties**

| Name                 | Type      | Description                                                                                |
| -------------------- | --------- | ------------------------------------------------------------------------------------------ |
| `value`              | `uint256` | Price feed value                                                                           |
| `timestamp`          | `uint256` | Price feed timestamp (block timestamp in eoracle chain when price feed rate is aggregated) |
| `eoracleBlockNumber` | `uint256` | eoracle block number                                                                       |
