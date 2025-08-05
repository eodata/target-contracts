// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IEOFeedAdapter
 * @author eOracle
 * @notice Interface for the EOFeedAdapter contract.
 * @dev compatible of AggregatorV3Interface from CL.
 */
interface IEOFeedAdapterOldCompatible {
    // slither-disable-next-line missing-inheritance
    function initialize(
        address feedManager,
        uint16 feedId,
        uint8 inputDecimals,
        uint8 outputDecimals,
        string memory feedDescription,
        uint256 feedVersion
    )
        external;

    function getFeedId() external view returns (uint256);
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    // v2 interface - for backward compatibility
    function latestAnswer() external view returns (int256);
    function latestTimestamp() external view returns (uint256);
    function latestRound() external view returns (uint256);
    function getAnswer(uint256 roundId) external view returns (int256);
    function getTimestamp(uint256 roundId) external view returns (uint256);
}
