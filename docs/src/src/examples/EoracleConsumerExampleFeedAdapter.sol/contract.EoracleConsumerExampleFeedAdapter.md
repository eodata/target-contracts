# EoracleConsumerExampleFeedAdapter

[Git Source](https://github.com/Eoracle/target-contracts/blob/6aa770eda8f0c2ec3d6b8a6ee534d020a26eb2db/src/examples/EoracleConsumerExampleFeedAdapter.sol)

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
