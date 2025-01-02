# EOFeedFactoryBeacon
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/adapters/factories/EOFeedFactoryBeacon.sol)

**Inherits:**
Initializable, [EOFeedFactoryBase](/src/adapters/factories/EOFeedFactoryBase.sol/abstract.EOFeedFactoryBase.md)


## State Variables
### _beacon

```solidity
address private _beacon;
```


## Functions
### getBeacon

*Returns the address of the beacon.*


```solidity
function getBeacon() external view returns (address);
```

### __EOFeedFactory_init

*Initializes the factory with the feedAdapter implementation.*


```solidity
function __EOFeedFactory_init(address impl, address initialOwner) internal override onlyInitializing;
```

### _deployEOFeedAdapter

*Deploys a new feedAdapter instance via Beacon proxy.*


```solidity
function _deployEOFeedAdapter() internal override returns (address);
```

