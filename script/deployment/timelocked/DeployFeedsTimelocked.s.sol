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
        string feedAddressesJsonKey;
        string feedAddressesJson;
        uint16 feedId;
        uint256 feedsLength;
        uint256 feedsToDeploy;
        address[] targets;
        bytes[] payloads;
        uint256[] values;
        uint256 index;
        bytes32 salt;
        bytes32 predecessor;
        uint256 delay;
    }

    EOFeedManager public feedManager;
    EOFeedRegistryAdapter public feedRegistryAdapter;
    TimelockController public timelock;

    error FeedIsNotSupported(uint16 feedId);

    function run() external {
        bool isExecution = vm.envOr("IS_EXECUTION", false);
        vm.startBroadcast();
        execute(isExecution);
        vm.stopBroadcast();
    }

    function execute(bool isExecution) public {
        EOJsonUtils.Config memory configStructured = EOJsonUtils.getParsedConfig();
        string memory outputConfig = EOJsonUtils.initOutputConfig();

        feedManager = EOFeedManager(outputConfig.readAddress(".feedManager"));
        feedRegistryAdapter = EOFeedRegistryAdapter(outputConfig.readAddress(".feedRegistryAdapter"));
        timelock = TimelockController(payable(outputConfig.readAddress(".timelock")));

        LocalVars memory vars;

        // Deploy feeds which are not deployed yet
        vars.feedAddressesJsonKey = "feedsJson";
        vars.feedsLength = configStructured.supportedFeedsData.length;
        vars.feedsToDeploy = checkFeeds(configStructured);

        vars.targets = new address[](vars.feedsToDeploy);
        vars.payloads = new bytes[](vars.feedsToDeploy);
        vars.values = new uint256[](vars.feedsToDeploy);
        vars.index = 0;

        for (uint256 i = 0; i < vars.feedsLength; i++) {
            vars.feedId = uint16(configStructured.supportedFeedsData[i].feedId);
            vars.feedAdapter = address(feedRegistryAdapter.getFeedById(vars.feedId));
            if (vars.feedAdapter == address(0)) {
                vars.payloads[vars.index] = abi.encodeCall(
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
                );
                vars.targets[vars.index] = address(feedRegistryAdapter);
                vars.index++;
            }
            vars.feedAddressesJson = vars.feedAddressesJsonKey.serialize(
                configStructured.supportedFeedsData[i].description, vars.feedAdapter
            );
        }
        string memory outputConfigJson = EOJsonUtils.OUTPUT_CONFIG.serialize("feeds", vars.feedAddressesJson);
        EOJsonUtils.writeConfig(outputConfigJson);

        // schedule or execute
        vars.salt = keccak256(abi.encode("feeds"));
        vars.predecessor;
        vars.delay = timelock.getMinDelay();

        if (isExecution) {
            timelock.executeBatch(vars.targets, vars.values, vars.payloads, vars.predecessor, vars.salt);
        } else {
            timelock.scheduleBatch(vars.targets, vars.values, vars.payloads, vars.predecessor, vars.salt, vars.delay);
        }
    }

    function checkFeeds(EOJsonUtils.Config memory configStructured) public view returns (uint256 newFeedsCount) {
        uint256 feedsLength = configStructured.supportedFeedsData.length;
        for (uint256 i = 0; i < feedsLength; i++) {
            uint16 feedId = uint16(configStructured.supportedFeedsData[i].feedId);
            if (!feedManager.isSupportedFeed(feedId)) {
                revert FeedIsNotSupported(feedId);
            }
            address feedAdapter = address(feedRegistryAdapter.getFeedById(feedId));
            if (feedAdapter == address(0)) {
                newFeedsCount++;
            }
        }
        return newFeedsCount;
    }
}
