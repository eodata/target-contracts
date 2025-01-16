# IBLS

[Git Source](https://github.com/Eoracle/target-contracts/blob/badb6375447660efebd9adbe5de6f290257bb3a9/src/interfaces/IBLS.sol)

## Functions

### hashToPoint

hashes an arbitrary message to a point on the curve

_Fouque-Tibouchi Hash to Curve_

```solidity
function hashToPoint(bytes32 domain, bytes memory message) external view returns (uint256[2] memory);
```

**Parameters**

| Name      | Type      | Description                   |
| --------- | --------- | ----------------------------- |
| `domain`  | `bytes32` | domain separator for the hash |
| `message` | `bytes`   | the message to map            |

**Returns**

| Name     | Type         | Description                                                  |
| -------- | ------------ | ------------------------------------------------------------ |
| `<none>` | `uint256[2]` | uint256[2] (x,y) point on the curve that the message maps to |

### verifySignature

verifies a single signature

```solidity
function verifySignature(
    uint256[2] calldata signature,
    uint256[4] calldata pubkey,
    uint256[2] calldata message
)
    external
    view
    returns (bool, bool);
```

**Parameters**

| Name        | Type         | Description                            |
| ----------- | ------------ | -------------------------------------- |
| `signature` | `uint256[2]` | 64-byte G1 group element (small sig)   |
| `pubkey`    | `uint256[4]` | 128-byte G2 group element (big pubkey) |
| `message`   | `uint256[2]` | message signed to produce signature    |

**Returns**

| Name     | Type   | Description                  |
| -------- | ------ | ---------------------------- |
| `<none>` | `bool` | bool sig verification        |
| `<none>` | `bool` | bool indicating call success |

### verifySignatureAndVeracity

verifies a single signature and the veracity of the apk

```solidity
function verifySignatureAndVeracity(
    uint256[2] calldata pubkey,
    uint256[2] calldata signature,
    uint256[2] calldata message,
    uint256[4] calldata pubkeyG2
)
    external
    view
    returns (bool, bool);
```

**Parameters**

| Name        | Type         | Description                                                     |
| ----------- | ------------ | --------------------------------------------------------------- |
| `pubkey`    | `uint256[2]` | 64-byte G1 group element (small pubkey) - the claimed G1 pubkey |
| `signature` | `uint256[2]` | 64-byte G1 group element (small sig)                            |
| `message`   | `uint256[2]` | hash 64-byte message signed to produce signature                |
| `pubkeyG2`  | `uint256[4]` | 128-byte G2 group element (big apk) - the provided G2 pubkey    |

**Returns**

| Name     | Type   | Description                  |
| -------- | ------ | ---------------------------- |
| `<none>` | `bool` | bool sig verification        |
| `<none>` | `bool` | bool indicating call success |

### ecadd

```solidity
function ecadd(uint256[2] calldata a, uint256[2] calldata b) external view returns (uint256[2] memory);
```

### ecmul

```solidity
function ecmul(uint256[2] calldata p, uint256 s) external view returns (uint256[2] memory);
```

### neg

```solidity
function neg(uint256[2] calldata a) external pure returns (uint256[2] memory);
```
