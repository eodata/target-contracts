# EOFeedRegistryAdapterBase
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/adapters/EOFeedRegistryAdapterBase.sol)

**Inherits:**
OwnableUpgradeable, [EOFeedFactoryBase](/src/adapters/factories/EOFeedFactoryBase.sol/abstract.EOFeedFactoryBase.md), [IEOFeedRegistryAdapter](/src/adapters/interfaces/IEOFeedRegistryAdapter.sol/interface.IEOFeedRegistryAdapter.md)

base contract which is adapter of EOFeedManager contract for CL FeedManager


## State Variables
### _feedManager

```solidity
IEOFeedManager internal _feedManager;
```


### _feedAdapters

```solidity
mapping(uint256 => IEOFeedAdapter) internal _feedAdapters;
```


### _feedEnabled

```solidity
mapping(address => bool) internal _feedEnabled;
```


### _tokenAddressesToFeedIds

```solidity
mapping(address => mapping(address => uint256)) internal _tokenAddressesToFeedIds;
```


### __gap

```solidity
uint256[50] private __gap;
```


## Functions
### onlyNonZeroAddress


```solidity
modifier onlyNonZeroAddress(address addr);
```

### constructor


```solidity
constructor();
```

### initialize

Initialize the contract


```solidity
function initialize(
    address feedManager,
    address feedAdapterImplementation,
    address owner
)
    external
    initializer
    onlyNonZeroAddress(feedManager)
    onlyNonZeroAddress(feedAdapterImplementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedManager`|`address`|The feed manager address|
|`feedAdapterImplementation`|`address`|The feedAdapter implementation address|
|`owner`|`address`|Owner of the contract|


### setFeedManager

Set the feed manager


```solidity
function setFeedManager(address feedManager) external onlyOwner onlyNonZeroAddress(feedManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedManager`|`address`|The feed manager address|


### deployEOFeedAdapter

deploy EOFeedAdapter


```solidity
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
    onlyOwner
    returns (IEOFeedAdapter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|
|`feedId`|`uint256`|The feed id|
|`feedDescription`|`string`|The description of feed|
|`inputDecimals`|`uint8`|The input decimals|
|`outputDecimals`|`uint8`|The output decimals|
|`feedVersion`|`uint256`|The version of the feed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IEOFeedAdapter`|IEOFeedAdapter The feed adapter|


### removeFeedAdapter

Remove the feedAdapter


```solidity
function removeFeedAdapter(address base, address quote) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|


### getFeedManager

Get the feed manager


```solidity
function getFeedManager() external view returns (IEOFeedManager);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IEOFeedManager`|IEOFeedManager The feed manager|


### getFeedById

Get the feedAdapter for a given id


```solidity
function getFeedById(uint256 feedId) external view returns (IEOFeedAdapter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedId`|`uint256`|The feed id|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IEOFeedAdapter`|IEOFeedAdapter The feedAdapter|


### decimals

Get the decimals for a given base/quote pair

*Calls the decimals function from the feedAdapter itself*


```solidity
function decimals(address base, address quote) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|uint8 The decimals|


### description

Get the description for a given base/quote pair

*Calls the description function from the feedAdapter itself*


```solidity
function description(address base, address quote) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|string The description|


### version

Get the version for a given base/quote pair

*Calls the version function from the feedAdapter itself*


```solidity
function version(address base, address quote) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The version|


### latestRoundData

Get the latest round data for a given base/quote pair

*Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself*


```solidity
function latestRoundData(
    address base,
    address quote
)
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint80`|The roundId|
|`answer`|`int256`|The answer|
|`startedAt`|`uint256`|The startedAt|
|`updatedAt`|`uint256`|The updatedAt|
|`answeredInRound`|`uint80`|The answeredInRound|


### getRoundData

Get the round data for a given base/quote pair

*Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
currently the roundId is not used and latest round is returned*


```solidity
function getRoundData(
    address base,
    address quote,
    uint80
)
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|
|`<none>`|`uint80`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`roundId`|`uint80`|The roundId|
|`answer`|`int256`|The answer|
|`startedAt`|`uint256`|The startedAt|
|`updatedAt`|`uint256`|The updatedAt|
|`answeredInRound`|`uint80`|The answeredInRound|


### latestAnswer

Get the latest price for a given base/quote pair

*Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself*


```solidity
function latestAnswer(address base, address quote) external view override returns (int256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|int256 The latest price|


### latestTimestamp

Get the latest timestamp for a given base/quote pair

*Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself*


```solidity
function latestTimestamp(address base, address quote) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The latest timestamp|


### getAnswer

Get the answer for a given base/quote pair and round

*Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
currently the roundId is not used and latest answer is returned*


```solidity
function getAnswer(address base, address quote, uint256) external view returns (int256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|
|`<none>`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|int256 The answer|


### getTimestamp

Get the timestamp for a given base/quote pair and round

*Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself
currently the roundId is not used and latest timestamp is returned*


```solidity
function getTimestamp(address base, address quote, uint256) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|
|`<none>`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The timestamp|


### getFeed

Get the feedAdapter for a given base/quote pair


```solidity
function getFeed(address base, address quote) external view override returns (IEOFeedAdapter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IEOFeedAdapter`|IEOFeedAdapter The feedAdapter|


### isFeedEnabled

Check if a feedAdapter is enabled in the storage of adapter


```solidity
function isFeedEnabled(address feedAdapter) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedAdapter`|`address`|The feedAdapter address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool True if the feedAdapter is enabled|


### getRoundFeed

Get the round feedAdapter for a given base/quote pair


```solidity
function getRoundFeed(address base, address quote, uint80) external view returns (IEOFeedAdapter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|
|`<none>`|`uint80`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IEOFeedAdapter`|IEOFeedAdapter The feedAdapter|


### latestRound

Get the latest round for a given base/quote pair

*Calls the getLatestPriceFeed function from the feed manager, not from Feed itself
currently the roundId is not used and 0 is returned*


```solidity
function latestRound(address base, address quote) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256 The latest round|


### _getFeed

Get the feedAdapter for a given base/quote pair


```solidity
function _getFeed(address base, address quote) internal view returns (IEOFeedAdapter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`base`|`address`|The base asset address|
|`quote`|`address`|The quote asset address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IEOFeedAdapter`|IEOFeedAdapter The feedAdapter|


## Events
### FeedManagerSet

```solidity
event FeedManagerSet(address indexed feedManager);
```

### FeedAdapterDeployed

```solidity
event FeedAdapterDeployed(uint256 indexed feedId, address indexed feedAdapter, address base, address quote);
```

