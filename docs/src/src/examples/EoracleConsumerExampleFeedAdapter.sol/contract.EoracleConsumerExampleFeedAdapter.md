# EoracleConsumerExampleFeedAdapter

[Git Source](https://github.com/Eoracle/target-contracts/blob/401eb40ea1472e38057aaf0537c1644781be9b1b/src/examples/EoracleConsumerExampleFeedAdapter.sol)

## State Variables

### \_feedAdapter

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
