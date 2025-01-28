// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/*//////////////////////////////////////////////////////////////////////////
                                EOFeedManager
//////////////////////////////////////////////////////////////////////////*/
error CallerIsNotWhitelisted(address caller);
error MissingLeafInputs();
error FeedNotSupported(uint256 feedId);
error CallerIsNotPauser();
error CallerIsNotUnpauser();
error CallerIsNotFeedDeployer();
/*//////////////////////////////////////////////////////////////////////////
                                EOFeedVerifier
//////////////////////////////////////////////////////////////////////////*/
error CallerIsNotFeedManager();
error InvalidInput();
error InvalidProof();
error InvalidAddress();
error InvalidEventRoot();
error VotingPowerIsZero();
error InsufficientVotingPower();
error SignatureVerificationFailed();
error SignaturePairingFailed();
error ValidatorIndexOutOfBounds();
error ValidatorSetTooSmall();
error DuplicatedAddresses();

/*//////////////////////////////////////////////////////////////////////////
                                EOFeedRegistryAdapter
//////////////////////////////////////////////////////////////////////////*/
error FeedAlreadyExists();
error BaseQuotePairExists();
error FeedDoesNotExist();
error NotFeedDeployer();
error NotLatestRound();
