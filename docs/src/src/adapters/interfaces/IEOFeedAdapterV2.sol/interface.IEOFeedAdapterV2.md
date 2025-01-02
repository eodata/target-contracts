# IEOFeedAdapterV2
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/adapters/interfaces/IEOFeedAdapterV2.sol)

Interface for the EOFeedAdapter contract.

*compatible of AggregatorV3Interface from CL.*


## Functions
### initialize


```solidity
function initialize(
    address feedManager,
    uint16 feedId,
    uint8 inputDecimals,
    uint8 outputDecimals,
    string memory feedDescription,
    uint256 feedVersion
)
    external;
```

### getFeedId


```solidity
function getFeedId() external view returns (uint256);
```

### decimals


```solidity
function decimals() external view returns (uint8);
```

### description


```solidity
function description() external view returns (string memory);
```

### version


```solidity
function version() external view returns (uint256);
```

### getRoundData


```solidity
function getRoundData(uint80 roundId_)
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
```

### latestRoundData


```solidity
function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
```

### latestAnswer


```solidity
function latestAnswer() external view returns (int256);
```

### latestTimestamp


```solidity
function latestTimestamp() external view returns (uint256);
```

### latestRound


```solidity
function latestRound() external view returns (uint256);
```

### getAnswer


```solidity
function getAnswer(uint256 roundId) external view returns (int256);
```

### getTimestamp


```solidity
function getTimestamp(uint256 roundId) external view returns (uint256);
```

