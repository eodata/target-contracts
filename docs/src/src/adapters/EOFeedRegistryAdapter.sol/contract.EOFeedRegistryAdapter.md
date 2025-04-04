# EOFeedRegistryAdapter

[Git Source](https://github.com/Eoracle/target-contracts/blob/401eb40ea1472e38057aaf0537c1644781be9b1b/src/adapters/EOFeedRegistryAdapter.sol)

**Inherits:**
[EOFeedRegistryAdapterBase](/src/adapters/EOFeedRegistryAdapterBase.sol/abstract.EOFeedRegistryAdapterBase.md),
[EOFeedFactoryBeacon](/src/adapters/factories/EOFeedFactoryBeacon.sol/abstract.EOFeedFactoryBeacon.md)

**Author:** eOracle

The adapter of EOFeedManager contract for CL FeedRegistry, uses the beacon

_This contract inherits EOFeedFactoryBeacon, uses the beacon proxy pattern for deploying EOFeedAdapter instances_

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
