# IEOFeedManager
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/interfaces/IEOFeedManager.sol)


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

|Name|Type|Description|
|----|----|-----------|
|`input`|`IEOFeedVerifier.LeafInput`|A merkle leaf containing price data and its merkle proof|
|`vParams`|`IEOFeedVerifier.VerificationParams`|Verification parameters|


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

|Name|Type|Description|
|----|----|-----------|
|`inputs`|`IEOFeedVerifier.LeafInput[]`|Array of leafs to prove the price feeds|
|`vParams`|`IEOFeedVerifier.VerificationParams`|Verification parameters|


### whitelistPublishers

Whitelist or remove publishers


```solidity
function whitelistPublishers(address[] calldata publishers, bool[] calldata isWhitelisted) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publishers`|`address[]`|Array of publisher addresses|
|`isWhitelisted`|`bool[]`|Array of booleans indicating whether each publisher should be whitelisted|


### getLatestPriceFeed

Get the latest price for a feed


```solidity
function getLatestPriceFeed(uint256 feedId) external view returns (PriceFeed memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedId`|`uint256`|Feed id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PriceFeed`|PriceFeed struct|


### getLatestPriceFeeds

Get the latest price feeds for multiple feeds


```solidity
function getLatestPriceFeeds(uint256[] calldata feedIds) external view returns (PriceFeed[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedIds`|`uint256[]`|Array of feed ids|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PriceFeed[]`|Array of PriceFeed structs|


### isWhitelistedPublisher

Check if a publisher is whitelisted


```solidity
function isWhitelistedPublisher(address publisher) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`publisher`|`address`|Address of the publisher|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Boolean indicating whether the publisher is whitelisted|


### isSupportedFeed

Check if a feed is supported


```solidity
function isSupportedFeed(uint256 feedId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedId`|`uint256`|feed Id to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Boolean indicating whether the feed is supported|


## Events
### RateUpdated
*Event emitted when a price feed is updated*


```solidity
event RateUpdated(uint256 indexed feedId, uint256 rate, uint256 timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedId`|`uint256`|Feed id|
|`rate`|`uint256`|Price feed value|
|`timestamp`|`uint256`|Price feed timestamp|

### SymbolReplay
*Event emitted when a price feed is replayed*


```solidity
event SymbolReplay(uint256 indexed feedId, uint256 rate, uint256 timestamp, uint256 latestTimestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedId`|`uint256`|Feed id|
|`rate`|`uint256`|Price feed value|
|`timestamp`|`uint256`|Price feed timestamp|
|`latestTimestamp`|`uint256`|Latest price feed timestamp|

## Structs
### PriceFeed
*Price feed structure*


```solidity
struct PriceFeed {
    uint256 value;
    uint256 timestamp;
    uint256 eoracleBlockNumber;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`value`|`uint256`|Price feed value|
|`timestamp`|`uint256`|Price feed timestamp (block timestamp in eoracle chain when price feed rate is aggregated)|
|`eoracleBlockNumber`|`uint256`|eoracle block number|

