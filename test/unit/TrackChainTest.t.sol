// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployTrackChain} from "../../script/DeployTrackChain.s.sol";
import {TrackChain} from "../../src/TrackChain.sol";

contract TrackChainTest is Test {
    TrackChain trackchain;

    address public user1 = address(1);
    address public user2 = address(2);
    address public user3 = address(3);

    function setUp() external {
        DeployTrackChain deployer = new DeployTrackChain();
        trackchain = deployer.run();
    }

    modifier createItem() {
        vm.startPrank(user1);
        trackchain.createItem("123ABC", "Test Item");
        vm.stopPrank();

        _;
    }

    modifier createItemAndTransfer() {
        vm.startPrank(user1);
        trackchain.createItem("234BCD", "iPhone 17 Pro");
        trackchain.transferOwnership("234BCD", user3);
        vm.stopPrank();

        _;
    }

    function testCreateItem() public createItem {
        string[] memory itemIds = trackchain.getItemIds();

        assertEq(itemIds.length, 1);
    }

    function testRevertWhenAddingDuplicateItem() public createItem {
        vm.startPrank(user1);
        vm.expectRevert(TrackChain.TrackChain__DuplicateItemsNotAllowed.selector);
        trackchain.createItem("123ABC", "Another Test Item");
        vm.stopPrank();
    }

    function testRevertWhenAddingItemWithEmptyParameters() public {
        vm.startPrank(user1);
        vm.expectRevert(TrackChain.TrackChain__EmptyItemPropertiesNotAllowed.selector);
        trackchain.createItem("", "iPhone 15 Pro Max");
        vm.stopPrank();
    }

    function testRevertWhenTransferNotPermitted() public createItem {
        vm.startPrank(user2);
        vm.expectRevert(TrackChain.TrackChain__TransferNotPermitted.selector);
        trackchain.transferOwnership("123ABC", user3);
        vm.stopPrank();
    }

    function testRevertWhenTransferringUnlistedItem() public {
        vm.startPrank(user1);
        vm.expectRevert(TrackChain.TrackChain__ItemNotFound.selector);
        trackchain.transferOwnership("567EFG", user3);
        vm.stopPrank();
    }

    function testRevertWhenTransferringToSelf() public createItem {
        vm.startPrank(user1);
        vm.expectRevert(TrackChain.TrackChain__CannotTransferToSelf.selector);
        trackchain.transferOwnership("123ABC", user1);
        vm.stopPrank();
    }

    function testRevertWhenGettingOwnerForUnlistedItem() public {
        vm.expectRevert(TrackChain.TrackChain__ItemNotFound.selector);
        trackchain.getCurrentOwner("456ABD");
    }

    function testGetOwner() public createItem {
        address currentOwner = trackchain.getCurrentOwner("123ABC");
        assertEq(currentOwner, user1);
    }

    function testGetOwnerAfterItemTransfer() public createItemAndTransfer {
        address currentOwner = trackchain.getCurrentOwner("234BCD");

        assertEq(currentOwner, user3);
    }

    function testGetInitialOwner() public createItemAndTransfer {
        address initialOwner = trackchain.getInitialOwner("234BCD");
        assertEq(initialOwner, user1);
    }

    function testGetItemsByOwner() public createItem {
        vm.startPrank(user1);
        // We need two to three items owned by user1
        trackchain.createItem("ZYX", "ZYX");
        trackchain.createItem("12G8", "12G8");
        vm.stopPrank();
        assertEq(trackchain.getItemsByOwner(user1).length, 3);
    }
}
