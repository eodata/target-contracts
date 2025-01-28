# EOFeedRegistryAdapterBase

[Git Source](https://github.com/Eoracle/target-contracts/blob/44a7184a934b669887867d9bb70946619d422be3/src/adapters/EOFeedRegistryAdapterBase.sol)

**Inherits:** OwnableUpgradeable,
[EOFeedFactoryBase](/src/adapters/factories/EOFeedFactoryBase.sol/abstract.EOFeedFactoryBase.md),
[IEOFeedRegistryAdapter](/src/adapters/interfaces/IEOFeedRegistryAdapter.sol/interface.IEOFeedRegistryAdapter.md)

**Author:** eOracle

base contract which is adapter of EOFeedManager contract for CL FeedManager

## State Variables

### \_feedManager

_Feed manager contract_

```solidity
IEOFeedManager internal _feedManager;
```

### \_feedAdapters

_Map of feed id to feed adapter (feed id => IEOFeedAdapter)_

```solidity
mapping(uint256 => IEOFeedAdapter) internal _feedAdapters;
```

### \_feedEnabled

_Map of feed adapter to enabled status (feed adapter => is enabled)_

```solidity
mapping(address => bool) internal _feedEnabled;
```

### \_tokenAddressesToFeedIds

_Map of token addresses to feed ids (base => quote => feed id)_

```solidity
mapping(address => mapping(address => uint256)) internal _tokenAddressesToFeedIds;
```

### \_\_gap

_Gap for future storage variables in upgradeable contract. See
https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps_

```solidity
uint256[50] private __gap;
```

## Functions

### onlyNonZeroAddress

_Allows only non-zero addresses_

```solidity
modifier onlyNonZeroAddress(address addr);
```

### onlyFeedDeployer

_Allows only the feed deployer to call the function_

```solidity
modifier onlyFeedDeployer();
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

| Name                        | Type      | Description                            |
| --------------------------- | --------- | -------------------------------------- |
| `feedManager`               | `address` | The feed manager address               |
| `feedAdapterImplementation` | `address` | The feedAdapter implementation address |
| `owner`                     | `address` | Owner of the contract                  |

### setFeedManager

Set the feed manager

```solidity
function setFeedManager(address feedManager) external onlyOwner onlyNonZeroAddress(feedManager);
```

**Parameters**

| Name          | Type      | Description              |
| ------------- | --------- | ------------------------ |
| `feedManager` | `address` | The feed manager address |

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
    onlyFeedDeployer
    returns (IEOFeedAdapter);
```

**Parameters**

| Name              | Type      | Description             |
| ----------------- | --------- | ----------------------- |
| `base`            | `address` | The base asset address  |
| `quote`           | `address` | The quote asset address |
| `feedId`          | `uint256` | The feed id             |
| `feedDescription` | `string`  | The description of feed |
| `inputDecimals`   | `uint8`   | The input decimals      |
| `outputDecimals`  | `uint8`   | The output decimals     |
| `feedVersion`     | `uint256` | The version of the feed |

**Returns**

| Name     | Type             | Description                     |
| -------- | ---------------- | ------------------------------- |
| `<none>` | `IEOFeedAdapter` | IEOFeedAdapter The feed adapter |

### removeFeedAdapter

Remove the feedAdapter

```solidity
function removeFeedAdapter(address base, address quote) external onlyOwner;
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

### getFeedManager

Get the feed manager

```solidity
function getFeedManager() external view returns (IEOFeedManager);
```

**Returns**

| Name     | Type             | Description                     |
| -------- | ---------------- | ------------------------------- |
| `<none>` | `IEOFeedManager` | IEOFeedManager The feed manager |

### getFeedById

Get the feedAdapter for a given id

```solidity
function getFeedById(uint256 feedId) external view returns (IEOFeedAdapter);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | The feed id |

**Returns**

| Name     | Type             | Description                    |
| -------- | ---------------- | ------------------------------ |
| `<none>` | `IEOFeedAdapter` | IEOFeedAdapter The feedAdapter |

### decimals

Get the decimals for a given base/quote pair

_Calls the decimals function from the feedAdapter itself_

```solidity
function decimals(address base, address quote) external view returns (uint8);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type    | Description        |
| -------- | ------- | ------------------ |
| `<none>` | `uint8` | uint8 The decimals |

### description

Get the description for a given base/quote pair

_Calls the description function from the feedAdapter itself_

```solidity
function description(address base, address quote) external view returns (string memory);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type     | Description            |
| -------- | -------- | ---------------------- |
| `<none>` | `string` | string The description |

### version

Get the version for a given base/quote pair

_Calls the version function from the feedAdapter itself_

```solidity
function version(address base, address quote) external view returns (uint256);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type      | Description         |
| -------- | --------- | ------------------- |
| `<none>` | `uint256` | uint256 The version |

### latestRoundData

Get the latest round data for a given base/quote pair

_Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself_

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

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name              | Type      | Description         |
| ----------------- | --------- | ------------------- |
| `roundId`         | `uint80`  | The roundId         |
| `answer`          | `int256`  | The answer          |
| `startedAt`       | `uint256` | The startedAt       |
| `updatedAt`       | `uint256` | The updatedAt       |
| `answeredInRound` | `uint80`  | The answeredInRound |

### getRoundData

Get the round data for a given base/quote pair

_Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself_

_Reverts if the roundId is not the latest one_

```solidity
function getRoundData(
    address base,
    address quote,
    uint80 roundId
)
    external
    view
    returns (uint80, int256, uint256, uint256, uint80);
```

**Parameters**

| Name      | Type      | Description                                  |
| --------- | --------- | -------------------------------------------- |
| `base`    | `address` | The base asset address                       |
| `quote`   | `address` | The quote asset address                      |
| `roundId` | `uint80`  | The roundId - only latest round is supported |

**Returns**

| Name     | Type      | Description                         |
| -------- | --------- | ----------------------------------- |
| `<none>` | `uint80`  | roundId The roundId                 |
| `<none>` | `int256`  | answer The answer                   |
| `<none>` | `uint256` | startedAt The startedAt             |
| `<none>` | `uint256` | updatedAt The updatedAt             |
| `<none>` | `uint80`  | answeredInRound The answeredInRound |

### latestAnswer

Get the latest price for a given base/quote pair

_Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself_

```solidity
function latestAnswer(address base, address quote) external view returns (int256);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type     | Description             |
| -------- | -------- | ----------------------- |
| `<none>` | `int256` | int256 The latest price |

### latestTimestamp

Get the latest timestamp for a given base/quote pair

_Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself_

```solidity
function latestTimestamp(address base, address quote) external view returns (uint256);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type      | Description                  |
| -------- | --------- | ---------------------------- |
| `<none>` | `uint256` | uint256 The latest timestamp |

### getAnswer

Get the answer for a given base/quote pair and round

_Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself_

_Reverts if the roundId is not the latest one_

```solidity
function getAnswer(address base, address quote, uint256 roundId) external view returns (int256);
```

**Parameters**

| Name      | Type      | Description                                  |
| --------- | --------- | -------------------------------------------- |
| `base`    | `address` | The base asset address                       |
| `quote`   | `address` | The quote asset address                      |
| `roundId` | `uint256` | The roundId - only latest round is supported |

**Returns**

| Name     | Type     | Description       |
| -------- | -------- | ----------------- |
| `<none>` | `int256` | int256 The answer |

### getTimestamp

Get the timestamp for a given base/quote pair and round

_Calls the getLatestPriceFeed function from the feed manager, not from feedAdapter itself_

_Reverts if the roundId is not the latest one_

```solidity
function getTimestamp(address base, address quote, uint256 roundId) external view returns (uint256);
```

**Parameters**

| Name      | Type      | Description                                  |
| --------- | --------- | -------------------------------------------- |
| `base`    | `address` | The base asset address                       |
| `quote`   | `address` | The quote asset address                      |
| `roundId` | `uint256` | The roundId - only latest round is supported |

**Returns**

| Name     | Type      | Description           |
| -------- | --------- | --------------------- |
| `<none>` | `uint256` | uint256 The timestamp |

### getFeed

Get the feedAdapter for a given base/quote pair

```solidity
function getFeed(address base, address quote) external view returns (IEOFeedAdapter);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type             | Description                    |
| -------- | ---------------- | ------------------------------ |
| `<none>` | `IEOFeedAdapter` | IEOFeedAdapter The feedAdapter |

### isFeedEnabled

Check if a feedAdapter is enabled in the storage of adapter

```solidity
function isFeedEnabled(address feedAdapter) external view returns (bool);
```

**Parameters**

| Name          | Type      | Description             |
| ------------- | --------- | ----------------------- |
| `feedAdapter` | `address` | The feedAdapter address |

**Returns**

| Name     | Type   | Description                             |
| -------- | ------ | --------------------------------------- |
| `<none>` | `bool` | bool True if the feedAdapter is enabled |

### getRoundFeed

Get the round feedAdapter for a given base/quote pair

_Reverts if the roundId is not the latest one_

```solidity
function getRoundFeed(address base, address quote, uint80 roundId) external view returns (IEOFeedAdapter);
```

**Parameters**

| Name      | Type      | Description                                  |
| --------- | --------- | -------------------------------------------- |
| `base`    | `address` | The base asset address                       |
| `quote`   | `address` | The quote asset address                      |
| `roundId` | `uint80`  | The roundId - only latest round is supported |

**Returns**

| Name     | Type             | Description                    |
| -------- | ---------------- | ------------------------------ |
| `<none>` | `IEOFeedAdapter` | IEOFeedAdapter The feedAdapter |

### latestRound

Get the latest round for a given base/quote pair

_Calls the getLatestPriceFeed function from the feed manager, not from Feed itself_

```solidity
function latestRound(address base, address quote) external view returns (uint256);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type      | Description              |
| -------- | --------- | ------------------------ |
| `<none>` | `uint256` | uint256 The latest round |

### \_getFeed

Get the feedAdapter for a given base/quote pair

```solidity
function _getFeed(address base, address quote) internal view returns (IEOFeedAdapter);
```

**Parameters**

| Name    | Type      | Description             |
| ------- | --------- | ----------------------- |
| `base`  | `address` | The base asset address  |
| `quote` | `address` | The quote asset address |

**Returns**

| Name     | Type             | Description                    |
| -------- | ---------------- | ------------------------------ |
| `<none>` | `IEOFeedAdapter` | IEOFeedAdapter The feedAdapter |

## Events

### FeedManagerSet

_Event emitted when the feed manager is set_

```solidity
event FeedManagerSet(address indexed feedManager);
```

**Parameters**

| Name          | Type      | Description              |
| ------------- | --------- | ------------------------ |
| `feedManager` | `address` | The feed manager address |

### FeedAdapterDeployed

_Event emitted when a feed adapter is deployed_

```solidity
event FeedAdapterDeployed(uint256 indexed feedId, address indexed feedAdapter, address base, address quote);
```

**Parameters**

| Name          | Type      | Description              |
| ------------- | --------- | ------------------------ |
| `feedId`      | `uint256` | The feed id              |
| `feedAdapter` | `address` | The feed adapter address |
| `base`        | `address` | The base asset address   |
| `quote`       | `address` | The quote asset address  |
