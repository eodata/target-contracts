# EoracleConsumerExampleFeedAdapter
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/examples/EoracleConsumerExampleFeedAdapter.sol)


## State Variables
### _feedAdapter

```solidity
IEOFeedAdapter private _feedAdapter;
```


## Functions
### constructor


```solidity
constructor(address feedAdapter);
```

### setFeed


```solidity
function setFeed(address feedAdapter) external;
```

### getFeed


```solidity
function getFeed() external view returns (IEOFeedAdapter);
```

### getPrice


```solidity
function getPrice() external view returns (int256 answer);
```

