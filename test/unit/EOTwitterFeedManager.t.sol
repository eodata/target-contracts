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

    function test_UpdateFeed_Create_Update_UpdateStatistics_Delete() public {
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
        IEOFeedVerifier.VerificationParams memory vParams = _getDefaultVerificationParams();

        IEOTwitterFeedManager.Post memory expectedPost;
        expectedPost.content = "Content1";
        expectedPost.timestampCreated = uint32(block.timestamp);
        expectedPost.eoracleBlockNumber = vParams.blockNumber;

        // Prepare input for post creation
        IEOTwitterFeedManager.PostData memory postData = IEOTwitterFeedManager.PostData({
            postId: postId,
            action: IEOTwitterFeedManager.PostAction.Creation,
            content: abi.encode(
                IEOTwitterFeedManager.PostCreation({
                    content: expectedPost.content,
                    timestamp: expectedPost.timestampCreated
                })
                )
        });
        IEOTwitterFeedManager.LeafData memory leafData =
            IEOTwitterFeedManager.LeafData({ feedId: feedId, data: abi.encode(postData) });
        IEOFeedVerifier.LeafInput memory input = IEOFeedVerifier.LeafInput({
            unhashedLeaf: abi.encode(leafData),
            leafIndex: leafData.feedId,
            proof: new bytes32[](0)
        });

        vm.expectEmit(true, false, false, true);
        emit FeedPostUpdated(feedId, postId, expectedPost);
        vm.prank(owner);
        twitterFeedManager.updateFeed(input, vParams);
        assertEq(twitterFeedManager.getFeedPost(feedId, postId).content, expectedPost.content);
        assertEq(twitterFeedManager.getFeedPost(feedId, postId).timestampCreated, expectedPost.timestampCreated);
        assertEq(twitterFeedManager.getLatestFeedPost(feedId).timestampCreated, expectedPost.timestampCreated);
        assertEq(twitterFeedManager.getLatestFeedPosts(feedId, 1)[0].timestampCreated, expectedPost.timestampCreated);

        // Prepare input for post update
        expectedPost.content = "Content2";
        expectedPost.timestampUpdatedContent = uint32(block.timestamp);
        expectedPost.eoracleBlockNumber = vParams.blockNumber;

        postData.action = IEOTwitterFeedManager.PostAction.UpdateContent;
        postData.content = abi.encode(
            IEOTwitterFeedManager.PostUpdateContent({
                content: expectedPost.content,
                timestamp: expectedPost.timestampUpdatedContent
            })
        );
        leafData.data = abi.encode(postData);
        input.unhashedLeaf = abi.encode(leafData);
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit FeedPostUpdated(feedId, postId, expectedPost);
        twitterFeedManager.updateFeed(input, vParams);
        assertEq(twitterFeedManager.getFeedPost(feedId, postId).content, expectedPost.content);
        assertEq(
            twitterFeedManager.getFeedPost(feedId, postId).timestampUpdatedContent, expectedPost.timestampUpdatedContent
        );
        assertEq(
            twitterFeedManager.getLatestFeedPost(feedId).timestampUpdatedContent, expectedPost.timestampUpdatedContent
        );
        assertEq(
            twitterFeedManager.getLatestFeedPosts(feedId, 1)[0].timestampUpdatedContent,
            expectedPost.timestampUpdatedContent
        );

        // Prepare input for post update statistics
        expectedPost.replies = 1;
        expectedPost.bookmarks = 1;
        expectedPost.reposts = 1;
        expectedPost.likes = 1;
        expectedPost.views = 1;
        expectedPost.timestampUpdatedStatistics = uint32(block.timestamp);

        postData.action = IEOTwitterFeedManager.PostAction.UpdateStatistics;
        postData.content = abi.encode(
            IEOTwitterFeedManager.PostUpdateStatistics({
                replies: expectedPost.replies,
                bookmarks: expectedPost.bookmarks,
                reposts: expectedPost.reposts,
                likes: expectedPost.likes,
                views: expectedPost.views,
                timestamp: expectedPost.timestampUpdatedStatistics
            })
        );
        leafData.data = abi.encode(postData);
        input.unhashedLeaf = abi.encode(leafData);
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit FeedPostUpdated(feedId, postId, expectedPost);
        twitterFeedManager.updateFeed(input, vParams);

        IEOTwitterFeedManager.Post memory post = twitterFeedManager.getFeedPost(feedId, postId);
        assertEq(post.replies, expectedPost.replies);
        assertEq(post.bookmarks, expectedPost.bookmarks);
        assertEq(post.reposts, expectedPost.reposts);
        assertEq(post.likes, expectedPost.likes);
        assertEq(post.views, expectedPost.views);
        assertEq(post.timestampUpdatedStatistics, expectedPost.timestampUpdatedStatistics);

        IEOTwitterFeedManager.Post memory latestPost = twitterFeedManager.getLatestFeedPost(feedId);
        assertEq(latestPost.replies, expectedPost.replies);
        assertEq(latestPost.bookmarks, expectedPost.bookmarks);
        assertEq(latestPost.reposts, expectedPost.reposts);
        assertEq(latestPost.likes, expectedPost.likes);
        assertEq(latestPost.views, expectedPost.views);

        assertEq(twitterFeedManager.getPostsAmount(feedId), 1);

        IEOTwitterFeedManager.Post[] memory latestPosts = twitterFeedManager.getLatestFeedPosts(feedId, 1);
        assertEq(latestPosts[0].replies, expectedPost.replies);
        assertEq(latestPosts[0].bookmarks, expectedPost.bookmarks);
        assertEq(latestPosts[0].reposts, expectedPost.reposts);
        assertEq(latestPosts[0].likes, expectedPost.likes);
        assertEq(latestPosts[0].views, expectedPost.views);

        // Prepare input for post deletion
        expectedPost.timestampDeleted = uint32(block.timestamp);
        postData.action = IEOTwitterFeedManager.PostAction.Deletion;
        postData.content = abi.encode(IEOTwitterFeedManager.PostDeletion({ timestamp: expectedPost.timestampDeleted }));
        leafData.data = abi.encode(postData);
        input.unhashedLeaf = abi.encode(leafData);
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit FeedPostUpdated(feedId, postId, expectedPost);
        twitterFeedManager.updateFeed(input, vParams);
        assertEq(twitterFeedManager.getFeedPost(feedId, postId).timestampDeleted, expectedPost.timestampDeleted);
        assertEq(twitterFeedManager.getLatestFeedPost(feedId).timestampDeleted, expectedPost.timestampDeleted);
        assertEq(twitterFeedManager.getLatestFeedPosts(feedId, 1)[0].timestampDeleted, expectedPost.timestampDeleted);
    }

    function test_UpdateFeeds_MultiplePosts_Create_Update_UpdateStatistics_Delete() public {
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

        uint64[] memory postIds = new uint64[](2);
        postIds[0] = 1;
        postIds[1] = 2;
        IEOFeedVerifier.VerificationParams memory vParams = _getDefaultVerificationParams();

        // Prepare input for multiple post creations
        IEOTwitterFeedManager.Post[] memory expectedPosts = new IEOTwitterFeedManager.Post[](2);
        expectedPosts[0].content = "Content1";
        expectedPosts[0].timestampCreated = uint32(block.timestamp - 1);
        expectedPosts[0].eoracleBlockNumber = vParams.blockNumber;

        expectedPosts[1].content = "Content2";
        expectedPosts[1].timestampCreated = uint32(block.timestamp);
        expectedPosts[1].eoracleBlockNumber = vParams.blockNumber;

        // Prepare input for multiple post creations
        IEOTwitterFeedManager.PostData[] memory postDataArray = new IEOTwitterFeedManager.PostData[](2);
        postDataArray[0] = IEOTwitterFeedManager.PostData({
            postId: postIds[0],
            action: IEOTwitterFeedManager.PostAction.Creation,
            content: abi.encode(
                IEOTwitterFeedManager.PostCreation({
                    content: expectedPosts[0].content,
                    timestamp: expectedPosts[0].timestampCreated
                })
                )
        });
        postDataArray[1] = IEOTwitterFeedManager.PostData({
            postId: postIds[1],
            action: IEOTwitterFeedManager.PostAction.Creation,
            content: abi.encode(
                IEOTwitterFeedManager.PostCreation({
                    content: expectedPosts[1].content,
                    timestamp: expectedPosts[1].timestampCreated
                })
                )
        });

        // leaf data
        IEOTwitterFeedManager.LeafData[] memory leafDataArray = new IEOTwitterFeedManager.LeafData[](2);
        leafDataArray[0] = IEOTwitterFeedManager.LeafData({ feedId: feedId, data: abi.encode(postDataArray[0]) });
        leafDataArray[1] = IEOTwitterFeedManager.LeafData({ feedId: feedId, data: abi.encode(postDataArray[1]) });

        // input
        IEOFeedVerifier.LeafInput[] memory inputArray = new IEOFeedVerifier.LeafInput[](2);
        inputArray[0] = IEOFeedVerifier.LeafInput({
            unhashedLeaf: abi.encode(leafDataArray[0]),
            leafIndex: leafDataArray[0].feedId,
            proof: new bytes32[](0)
        });
        inputArray[1] = IEOFeedVerifier.LeafInput({
            unhashedLeaf: abi.encode(leafDataArray[1]),
            leafIndex: leafDataArray[1].feedId,
            proof: new bytes32[](0)
        });

        vm.prank(owner);
        twitterFeedManager.updateFeeds(inputArray, vParams);

        assertEq(twitterFeedManager.getFeedPost(feedId, postIds[0]).content, expectedPosts[0].content);
        assertEq(twitterFeedManager.getFeedPost(feedId, postIds[0]).timestampCreated, expectedPosts[0].timestampCreated);
        assertEq(twitterFeedManager.getFeedPost(feedId, postIds[1]).content, expectedPosts[1].content);
        assertEq(twitterFeedManager.getFeedPost(feedId, postIds[1]).timestampCreated, expectedPosts[1].timestampCreated);

        assertEq(twitterFeedManager.getPostsAmount(feedId), 2);
        IEOTwitterFeedManager.Post[] memory latestPosts = twitterFeedManager.getLatestFeedPosts(feedId, 2);
        assertEq(latestPosts[0].timestampCreated, expectedPosts[1].timestampCreated);
        assertEq(latestPosts[1].timestampCreated, expectedPosts[0].timestampCreated);
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
