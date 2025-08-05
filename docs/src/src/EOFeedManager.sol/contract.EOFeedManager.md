# EOFeedManager

[Git Source](https://github.com/Eoracle/target-contracts/blob/401eb40ea1472e38057aaf0537c1644781be9b1b/src/EOFeedManager.sol)

**Inherits:** [IEOFeedManager](/src/interfaces/IEOFeedManager.sol/interface.IEOFeedManager.md), OwnableUpgradeable,
PausableUpgradeable

**Author:** eOracle

The EOFeedManager contract is responsible for receiving feed updates from whitelisted publishers. These updates are
verified using the logic in the EOFeedVerifier. Upon successful verification, the feed data is stored in the
EOFeedManager and made available for other smart contracts to read. Only supported feed IDs can be published to the feed
manager.

## State Variables

### \_priceFeeds

_Map of feed id to price feed (feed id => PriceFeed)_

```solidity
mapping(uint256 => PriceFeed) internal _priceFeeds;
```

### \_whitelistedPublishers

_Map of whitelisted publishers (publisher => is whitelisted)_

```solidity
mapping(address => bool) internal _whitelistedPublishers;
```

### \_supportedFeedIds

_Map of supported feeds, (feed id => is supported)_

```solidity
mapping(uint256 => bool) internal _supportedFeedIds;
```

### \_feedVerifier

_feed verifier contract_

```solidity
IEOFeedVerifier internal _feedVerifier;
```

### \_pauserRegistry

Address of the `PauserRegistry` contract that this contract defers to for determining access control (for pausing).

```solidity
IPauserRegistry internal _pauserRegistry;
```

### \_feedDeployer

_Address of the feed deployer_

```solidity
address internal _feedDeployer;
```

### \_\_gap

_Gap for future storage variables in upgradeable contract. See
https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps_

```solidity
uint256[48] private __gap;
```

## Functions

### onlyWhitelisted

_Allows only whitelisted publishers to call the function_

```solidity
modifier onlyWhitelisted();
```

### onlyNonZeroAddress

_Allows only non-zero addresses_

```solidity
modifier onlyNonZeroAddress(address addr);
```

### onlyPauser

```solidity
modifier onlyPauser();
```

### onlyUnpauser

```solidity
modifier onlyUnpauser();
```

### onlyFeedDeployer

```solidity
modifier onlyFeedDeployer();
```

### constructor

**Note:** oz-upgrades-unsafe-allow: constructor

```solidity
constructor();
```

### initialize

Initialize the contract with the feed verifier address

_The feed verifier contract must be deployed first_

```solidity
function initialize(
    address feedVerifier,
    address owner,
    address pauserRegistry,
    address feedDeployer
)
    external
    onlyNonZeroAddress(feedVerifier)
    onlyNonZeroAddress(feedDeployer)
    onlyNonZeroAddress(pauserRegistry)
    initializer;
```

**Parameters**

| Name             | Type      | Description                             |
| ---------------- | --------- | --------------------------------------- |
| `feedVerifier`   | `address` | Address of the feed verifier contract   |
| `owner`          | `address` | Owner of the contract                   |
| `pauserRegistry` | `address` | Address of the pauser registry contract |
| `feedDeployer`   | `address` | Address of the feed deployer            |

### setFeedVerifier

Set the feed verifier contract address

```solidity
function setFeedVerifier(address feedVerifier) external onlyOwner onlyNonZeroAddress(feedVerifier);
```

**Parameters**

| Name           | Type      | Description                           |
| -------------- | --------- | ------------------------------------- |
| `feedVerifier` | `address` | Address of the feed verifier contract |

### setFeedDeployer

Set the feed deployer

```solidity
function setFeedDeployer(address feedDeployer) external onlyOwner onlyNonZeroAddress(feedDeployer);
```

**Parameters**

| Name           | Type      | Description               |
| -------------- | --------- | ------------------------- |
| `feedDeployer` | `address` | The feed deployer address |

### resetFeedTimestamps

Reset timestamps for specified price feeds to zero

_This function can only be called by the contract owner_

_Useful for emergency situations where you need to clear stale timestamp data_

```solidity
function resetFeedTimestamps(uint256[] calldata feedIds) external onlyOwner;
```

**Parameters**

| Name      | Type        | Description                                        |
| --------- | ----------- | -------------------------------------------------- |
| `feedIds` | `uint256[]` | Array of feed IDs whose timestamps should be reset |

### setSupportedFeeds

Set the supported feeds

```solidity
function setSupportedFeeds(uint256[] calldata feedIds, bool[] calldata isSupported) external onlyOwner;
```

**Parameters**

| Name          | Type        | Description                                                |
| ------------- | ----------- | ---------------------------------------------------------- |
| `feedIds`     | `uint256[]` | Array of feed ids                                          |
| `isSupported` | `bool[]`    | Array of booleans indicating whether the feed is supported |

### addSupportedFeeds

Add supported feeds

```solidity
function addSupportedFeeds(uint256[] calldata feedIds) external onlyFeedDeployer;
```

**Parameters**

| Name      | Type        | Description       |
| --------- | ----------- | ----------------- |
| `feedIds` | `uint256[]` | Array of feed ids |

### whitelistPublishers

Whitelist or remove publishers

```solidity
function whitelistPublishers(address[] calldata publishers, bool[] calldata isWhitelisted) external onlyOwner;
```

**Parameters**

| Name            | Type        | Description                                                               |
| --------------- | ----------- | ------------------------------------------------------------------------- |
| `publishers`    | `address[]` | Array of publisher addresses                                              |
| `isWhitelisted` | `bool[]`    | Array of booleans indicating whether each publisher should be whitelisted |

### updateFeed

Update the price for a feed

```solidity
function updateFeed(
    IEOFeedVerifier.LeafInput calldata input,
    IEOFeedVerifier.VerificationParams calldata vParams
)
    external
    onlyWhitelisted
    whenNotPaused;
```

**Parameters**

| Name      | Type                                 | Description                                              |
| --------- | ------------------------------------ | -------------------------------------------------------- |
| `input`   | `IEOFeedVerifier.LeafInput`          | A merkle leaf containing price data and its merkle proof |
| `vParams` | `IEOFeedVerifier.VerificationParams` | Verification parameters                                  |

### updateFeeds

Update the price for multiple feeds

```solidity
function updateFeeds(
    IEOFeedVerifier.LeafInput[] calldata inputs,
    IEOFeedVerifier.VerificationParams calldata vParams
)
    external
    onlyWhitelisted
    whenNotPaused;
```

**Parameters**

| Name      | Type                                 | Description                             |
| --------- | ------------------------------------ | --------------------------------------- |
| `inputs`  | `IEOFeedVerifier.LeafInput[]`        | Array of leafs to prove the price feeds |
| `vParams` | `IEOFeedVerifier.VerificationParams` | Verification parameters                 |

### setPauserRegistry

Set the pauser registry contract address

```solidity
function setPauserRegistry(address pauserRegistry) external onlyOwner onlyNonZeroAddress(pauserRegistry);
```

**Parameters**

| Name             | Type      | Description                             |
| ---------------- | --------- | --------------------------------------- |
| `pauserRegistry` | `address` | Address of the pauser registry contract |

### pause

Pause the feed manager

```solidity
function pause() external onlyPauser;
```

### unpause

Unpause the feed manager

```solidity
function unpause() external onlyUnpauser;
```

### getLatestPriceFeed

Get the latest price for a feed

```solidity
function getLatestPriceFeed(uint256 feedId) external view returns (PriceFeed memory);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | Feed id     |

**Returns**

| Name     | Type        | Description                                                                                                                                                                                              |
| -------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<none>` | `PriceFeed` | The latest price feed data containing: - value: The price feed value - timestamp: The timestamp when the price was aggregated - eoracleBlockNumber: The eoracle block number when the price was recorded |

### getLatestPriceFeeds

Get the latest price feeds for multiple feeds

```solidity
function getLatestPriceFeeds(uint256[] calldata feedIds) external view returns (PriceFeed[] memory);
```

**Parameters**

| Name      | Type        | Description       |
| --------- | ----------- | ----------------- |
| `feedIds` | `uint256[]` | Array of feed ids |

**Returns**

| Name     | Type          | Description                                                        |
| -------- | ------------- | ------------------------------------------------------------------ |
| `<none>` | `PriceFeed[]` | Array of PriceFeed structs corresponding to each requested feed ID |

### isWhitelistedPublisher

Check if a publisher is whitelisted

```solidity
function isWhitelistedPublisher(address publisher) external view returns (bool);
```

**Parameters**

| Name        | Type      | Description              |
| ----------- | --------- | ------------------------ |
| `publisher` | `address` | Address of the publisher |

**Returns**

| Name     | Type   | Description                                             |
| -------- | ------ | ------------------------------------------------------- |
| `<none>` | `bool` | Boolean indicating whether the publisher is whitelisted |

### isSupportedFeed

Check if a feed is supported

```solidity
function isSupportedFeed(uint256 feedId) external view returns (bool);
```

**Parameters**

| Name     | Type      | Description      |
| -------- | --------- | ---------------- |
| `feedId` | `uint256` | feed Id to check |

**Returns**

| Name     | Type   | Description                                      |
| -------- | ------ | ------------------------------------------------ |
| `<none>` | `bool` | Boolean indicating whether the feed is supported |

### getFeedDeployer

Get the feed deployer

```solidity
function getFeedDeployer() external view returns (address);
```

**Returns**

| Name     | Type      | Description                  |
| -------- | --------- | ---------------------------- |
| `<none>` | `address` | Address of the feed deployer |

### getFeedVerifier

Get the feed verifier contract address

```solidity
function getFeedVerifier() external view returns (IEOFeedVerifier);
```

**Returns**

| Name     | Type              | Description                           |
| -------- | ----------------- | ------------------------------------- |
| `<none>` | `IEOFeedVerifier` | Address of the feed verifier contract |

### getPauserRegistry

Get the pauser registry contract address

```solidity
function getPauserRegistry() external view returns (IPauserRegistry);
```

**Returns**

| Name     | Type              | Description                             |
| -------- | ----------------- | --------------------------------------- |
| `<none>` | `IPauserRegistry` | Address of the pauser registry contract |

### \_processVerifiedRate

Process the verified feed data, validate it and store it. If the timestamp is newer than the existing timestamp, updates
the price feed and emits RateUpdated. Otherwise emits SymbolReplay without updating.

```solidity
function _processVerifiedRate(bytes memory data, uint256 blockNumber) internal;
```

**Parameters**

| Name          | Type      | Description                                                                       |
| ------------- | --------- | --------------------------------------------------------------------------------- |
| `data`        | `bytes`   | verified feed data, abi encoded (uint256 feedId, uint256 rate, uint256 timestamp) |
| `blockNumber` | `uint256` | eoracle chain block number                                                        |

### \_getLatestPriceFeed

Get the latest price feed

```solidity
function _getLatestPriceFeed(uint256 feedId) internal view returns (PriceFeed memory);
```

**Parameters**

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| `feedId` | `uint256` | Feed id     |

**Returns**

| Name     | Type        | Description      |
| -------- | ----------- | ---------------- |
| `<none>` | `PriceFeed` | PriceFeed struct |
