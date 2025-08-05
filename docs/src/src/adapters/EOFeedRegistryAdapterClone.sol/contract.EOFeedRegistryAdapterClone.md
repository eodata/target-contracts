# EOFeedRegistryAdapterClone

[Git Source](https://github.com/Eoracle/target-contracts/blob/401eb40ea1472e38057aaf0537c1644781be9b1b/src/adapters/EOFeedRegistryAdapterClone.sol)

**Inherits:**
[EOFeedRegistryAdapterBase](/src/adapters/EOFeedRegistryAdapterBase.sol/abstract.EOFeedRegistryAdapterBase.md),
[EOFeedFactoryClone](/src/adapters/factories/EOFeedFactoryClone.sol/abstract.EOFeedFactoryClone.md)

**Author:** eOracle

The adapter of EOFeedManager contract for CL FeedRegistry

_This contract uses the clone pattern for deploying EOFeedAdapter instances_

## Functions

### initialize

Initialize the contract

```solidity
function initialize(
    address feedManager,
    address feedAdapterImplementation,
    address owner
)
    external
    virtual
    override
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
