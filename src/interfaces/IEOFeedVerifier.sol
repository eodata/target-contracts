// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IEOFeedVerifier {
    /* ============ Structs ============ */

    /**
     * @dev Leaf input structure
     * @param leafIndex Index of the leaf
     * @param unhashedLeaf Unhashed leaf data
     *         abi encoded (uint256 id, address sender, address receiver, bytes memory data)
     *              where bytes memory data =  abi encoded (uint256 feedId, uint256 rate, uint256 timestamp)
     * @param proof Merkle proof of the leaf
     */
    struct LeafInput {
        uint256 leafIndex;
        bytes unhashedLeaf;
        bytes32[] proof;
    }

    /**
     * @dev Signed Data structure
     * @param eventRoot merkle tree root for events
     * @param blockNumber the block number this merkle tree originated from (on EO chain)
     * @param signature G1 hashed payload of abi.encode(eventRoot, blockNumber)
     * @param apkG2 G2 apk provided from off-chain
     * @param nonSignersBitmap used to construct G1 apk onchain
     */
    struct VerificationParams {
        uint64 blockNumber; // 8 bytes +
        uint32 chainId; // 4 bytes +
        address aggregator; // 20 bytes = 32 bytes
        bytes32 eventRoot; // 32 bytes
        bytes32 blockHash; // 32 bytes
        uint256[2] signature; // 64 bytes
        uint256[4] apkG2; // 64 bytes
        bytes nonSignersBitmap; // dynamic
    }

    /**
     * @notice consider adding a small gap for future fields to ease upgrades in the future.
     * @dev Validator structure
     * @param _address validator address
     * @param g1pk validator G1 public key
     * @param g2pk validator G2 public key (not used for now but good to have it)
     * @param votingPower Validator voting power
     */
    struct Validator {
        address _address;
        uint256[2] g1pk;
        uint256[4] g2pk;
        uint256 votingPower;
    }

    /* ============ Events ============ */

    /**
     * @dev Event emitted when the validator set is updated
     * @param currentValidatorSetLength Length of the current validator set
     * @param currentValidatorSetHash Hash of the current validator set
     * @param totalVotingPower Total voting power of the current validator set
     */
    event ValidatorSetUpdated(
        uint256 currentValidatorSetLength, bytes32 currentValidatorSetHash, uint256 totalVotingPower
    );

    /**
     * @dev Event emitted when the feed manager is set
     * @param feedManager Address of the feed manager
     */
    event FeedManagerSet(address feedManager);

    /* ============ External Functions ============ */

    /**
     * @notice verify single leaf signature from a block merkle tree
     * @param input leaf input data and proof (LeafInput)
     * @param vParams verification params
     * @return leafData Leaf data, abi encoded (uint256 feedId, uint256 rate, uint256 timestamp)
     */
    function verify(
        LeafInput memory input,
        VerificationParams calldata vParams
    )
        external
        returns (bytes memory leafData);

    /**
     * @notice batch verify signature of multiple leaves from the same block merkle tree
     * @param inputs feed leaves
     * @param vParams verification params
     */
    function batchVerify(
        LeafInput[] memory inputs,
        VerificationParams calldata vParams
    )
        external
        returns (bytes[] memory);
}
