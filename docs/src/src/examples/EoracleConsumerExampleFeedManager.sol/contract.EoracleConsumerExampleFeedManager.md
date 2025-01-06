# EoracleConsumerExampleFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/examples/EoracleConsumerExampleFeedManager.sol)

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
