// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Test } from "forge-std/Test.sol";
import { Utils } from "../utils/Utils.sol";
import { EOTwitterFeedManager } from "../../src/EOTwitterFeedManager.sol";
import { IEOTwitterFeedManager } from "../../src/interfaces/IEOTwitterFeedManager.sol";
import { IEOFeedVerifier } from "../../src/interfaces/IEOFeedVerifier.sol";
import { MockFeedVerifier } from "../mock/MockFeedVerifier.sol";
import { DeployTwitterFeedManager } from "../../script/deployment/base/DeployTwitterFeedManager.s.sol";
import { InvalidInput, InvalidAddress, CallerIsNotWhitelisted } from "../../src/interfaces/Errors.sol";

//solhint-disable max-states-count
contract EOTwitterFeedManagerTest is Test, Utils {
    EOTwitterFeedManager private twitterFeedManager;
    MockFeedVerifier private verifier;
    DeployTwitterFeedManager private deployer;
    address private proxyAdmin = makeAddr("proxyAdmin");
    address private owner = makeAddr("owner");
    address private notOwner = makeAddr("notOwner");
    uint32 private feedId = 1;

    event FeedPostUpdated(uint32 indexed feedId, uint64 indexed postId, IEOTwitterFeedManager.Post post);

    function setUp() public {
        verifier = new MockFeedVerifier();
        deployer = new DeployTwitterFeedManager();
        twitterFeedManager = EOTwitterFeedManager(deployer.run(proxyAdmin, address(verifier), owner));
    }

    function test_RevertWhen_NotOwner_SetFeedVerifier() public {
        address newVerifier = makeAddr("newVerifier");
        vm.prank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, notOwner));
        twitterFeedManager.setFeedVerifier(newVerifier);
    }

    function test_RevertWhen_ZeroAddress_SetFeedVerifier() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidAddress.selector));
        vm.prank(owner);
        twitterFeedManager.setFeedVerifier(address(0));
    }

    function test_SetFeedVerifier() public {
        vm.prank(owner);
        address newVerifier = makeAddr("newVerifier");
        twitterFeedManager.setFeedVerifier(newVerifier);
        assertEq(address(twitterFeedManager.getFeedVerifier()), newVerifier);
    }

    function test_RevertWhen_NotOwner_WhitelistPublishers() public {
        address[] memory publishers = new address[](1);
        publishers[0] = notOwner;
        bool[] memory isWhitelisted = new bool[](1);
        isWhitelisted[0] = true;
        vm.prank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, notOwner));
        twitterFeedManager.whitelistPublishers(publishers, isWhitelisted);
    }

    function test_RevertWhen_InvalidInput_WhitelistPublishers() public {
        address[] memory publishers = new address[](2);
        bool[] memory isWhitelisted = new bool[](1);
        vm.expectRevert(abi.encodeWithSelector(InvalidInput.selector));
        vm.prank(owner);
        twitterFeedManager.whitelistPublishers(publishers, isWhitelisted);
    }

    function test_RevertWhen_ZeroAddress_WhitelistPublishers() public {
        address[] memory publishers = new address[](1);
        bool[] memory isWhitelisted = new bool[](1);
        publishers[0] = address(0);
        isWhitelisted[0] = true;
        vm.expectRevert(abi.encodeWithSelector(InvalidAddress.selector));
        vm.prank(owner);
        twitterFeedManager.whitelistPublishers(publishers, isWhitelisted);
    }

    function test_WhitelistPublishers() public {
        address[] memory publishers = new address[](1);
        publishers[0] = notOwner;
        bool[] memory isWhitelisted = new bool[](1);
        isWhitelisted[0] = true;
        vm.prank(owner);
        twitterFeedManager.whitelistPublishers(publishers, isWhitelisted);
        assert(twitterFeedManager.isWhitelistedPublisher(notOwner));
    }

    function test_RevertWhen_SetSupportedFeedsNotOwner() public {
        uint32[] memory feedIds = new uint32[](1);
        feedIds[0] = feedId;
        bool[] memory isSupported = new bool[](1);
        isSupported[0] = true;
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, notOwner));
        vm.prank(notOwner);
        twitterFeedManager.setSupportedFeeds(feedIds, isSupported);
    }

    function test_RevertWhen_SetSupportedFeedsInvalidInput() public {
        uint32[] memory feedIds = new uint32[](5);
        bool[] memory isSupported = new bool[](4);
        vm.expectRevert(abi.encodeWithSelector(InvalidInput.selector));
        vm.prank(owner);
        twitterFeedManager.setSupportedFeeds(feedIds, isSupported);
    }

    function test_SetSupportedFeeds() public {
        uint32[] memory feedIds = new uint32[](1);
        feedIds[0] = feedId;
        bool[] memory isSupported = new bool[](1);
        isSupported[0] = true;
        vm.prank(owner);
        twitterFeedManager.setSupportedFeeds(feedIds, isSupported);
        assert(twitterFeedManager.isSupportedFeed(feedId));
    }

    function test_RevertWhen_NotWhitelisted_UpdateFeed() public {
        IEOFeedVerifier.LeafInput memory input =
            IEOFeedVerifier.LeafInput({ unhashedLeaf: "", leafIndex: 1, proof: new bytes32[](0) });
        IEOFeedVerifier.VerificationParams memory vParams = _getDefaultVerificationParams();
        vm.expectRevert(abi.encodeWithSelector(CallerIsNotWhitelisted.selector, address(this)));
        twitterFeedManager.updateFeed(input, vParams);
    }

    function test_UpdateFeed() public {
        // Setup whitelisted publisher and supported feed
        address[] memory publishers = new address[](1);
        publishers[0] = owner;
        bool[] memory isWhitelisted = new bool[](1);
        isWhitelisted[0] = true;
        vm.prank(owner);
        twitterFeedManager.whitelistPublishers(publishers, isWhitelisted);

        uint32[] memory feedIds = new uint32[](1);
        feedIds[0] = feedId;
        bool[] memory isSupported = new bool[](1);
        isSupported[0] = true;
        vm.prank(owner);
        twitterFeedManager.setSupportedFeeds(feedIds, isSupported);

        uint64 postId = 1;
        // Prepare input for update
        IEOTwitterFeedManager.PostData memory postData = IEOTwitterFeedManager.PostData({
            postId: postId,
            action: IEOTwitterFeedManager.PostAction.Creation,
            content: abi.encode(
                IEOTwitterFeedManager.PostCreation({ content: "Hello, world!", timestamp: uint32(block.timestamp) })
                )
        });
        IEOTwitterFeedManager.LeafData memory leafData =
            IEOTwitterFeedManager.LeafData({ feedId: feedId, data: abi.encode(postData) });
        IEOFeedVerifier.LeafInput memory input = IEOFeedVerifier.LeafInput({
            unhashedLeaf: abi.encode(leafData),
            leafIndex: leafData.feedId,
            proof: new bytes32[](0)
        });
        IEOFeedVerifier.VerificationParams memory vParams = _getDefaultVerificationParams();

        vm.expectEmit(true, false, false, true);
        IEOTwitterFeedManager.Post memory post;
        post.content = "Hello, world!";
        post.timestampCreated = uint32(block.timestamp);
        post.eoracleBlockNumber = vParams.blockNumber;
        emit FeedPostUpdated(feedId, postId, post);
        vm.prank(owner);
        twitterFeedManager.updateFeed(input, vParams);
        assertEq(twitterFeedManager.getFeedPost(feedId, postId).content, "Hello, world!");
        assertEq(twitterFeedManager.getFeedPost(feedId, postId).timestampCreated, block.timestamp);
    }

    function _getDefaultVerificationParams() private pure returns (IEOFeedVerifier.VerificationParams memory) {
        IEOFeedVerifier.VerificationParams memory vParams;
        vParams.blockNumber = 1;
        vParams.eventRoot = bytes32(uint256(1));
        vParams.apkG2 = [uint256(1), uint256(2), uint256(3), uint256(4)];
        vParams.signature = [uint256(1), uint256(2)];
        vParams.nonSignersBitmap = new bytes(1);
        return vParams;
    }
}
