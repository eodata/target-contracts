# ModexpInverse
[Git Source](https://github.com/Eoracle/target-contracts/blob/88beedd8b816225fb92696d7d314b9def6318a7e/src/common/BLS.sol)


## Functions
### run

computes inverse

*computes $input^(N - 2) mod N$ using Addition Chain method.*


```solidity
function run(uint256 t2) internal pure returns (uint256 t0);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`t2`|`uint256`|the number to get the inverse of (uint256)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`t0`|`uint256`|the inverse (uint256)|


