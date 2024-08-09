// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IssuerSoulboundToken, AdminCanPause} from "../../src/ERC5484/IssuerSoulboundToken.sol";
import {IAccessControl, AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC5484} from "../../src/ERC5484/IERC5484.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract IssuerSoulboundTokenTest is Test {
    address private constant s_admin = address(0xabcdef123);
    address private constant s_issuer = address(0x123456789);
    address private constant s_receiver = address(0x987654321);
    IssuerSoulboundToken private s_token;

    function setUp() public {
        vm.startPrank(s_issuer);
        s_token = new IssuerSoulboundToken(s_admin, s_issuer);
        vm.stopPrank();
    }

    // Issuer Only Soulbound Actions

    // Issue

    function testIssueSuccess() public {
        vm.startPrank(s_issuer);
        vm.expectEmit();
        emit IERC721.Transfer(address(0), s_receiver, 0);
        emit IERC5484.Issued(s_issuer, s_receiver, 0, IERC5484.BurnAuth.IssuerOnly);
        s_token.issue(s_receiver, 0);
        vm.stopPrank();

        assertEq(s_token.ownerOf(0), s_receiver);
        assertEq(s_token.balanceOf(s_receiver), 1);
    }

    function testIssueOnlyIssuerAdminReverts() public {
        vm.startPrank(s_admin);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, s_admin, s_token.ISSUER_ROLE()));
        s_token.issue(s_receiver, 0);
        vm.stopPrank();
    }

    function testIssueOnlyIssuerRandomAddressReverts() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), s_token.ISSUER_ROLE()));
        s_token.issue(s_receiver, 0);
    }

    function testIssuePausedReverts() public {
        vm.startPrank(s_admin);
        s_token.pause();
        changePrank(s_issuer);
        vm.expectRevert(Pausable.EnforcedPause.selector);
        s_token.issue(s_receiver, 0);
        vm.stopPrank();
    }

    // Revoke

    function testRevokeSuccess() public {
        vm.startPrank(s_issuer);

        s_token.issue(s_receiver, 0);

        vm.expectEmit();
        emit IERC721.Transfer(s_receiver, address(0), 0);
        s_token.revoke(s_receiver, 0);
        vm.stopPrank();

        assertEq(s_token.balanceOf(s_receiver), 0);
    }

    function testRevokeOnlyIssuerAdminReverts() public {
        vm.startPrank(s_admin);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, s_admin, s_token.ISSUER_ROLE()));
        s_token.revoke(s_receiver, 0);
        vm.stopPrank();
    }

    function testRevokeOnlyIssuerRandomAddressReverts() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), s_token.ISSUER_ROLE()));
        s_token.revoke(s_receiver, 0);
    }

    function testRevokePausedReverts() public {
        vm.startPrank(s_issuer);
        s_token.issue(s_receiver, 0);
        changePrank(s_admin);
        s_token.pause();
        changePrank(s_issuer);
        vm.expectRevert(Pausable.EnforcedPause.selector);
        s_token.revoke(s_receiver, 0);
        vm.stopPrank();
    }

    function testRevokeTokenDoesNotBelongToAddressReverts() public {
        vm.startPrank(s_issuer);
        s_token.issue(s_receiver, 0);

        vm.expectRevert(IssuerSoulboundToken.TokenDoesNotBelongToAddress.selector);
        s_token.revoke(address(this), 0);

        vm.stopPrank();
    }

    // Reissue

    function testReissueSuccess() public {
        vm.startPrank(s_issuer);

        s_token.issue(s_receiver, 0);

        address newReceiver = address(0x123456789);
        vm.expectEmit();
        emit IssuerSoulboundToken.Revoked(s_issuer, s_receiver, 0);
        emit IERC5484.Issued(s_issuer, newReceiver, 0, IERC5484.BurnAuth.IssuerOnly);
        s_token.reissue(s_receiver, newReceiver, 0);
        vm.stopPrank();

        assertEq(s_token.ownerOf(0), newReceiver);
        assertEq(s_token.balanceOf(s_receiver), 0);
    }

    function testReissueOnlyIssuerAdminReverts() public {
        vm.startPrank(s_admin);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, s_admin, s_token.ISSUER_ROLE()));
        s_token.reissue(s_receiver, s_receiver, 0);
        vm.stopPrank();
    }

    function testReissueOnlyIssuerRandomAddressReverts() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, address(this), s_token.ISSUER_ROLE()));
        s_token.reissue(s_receiver, s_receiver, 0);
    }

    function testReissuePausedReverts() public {
        vm.startPrank(s_issuer);
        s_token.issue(s_receiver, 0);
        changePrank(s_admin);
        s_token.pause();
        changePrank(s_issuer);
        vm.expectRevert(Pausable.EnforcedPause.selector);
        s_token.reissue(s_receiver, s_receiver, 0);
        vm.stopPrank();
    }

    // ERC 5484

    function testBurnAuth() public view {
        IERC5484.BurnAuth burnAuth = s_token.burnAuth(0);
        assert(IERC5484.BurnAuth.IssuerOnly == burnAuth);
    }

    // ERC 721

    function testSafeTransferFromReverts() public {
        vm.expectRevert(IssuerSoulboundToken.SoulboundRestricted.selector);
        s_token.safeTransferFrom(address(0), address(0), 0, "");
    }

    function testTransferFromReverts() public {
        vm.expectRevert(IssuerSoulboundToken.SoulboundRestricted.selector);
        s_token.transferFrom(address(0), address(0), 0);
    }

    function testApproveReverts() public {
        vm.expectRevert(IssuerSoulboundToken.SoulboundRestricted.selector);
        s_token.approve(address(0), 0);
    }

    function testSetApprovalForAllReverts() public {
        vm.expectRevert(IssuerSoulboundToken.SoulboundRestricted.selector);
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
