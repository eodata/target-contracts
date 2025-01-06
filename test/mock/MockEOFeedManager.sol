// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IEOFeedManager } from "../../src/interfaces/IEOFeedManager.sol";
import { IEOFeedVerifier } from "../../src/interfaces/IEOFeedVerifier.sol";

// solhint-disable ordering
// solhint-disable no-empty-blocks

contract MockEOFeedManager is IEOFeedManager {
    uint256 public constant NOT_SUPPORTED_FEED = 1000;
    mapping(uint256 => PriceFeed) public priceFeeds;
    address internal _feedDeployer;

    constructor(address feedDeployer) {
        _feedDeployer = feedDeployer;
    }

    function updateFeed(
        IEOFeedVerifier.LeafInput calldata input,
        IEOFeedVerifier.VerificationParams calldata vParams
    )
        external
    {
        (uint256 feedId, uint256 rate, uint256 timestamp) = abi.decode(input.unhashedLeaf, (uint256, uint256, uint256));

        priceFeeds[feedId] = PriceFeed(rate, timestamp, vParams.blockNumber);
    }

    function updateFeeds(
        IEOFeedVerifier.LeafInput[] calldata inputs,
        IEOFeedVerifier.VerificationParams calldata vParams
    )
        external
    {
        for (uint256 i = 0; i < inputs.length; i++) {
            (uint256 feedId, uint256 rate, uint256 timestamp) =
                abi.decode(inputs[i].unhashedLeaf, (uint256, uint256, uint256));

            priceFeeds[feedId] = PriceFeed(rate, timestamp, vParams.blockNumber);
        }
    }

    function getLatestPriceFeed(uint256 feedId) external view returns (PriceFeed memory) {
        return priceFeeds[feedId];
    }

    function getLatestPriceFeeds(uint256[] calldata feedIds) external view returns (PriceFeed[] memory) {
        PriceFeed[] memory feeds = new PriceFeed[](feedIds.length);
        for (uint256 i = 0; i < feedIds.length; i++) {
            feeds[i] = priceFeeds[feedIds[i]];
        }
        return feeds;
    }

    function whitelistPublishers(address[] calldata, bool[] calldata) external { }

    function isWhitelistedPublisher(address) external pure returns (bool) {
        return true;
    }

    function isSupportedFeed(uint256 feedId) external pure returns (bool) {
        return feedId != NOT_SUPPORTED_FEED;
    }

    function getFeedDeployer() external view returns (address) {
        return _feedDeployer;
    }
}
