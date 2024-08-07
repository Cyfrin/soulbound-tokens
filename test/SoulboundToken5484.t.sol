// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {SoulboundToken5484, IERC5484, IERC721, IERC165, Ownable} from "../src/ERC5484/SoulboundToken5484.sol";

contract SoulboundToken5484Test is Test {
    address private constant s_issuer = address(0x123456789);
    address private constant s_receiver = address(0x987654321);
    SoulboundToken5484 private s_token;

    function setUp() public {
        vm.startPrank(s_issuer);
        s_token = new SoulboundToken5484();
        vm.stopPrank();
    }

    // Integration test
    function testSoulboundTokenMovedFromOneAddressToAnother() public {
        // Soulbound token is minted to receiver
        vm.startPrank(s_issuer);
        s_token.mint(s_receiver, 0);
        assertEq(s_token.ownerOf(0), s_receiver);
        assertEq(s_token.balanceOf(s_receiver), 1);

        // Offchain, the "soul" indicates a desire to transfer the token to another address
        // The issuer is the only one who can burn the token, and then mint that exact same token to the new address

        // Burn token 0
        s_token.burn(0);
        assertEq(s_token.balanceOf(s_receiver), 0);

        // Mint token 0 to new receiver
        address newReceiver = address(0x555555);
        s_token.mint(newReceiver, 0);

        assertEq(s_token.balanceOf(newReceiver), 1);
        assertEq(s_token.ownerOf(0), newReceiver);
    }

    // Issuer Only Soulbound Actions

    function testMintOnlyOwnerSuccess() public {
        vm.startPrank(s_issuer);
        vm.expectEmit();
        emit IERC721.Transfer(address(0), s_receiver, 0);
        emit IERC5484.Issued(s_issuer, s_receiver, 0, IERC5484.BurnAuth.IssuerOnly);
        s_token.mint(s_receiver, 0);
        vm.stopPrank();

        assertEq(s_token.ownerOf(0), s_receiver);
        assertEq(s_token.balanceOf(s_receiver), 1);
    }

    function testMintOnlyOwnerReverts() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(this)));
        s_token.mint(s_receiver, 0);
    }

    function testBurnOnlyOwnerSuccess() public {
        vm.startPrank(s_issuer);

        s_token.mint(s_receiver, 0);

        vm.expectEmit();
        emit IERC721.Transfer(s_receiver, address(0), 0);
        s_token.burn(0);
        vm.stopPrank();

        assertEq(s_token.balanceOf(s_receiver), 0);
    }

    function testBurnOnlyOwnerReverts() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(this)));
        s_token.burn(0);
    }

    // ERC 5484

    function testBurnAuth() public view {
        assert(IERC5484.BurnAuth.IssuerOnly == s_token.burnAuth(0));
    }

    // ERC 721

    function testSafeTransferFromReverts() public {
        vm.expectRevert(SoulboundToken5484.SoulboundRestricted.selector);
        s_token.safeTransferFrom(address(0), address(0), 0, "");
    }

    function testTransferFromReverts() public {
        vm.expectRevert(SoulboundToken5484.SoulboundRestricted.selector);
        s_token.transferFrom(address(0), address(0), 0);
    }

    function testApproveReverts() public {
        vm.expectRevert(SoulboundToken5484.SoulboundRestricted.selector);
        s_token.approve(address(0), 0);
    }

    function testSetApprovalForAllReverts() public {
        vm.expectRevert(SoulboundToken5484.SoulboundRestricted.selector);
        s_token.setApprovalForAll(address(0), false);
    }

    // ERC 165

    function testInterfaceSupportsIERC5484() public view {
        assertTrue(s_token.supportsInterface(type(IERC5484).interfaceId));
    }

    function testInterfaceSupportsIERC721() public view {
        assertTrue(s_token.supportsInterface(type(IERC721).interfaceId));
    }

    function testInterfaceSupportsIERC165() public view {
        assertTrue(s_token.supportsInterface(type(IERC165).interfaceId));
    }
}
