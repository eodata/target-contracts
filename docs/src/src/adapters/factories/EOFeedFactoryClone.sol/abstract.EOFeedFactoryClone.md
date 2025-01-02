# EOFeedFactoryClone
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/adapters/factories/EOFeedFactoryClone.sol)

**Inherits:**
Initializable, [EOFeedFactoryBase](/src/adapters/factories/EOFeedFactoryBase.sol/abstract.EOFeedFactoryBase.md)


## State Variables
### _feedImplementation

```solidity
address private _feedImplementation;
```


## Functions
### getFeedAdapterImplementation

*Returns the address of the feedAdapter implementation.*


```solidity
function getFeedAdapterImplementation() external view returns (address);
```

### __EOFeedFactory_init

*Initializes the factory with the feedAdapter implementation.*


```solidity
function __EOFeedFactory_init(address impl, address) internal override onlyInitializing;
```

### _deployEOFeedAdapter

*Deploys a new feedAdapter instance via Clones library.*


```solidity
function _deployEOFeedAdapter() internal override returns (address);
```

