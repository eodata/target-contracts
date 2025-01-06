# EoracleConsumerExampleFeedRegistryAdapter

[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/examples/EoracleConsumerExampleFeedRegistryAdapter.sol)

## State Variables

### \_feedRegistryAdapter

```solidity
IEOFeedRegistryAdapter private _feedRegistryAdapter;
```

## Functions

### constructor

```solidity
constructor(address feedRegistryAdapter);
```

### setFeedRegistryAdapter

```solidity
function setFeedRegistryAdapter(address feedRegistryAdapter) external;
```

### getFeedRegistryAdapter

```solidity
function getFeedRegistryAdapter() external view returns (IEOFeedRegistryAdapter);
```

### getEthUsdPrice

```solidity
function getEthUsdPrice() external view returns (int256);
```

### getPrice

```solidity
function getPrice(address base, address quote) external view returns (int256);
```
