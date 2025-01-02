# IEOFeedVerifier
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/interfaces/IEOFeedVerifier.sol)


## Functions
### verify

verify single leaf signature from a block merkle tree


```solidity
function verify(LeafInput memory input, VerificationParams calldata vParams) external returns (bytes memory leafData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`input`|`LeafInput`|leaf input data and proof (LeafInput)|
|`vParams`|`VerificationParams`|verification params|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`leafData`|`bytes`|Leaf data, abi encoded (uint256 feedId, uint256 rate, uint256 timestamp)|


### batchVerify

batch verify signature of multiple leaves from the same block merkle tree


```solidity
function batchVerify(
    LeafInput[] memory inputs,
    VerificationParams calldata vParams
)
    external
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
function setNewValidatorSet(Validator[] calldata newValidatorSet) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newValidatorSet`|`Validator[]`|The new validator set to store|


### setFeedManager

Sets the address of the feed manager.


```solidity
function setFeedManager(address feedManager_) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedManager_`|`address`|The address of the new feed manager.|


## Events
### ValidatorSetUpdated
*Event emitted when the validator set is updated*


```solidity
event ValidatorSetUpdated(uint256 currentValidatorSetLength, bytes32 currentValidatorSetHash, uint256 totalVotingPower);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currentValidatorSetLength`|`uint256`|Length of the current validator set|
|`currentValidatorSetHash`|`bytes32`|Hash of the current validator set|
|`totalVotingPower`|`uint256`|Total voting power of the current validator set|

### FeedManagerSet
*Event emitted when the feed manager is set*


```solidity
event FeedManagerSet(address feedManager);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`feedManager`|`address`|Address of the feed manager|

## Structs
### LeafInput
*Leaf input structure*


```solidity
struct LeafInput {
    uint256 leafIndex;
    bytes unhashedLeaf;
    bytes32[] proof;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`leafIndex`|`uint256`|Index of the leaf|
|`unhashedLeaf`|`bytes`|Unhashed leaf data abi encoded (uint256 id, address sender, address receiver, bytes memory data) where bytes memory data =  abi encoded (uint256 feedId, uint256 rate, uint256 timestamp)|
|`proof`|`bytes32[]`|Merkle proof of the leaf|

### VerificationParams
*Signed Data structure*


```solidity
struct VerificationParams {
    uint64 blockNumber;
    uint32 chainId;
    address aggregator;
    bytes32 eventRoot;
    bytes32 blockHash;
    uint256[2] signature;
    uint256[4] apkG2;
    bytes nonSignersBitmap;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`blockNumber`|`uint64`|the block number this merkle tree originated from (on EO chain)|
|`chainId`|`uint32`||
|`aggregator`|`address`||
|`eventRoot`|`bytes32`|merkle tree root for events|
|`blockHash`|`bytes32`||
|`signature`|`uint256[2]`|G1 hashed payload of abi.encode(eventRoot, blockNumber)|
|`apkG2`|`uint256[4]`|G2 apk provided from off-chain|
|`nonSignersBitmap`|`bytes`|used to construct G1 apk onchain|

### Validator
consider adding a small gap for future fields to ease upgrades in the future.

*Validator structure*


```solidity
struct Validator {
    address _address;
    uint256[2] g1pk;
    uint256[4] g2pk;
    uint256 votingPower;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|validator address|
|`g1pk`|`uint256[2]`|validator G1 public key|
|`g2pk`|`uint256[4]`|validator G2 public key (not used for now but good to have it)|
|`votingPower`|`uint256`|Validator voting power|

