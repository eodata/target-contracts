// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/Script.sol";
import { EOJsonUtils } from "../../utils/EOJsonUtils.sol";
import { EOFeedManager } from "../../../src/EOFeedManager.sol";
import { EOFeedRegistryAdapter } from "../../../src/adapters/EOFeedRegistryAdapter.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

contract DeployFeedsTimelocked is Script {
    using stdJson for string;

    struct LocalVars {
        address feedAdapter;
        uint16 feedId;
        uint256 feedsLength;
        address[] targets;
        bytes[] payloads;
        uint256[] values;
        EOJsonUtils.FeedData[] feedData;
        bytes32 salt;
        bytes32 predecessor;
        uint256 delay;
        uint16[] feedIds;
        bool[] feedBools;
    }

    LocalVars public vars;

    EOFeedManager public feedManager;
    EOFeedRegistryAdapter public feedRegistryAdapter;
    TimelockController public timelock;

    bool public isExecutionMode;

    error FeedIsNotSupported(uint16 feedId);

    function run(bool isExecution) external {
        isExecutionMode = isExecution;
        vm.startBroadcast();
        execute();
        vm.stopBroadcast();
    }

    // for testing purposes
    function run(address broadcastFrom, bool isExecution) public {
        isExecutionMode = isExecution;
        vm.startBroadcast(broadcastFrom);
        execute();
        vm.stopBroadcast();
    }

    function execute() public {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        feedRegistryAdapter = EOFeedRegistryAdapter(outputConfig.readAddress(".feedRegistryAdapter"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        // Deploy feeds which are not deployed yet
        vars.feedsLength = configStructured.supportedFeedsData.length;

        bytes memory supportedFeedsCalldata = updateSupportedFeedsData(configStructured);
        if (supportedFeedsCalldata.length > 0) {
            vars.targets.push(address(feedManager));
            vars.payloads.push(supportedFeedsCalldata);
            vars.values.push(0);
        }

        for (uint256 i = 0; i < vars.feedsLength; i++) {
            vars.feedId = uint16(configStructured.supportedFeedsData[i].feedId);
            vars.feedAdapter = address(feedRegistryAdapter.getFeedById(vars.feedId));
            if (vars.feedAdapter == address(0)) {
                vars.payloads.push(
                    abi.encodeCall(
                        feedRegistryAdapter.deployEOFeedAdapter,
                        (
                            configStructured.supportedFeedsData[i].base,
                            configStructured.supportedFeedsData[i].quote,
                            vars.feedId,
                            configStructured.supportedFeedsData[i].description,
                            uint8(configStructured.supportedFeedsData[i].inputDecimals),
                            uint8(configStructured.supportedFeedsData[i].outputDecimals),
                            1
                        )
                    )
                );
                vars.targets.push(address(feedRegistryAdapter));
                vars.values.push(0);
                vars.feedData.push(configStructured.supportedFeedsData[i]);
            }
        }

        // schedule or execute
        vars.salt = keccak256(abi.encode("feeds"));
        vars.delay = timelock.getMinDelay();

        if (isExecutionMode) {
            timelock.executeBatch(vars.targets, vars.values, vars.payloads, vars.predecessor, vars.salt);
            writeConfig(vars.feedData);
        } else {
            timelock.scheduleBatch(vars.targets, vars.values, vars.payloads, vars.predecessor, vars.salt, vars.delay);
        }
        delete vars;
    }

    function writeConfig(EOJsonUtils.FeedData[] memory feedData) public {
        string memory feedAddressesJsonKey = "feedsJson";
        string memory feedAddressesJson;
        for (uint256 i = 0; i < feedData.length; i++) {
            feedAddressesJson = feedAddressesJsonKey.serialize(
                feedRegistryAdapter.description(feedData[i].base, feedData[i].quote),
                address(feedRegistryAdapter.getFeed(feedData[i].base, feedData[i].quote))
            );
        }

        string memory outputConfigJson = EOJsonUtils.OUTPUT_CONFIG.serialize("feeds", feedAddressesJson);
        EOJsonUtils.writeConfig(outputConfigJson);
    }

    function updateSupportedFeedsData(EOJsonUtils.Config memory _configData) internal returns (bytes memory data) {
        uint16 feedId;

        for (uint256 i = 0; i < _configData.supportedFeedIds.length; i++) {
            feedId = uint16(_configData.supportedFeedIds[i]);
            if (!feedManager.isSupportedFeed(feedId)) {
                vars.feedIds.push(feedId);
                vars.feedBools.push(true);
            }
        }
        if (vars.feedIds.length > 0) {
            data = abi.encodeCall(feedManager.setSupportedFeeds, (vars.feedIds, vars.feedBools));
        }
    }
}
