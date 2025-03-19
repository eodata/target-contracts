# EoracleConsumerExampleFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/44a7184a934b669887867d9bb70946619d422be3/src/examples/EoracleConsumerExampleFeedManager.sol)

## State Variables

### \_feedManager

```solidity
IEOFeedManager private _feedManager;
```

## Functions

### constructor

```solidity
constructor(address feedManager);
```

### setFeedManager

```solidity
function setFeedManager(address feedManager) external;
```

### getFeedManager

```solidity
function getFeedManager() external view returns (IEOFeedManager);
```

### getPrice

```solidity
function getPrice(uint256 feedId) external view returns (IEOFeedManager.PriceFeed memory);
```

### getPrices

```solidity
function getPrices(uint256[] calldata feedIds) external view returns (IEOFeedManager.PriceFeed[] memory);
```
