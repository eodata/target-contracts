# BLS

[Git Source](https://github.com/Eoracle/target-contracts/blob/badb6375447660efebd9adbe5de6f290257bb3a9/src/common/BLS.sol)

**Inherits:** [IBLS](/src/interfaces/IBLS.sol/interface.IBLS.md)

## State Variables

### PAIRING_EQUALITY_CHECK_GAS

```solidity
uint256 internal constant PAIRING_EQUALITY_CHECK_GAS = 120_000;
```

### N

```solidity
uint256 internal constant N =
    21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_583;
```

### G1_X

```solidity
uint256 internal constant G1_X = 1;
```

### G1_Y

```solidity
uint256 internal constant G1_Y = 2;
```

### N_G2_X0

```solidity
uint256 internal constant N_G2_X0 =
    10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781;
```

### N_G2_X1

```solidity
uint256 internal constant N_G2_X1 =
    11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634;
```

### N_G2_Y0

```solidity
uint256 internal constant N_G2_Y0 =
    13_392_588_948_715_843_804_641_432_497_768_002_650_278_120_570_034_223_513_918_757_245_338_268_106_653;
```

### N_G2_Y1

```solidity
uint256 internal constant N_G2_Y1 =
    17_805_874_995_975_841_540_914_202_342_111_839_520_379_459_829_704_422_454_583_296_818_431_106_115_052;
```

### Z0

```solidity
uint256 internal constant Z0 = 0x0000000000000000b3c4d79d41a91759a9e4c7e359b6b89eaec68e62effffffd;
```

### Z1

```solidity
uint256 internal constant Z1 = 0x000000000000000059e26bcea0d48bacd4f263f1acdb5c4f5763473177fffffe;
```

### T24

```solidity
uint256 internal constant T24 = 0x1000000000000000000000000000000000000000000000000;
```

### MASK24

```solidity
uint256 internal constant MASK24 = 0xffffffffffffffffffffffffffffffffffffffffffffffff;
```

## Functions

### hashToPoint

```solidity
function hashToPoint(bytes32 domain, bytes memory message) external view returns (uint256[2] memory);
```

### verifySignature

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

### verifySignatureAndVeracity

```solidity
function verifySignatureAndVeracity(
    uint256[2] calldata pk,
    uint256[2] calldata signature,
    uint256[2] calldata msgHash,
    uint256[4] calldata pkG2
)
    external
    view
    returns (bool, bool);
```

### ecadd

Adds two G1 points on the elliptic curve

```solidity
function ecadd(uint256[2] memory p1, uint256[2] memory p2) public view returns (uint256[2] memory r);
```

**Parameters**

| Name | Type         | Description  |
| ---- | ------------ | ------------ |
| `p1` | `uint256[2]` | First point  |
| `p2` | `uint256[2]` | Second point |

**Returns**

| Name | Type         | Description            |
| ---- | ------------ | ---------------------- |
| `r`  | `uint256[2]` | Result of the addition |

### ecmul

```solidity
function ecmul(uint256[2] memory p, uint256 s) public view returns (uint256[2] memory r);
```

**Parameters**

| Name | Type         | Description |
| ---- | ------------ | ----------- |
| `p`  | `uint256[2]` | G1 point    |
| `s`  | `uint256`    | scalar      |

**Returns**

| Name | Type         | Description                               |
| ---- | ------------ | ----------------------------------------- |
| `r`  | `uint256[2]` | the product of a point on G1 and a scalar |

### neg

```solidity
function neg(uint256[2] memory p) public pure returns (uint256[2] memory);
```

**Parameters**

| Name | Type         | Description       |
| ---- | ------------ | ----------------- |
| `p`  | `uint256[2]` | Some point in G1. |

**Returns**

| Name     | Type         | Description         |
| -------- | ------------ | ------------------- |
| `<none>` | `uint256[2]` | The negation of `p` |

### ecpairing

Performs elliptic curve pairing check

```solidity
function ecpairing(
    uint256[2] memory a1,
    uint256[4] memory a2,
    uint256[2] memory b1,
    uint256[4] memory b2,
    uint256 pairingGas
)
    internal
    view
    returns (bool success, bool result);
```

**Parameters**

| Name         | Type         | Description                         |
| ------------ | ------------ | ----------------------------------- |
| `a1`         | `uint256[2]` | First point in G1                   |
| `a2`         | `uint256[4]` | First point in G2                   |
| `b1`         | `uint256[2]` | Second point in G1                  |
| `b2`         | `uint256[4]` | Second point in G2                  |
| `pairingGas` | `uint256`    | Gas limit for the pairing operation |

**Returns**

| Name      | Type   | Description                              |
| --------- | ------ | ---------------------------------------- |
| `success` | `bool` | Whether the pairing check was successful |
| `result`  | `bool` | Whether the pairing equality holds       |

### hashToField

Hashes a message to a field element

```solidity
function hashToField(bytes32 domain, bytes memory messages) internal pure returns (uint256[2] memory);
```

**Parameters**

| Name       | Type      | Description      |
| ---------- | --------- | ---------------- |
| `domain`   | `bytes32` | Domain separator |
| `messages` | `bytes`   | Message to hash  |

**Returns**

| Name     | Type         | Description                              |
| -------- | ------------ | ---------------------------------------- |
| `<none>` | `uint256[2]` | Array representing the G1 hashed message |

### expandMsgTo96

Expands a message to 96 bytes

```solidity
function expandMsgTo96(bytes32 domain, bytes memory message) internal pure returns (bytes memory);
```

**Parameters**

| Name      | Type      | Description       |
| --------- | --------- | ----------------- |
| `domain`  | `bytes32` | Domain separator  |
| `message` | `bytes`   | Message to expand |

**Returns**

| Name     | Type    | Description      |
| -------- | ------- | ---------------- |
| `<none>` | `bytes` | Expanded message |

### mapToPoint

Maps a field element to a point on the curve

```solidity
function mapToPoint(uint256 _x) internal pure returns (uint256[2] memory p);
```

**Parameters**

| Name | Type      | Description          |
| ---- | --------- | -------------------- |
| `_x` | `uint256` | Field element to map |

**Returns**

| Name | Type         | Description                  |
| ---- | ------------ | ---------------------------- |
| `p`  | `uint256[2]` | Resulting point on the curve |

### sqrt

returns square root of a uint256 value

```solidity
function sqrt(uint256 xx) internal pure returns (uint256 x, bool hasRoot);
```

**Parameters**

| Name | Type      | Description                          |
| ---- | --------- | ------------------------------------ |
| `xx` | `uint256` | the value to take the square root of |

**Returns**

| Name      | Type      | Description                                 |
| --------- | --------- | ------------------------------------------- |
| `x`       | `uint256` | the uint256 value of the root               |
| `hasRoot` | `bool`    | a bool indicating if there is a square root |

### inverse

inverts a uint256 value

```solidity
function inverse(uint256 a) internal pure returns (uint256);
```

**Parameters**

| Name | Type      | Description             |
| ---- | --------- | ----------------------- |
| `a`  | `uint256` | uint256 value to invert |

**Returns**

| Name     | Type      | Description                         |
| -------- | --------- | ----------------------------------- |
| `<none>` | `uint256` | uint256 of the value of the inverse |
