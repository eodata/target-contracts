# EOFeedAdapter

[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/adapters/EOFeedAdapter.sol)

**Inherits:** [IEOFeedAdapter](/src/adapters/interfaces/IEOFeedAdapter.sol/interface.IEOFeedAdapter.md), Initializable

Price feed adapter contract

## State Variables

### \_feedManager

_Feed manager contract_

```solidity
IEOFeedManager private _feedManager;
```

### \_version

_Feed version_

```solidity
uint256 private _version;
```

### \_description

_Feed description_

```solidity
string private _description;
```

### \_feedId

_Feed id_

```solidity
uint256 private _feedId;
```

### \_inputDecimals

_Decimals of the rate_

```solidity
uint8 private _inputDecimals;
```

### \_outputDecimals

```solidity
uint8 private _outputDecimals;
```

### \_decimalsDiff

```solidity
int256 private _decimalsDiff;
```

### \_\_gap

```solidity
uint256[50] private __gap;
```

## Functions

### constructor

```solidity
constructor();
```

### initialize

Initialize the contract

```solidity
function initialize(
    address feedManager,
    uint256 feedId,
    uint8 inputDecimals,
    uint8 outputDecimals,
    string memory feedDescription,
    uint256 feedVersion
)
    external
    initializer;
```

**Parameters**

| Name              | Type      | Description                              |
| ----------------- | --------- | ---------------------------------------- |
| `feedManager`     | `address` | The feed manager address                 |
| `feedId`          | `uint256` | Feed id                                  |
| `inputDecimals`   | `uint8`   | The input decimal precision of the rate  |
| `outputDecimals`  | `uint8`   | The output decimal precision of the rate |
| `feedDescription` | `string`  | The description of feed                  |
| `feedVersion`     | `uint256` | The version of feed                      |

### getRoundData

Get the price for the round

```solidity
function getRoundData(uint80) external view returns (uint80, int256, uint256, uint256, uint80);
```

**Parameters**

| Name     | Type     | Description |
| -------- | -------- | ----------- |
| `<none>` | `uint80` |             |

**Returns**

| Name     | Type      | Description                                                   |
| -------- | --------- | ------------------------------------------------------------- |
| `<none>` | `uint80`  | roundId The round id                                          |
| `<none>` | `int256`  | answer The price                                              |
| `<none>` | `uint256` | startedAt The timestamp of the start of the round             |
| `<none>` | `uint256` | updatedAt The timestamp of the end of the round               |
| `<none>` | `uint80`  | answeredInRound The round id in which the answer was computed |

### latestRoundData

Get the latest price

```solidity
function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
```

**Returns**

| Name     | Type      | Description                                                   |
| -------- | --------- | ------------------------------------------------------------- |
| `<none>` | `uint80`  | roundId The round id                                          |
| `<none>` | `int256`  | answer The price                                              |
| `<none>` | `uint256` | startedAt The timestamp of the start of the round             |
| `<none>` | `uint256` | updatedAt The timestamp of the end of the round               |
| `<none>` | `uint80`  | answeredInRound The round id in which the answer was computed |

### latestAnswer

Get the latest price

```solidity
function latestAnswer() external view returns (int256);
```

**Returns**

| Name     | Type     | Description      |
| -------- | -------- | ---------------- |
| `<none>` | `int256` | int256 The price |

### latestTimestamp

Get the latest timestamp

```solidity
function latestTimestamp() external view returns (uint256);
```

**Returns**

| Name     | Type      | Description           |
| -------- | --------- | --------------------- |
| `<none>` | `uint256` | uint256 The timestamp |

### getAnswer

Get the price for the round (round is not used, the latest price is returned)

```solidity
function getAnswer(uint256) external view returns (int256);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `<none>` | `uint256` |             |

**Returns**

| Name     | Type     | Description      |
| -------- | -------- | ---------------- |
| `<none>` | `int256` | int256 The price |

### getTimestamp

Get the timestamp for the round (round is not used, the latest timestamp is returned)

```solidity
function getTimestamp(uint256) external view returns (uint256);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `<none>` | `uint256` |             |

**Returns**

| Name     | Type      | Description           |
| -------- | --------- | --------------------- |
| `<none>` | `uint256` | uint256 The timestamp |

### getFeedId

Get the id of the feed

```solidity
function getFeedId() external view returns (uint256);
```

**Returns**

| Name     | Type      | Description         |
| -------- | --------- | ------------------- |
| `<none>` | `uint256` | uint256 The feed id |

### decimals

Get the decimals of the rate

```solidity
function decimals() external view returns (uint8);
```

**Returns**

| Name     | Type    | Description        |
| -------- | ------- | ------------------ |
| `<none>` | `uint8` | uint8 The decimals |

### description

Get the description of the feed

```solidity
function description() external view returns (string memory);
```

**Returns**

| Name     | Type     | Description            |
| -------- | -------- | ---------------------- |
| `<none>` | `string` | string The description |

### version

Get the version of the feed

```solidity
function version() external view returns (uint256);
```

**Returns**

| Name     | Type      | Description         |
| -------- | --------- | ------------------- |
| `<none>` | `uint256` | uint256 The version |

### latestRound

Get the latest round

```solidity
function latestRound() external view returns (uint256);
```

**Returns**

| Name     | Type      | Description                                |
| -------- | --------- | ------------------------------------------ |
| `<none>` | `uint256` | uint256 The round id, eoracle block number |

### \_normalizePrice

```solidity
function _normalizePrice(uint256 price) internal view returns (int256);
```
