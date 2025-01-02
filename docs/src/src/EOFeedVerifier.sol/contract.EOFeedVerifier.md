# EOFeedVerifier
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/EOFeedVerifier.sol)

**Inherits:**
[IEOFeedVerifier](/src/interfaces/IEOFeedVerifier.sol/interface.IEOFeedVerifier.md), OwnableUpgradeable

The EOFeedVerifier contract handles the verification of update payloads. The payload includes a Merkle root
signed by eoracle validators and a Merkle path to the leaf containing the data. The verifier stores the current
validator set in its storage and ensures that the Merkle root is signed by a subset of this validator set with
sufficient voting power.


## State Variables
### DOMAIN

```solidity
bytes32 public constant DOMAIN = keccak256("EORACLE_FEED_VERIFIER");
```


### _minNumOfValidators

```solidity
uint256 internal _minNumOfValidators;
```


### _eoracleChainId
*ID of eoracle chain*


```solidity
uint256 internal _eoracleChainId;
```


### _bls
*BLS library contract*


```solidity
IBLS internal _bls;
```


### _currentValidatorSetLength
*length of validators set*


```solidity
uint256 internal _currentValidatorSetLength;
```


### _totalVotingPower
*total voting power of the current validators set*


```solidity
uint256 internal _totalVotingPower;
```


### _currentValidatorSet
*current validators set (index => Validator)*


```solidity
mapping(uint256 => Validator) internal _currentValidatorSet;
```


### _currentValidatorSetHash
*hash (keccak256) of the current validator set*


```solidity
bytes32 internal _currentValidatorSetHash;
```


### _lastProcessedBlockNumber
*block number of the last processed block*


```solidity
uint256 internal _lastProcessedBlockNumber;
```


### _lastProcessedEventRoot
*event root of the last processed block*


```solidity
bytes32 internal _lastProcessedEventRoot;
```


### _feedManager
*address of the feed manager*


```solidity
address internal _feedManager;
```


### _fullApk

```solidity
uint256[2] internal _fullApk;
```


### __gap

```solidity
uint256[50] private __gap;
```


## Functions
### onlyFeedManager

*Allows only the feed manager to call the function*


```solidity
modifier onlyFeedManager();
```

### constructor


```solidity
constructor();
```

### initialize


```solidity
function initialize(address owner, IBLS bls_, uint256 eoracleChainId_) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Owner of the contract|
|`bls_`|`IBLS`||
|`eoracleChainId_`|`uint256`|Chain ID of the eoracle chain|


### verify

verify single leaf signature from a block merkle tree


```solidity
function verify(
    LeafInput calldata input,
    VerificationParams calldata vParams
)
    external
    onlyFeedManager
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`input`|`LeafInput`|leaf input data and proof (LeafInput)|
|`vParams`|`VerificationParams`|verification params|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|leafData Leaf data, abi encoded (uint256 feedId, uint256 rate, uint256 timestamp)|


### batchVerify

batch verify signature of multiple leaves from the same block merkle tree


```solidity
function batchVerify(
    LeafInput[] calldata inputs,
    VerificationParams calldata vParams
)
    external
    onlyFeedManager
    returns (bytes[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`inputs`|`LeafInput[]`|feed leaves|
|`vParams`|`VerificationParams`|verification params|


### setNewValidatorSet

Function to set a new validator set


```solidity
function setNewValidatorSet(Validator[] calldata newValidatorSet) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newValidatorSet`|`Validator[]`|The new validator set to store|


### setFeedManager

Sets the address of the feed manager.


```solidity
function setFeedManager(address feedManager_) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedManager_`|`address`|The address of the new feed manager.|


### eoracleChainId

Returns the ID of the eoracle chain.


```solidity
function eoracleChainId() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The eoracle chain ID.|


### currentValidatorSetLength

Returns the length of the current validator set.


```solidity
function currentValidatorSetLength() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The number of validators in the current set.|


### totalVotingPower

Returns the total voting power of the current validator set.


```solidity
function totalVotingPower() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total voting power.|


### currentValidatorSet

Returns the validator at the specified index in the current validator set.


```solidity
function currentValidatorSet(uint256 index) external view returns (Validator memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`index`|`uint256`|The index of the validator in the current set.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Validator`|The validator at the given index.|


### currentValidatorSetHash

Returns the hash of the current validator set.


```solidity
function currentValidatorSetHash() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The hash of the current validator set.|


### lastProcessedBlockNumber

Returns the block number of the last processed block.


```solidity
function lastProcessedBlockNumber() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The last processed block number.|


### lastProcessedEventRoot

Returns the event root of the last processed block.


```solidity
function lastProcessedEventRoot() external view returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|The last processed event root.|


### feedManager

Returns the address of the feed manager.


```solidity
function feedManager() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of the feed manager.|


### bls


```solidity
function bls() external view returns (IBLS);
```

### _verifyParams

Function to verify the checkpoint signature


```solidity
function _verifyParams(IEOFeedVerifier.VerificationParams calldata vParams) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`vParams`|`IEOFeedVerifier.VerificationParams`|Signed data|


### _verifySignature

Verify the signature of the checkpoint


```solidity
function _verifySignature(
    bytes32 messageHash,
    uint256[2] calldata signature,
    uint256[4] calldata apkG2,
    bytes calldata nonSignersBitmap
)
    internal
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`messageHash`|`bytes32`|Hash of the message to verify|
|`signature`|`uint256[2]`|G1 Aggregated signature of the checkpoint|
|`apkG2`|`uint256[4]`|G2 Aggregated public key of the checkpoint|
|`nonSignersBitmap`|`bytes`|Bitmap of the validators who did not sign the data|


### _verifyLeaves

Verify a batch of exits leaves


```solidity
function _verifyLeaves(LeafInput[] calldata inputs, bytes32 eventRoot) internal pure returns (bytes[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`inputs`|`LeafInput[]`|Batch exit inputs for multiple event leaves|
|`eventRoot`|`bytes32`|the root this event should belong to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes[]`|Array of the leaf data fields of all submitted leaves|


### _verifyLeaf

Verify for one event


```solidity
function _verifyLeaf(LeafInput calldata input, bytes32 eventRoot) internal pure returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`input`|`LeafInput`|Exit leaf input|
|`eventRoot`|`bytes32`|event root the leaf should belong to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|The leaf data field|


### _getValueFromBitmap

*Extracts a boolean value from a specific index in a bitmap.*


```solidity
function _getValueFromBitmap(bytes calldata bitmap, uint256 index) private pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`bitmap`|`bytes`|The bytes array containing the bitmap.|
|`index`|`uint256`|The bit position from which to retrieve the value.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool The boolean value of the bit at the specified index in the bitmap. Returns 'true' if the bit is set (1), and 'false' if the bit is not set (0).|


