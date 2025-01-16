# EoracleConsumerExampleFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/badb6375447660efebd9adbe5de6f290257bb3a9/src/examples/EoracleConsumerExampleFeedManager.sol)

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
