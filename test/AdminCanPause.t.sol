// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {AdminCanPause, Pausable} from "../src/AdminCanPause.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract AdminCanPauseTest is Test {

    AdminCanPause private s_target;

    function setUp() public {
        s_target = new AdminCanPause(address(this));
    }

    function testPauseSuccess() public {
        s_target.pause();
        assertTrue(s_target.paused());
    }

    function testPauseAlreadyPausedReverts() public {
        s_target.pause();
        vm.expectRevert(Pausable.EnforcedPause.selector);
        s_target.pause();
    }

    function testPauseWrongRoleReverts() public {
        address random = address(123);
        vm.startPrank(random);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector , random, s_target.DEFAULT_ADMIN_ROLE()));
        s_target.pause();
        vm.stopPrank();
    }

    function testUnpauseSuccess() public {
        s_target.pause();
        s_target.unpause();
        assertFalse(s_target.paused());
    }

    function testUnpauseAlreadyUnpausedReverts() public {
        vm.expectRevert(Pausable.ExpectedPause.selector);
        s_target.unpause();
    }

    function testUnpaiseWrongRoleReverts() public {
        address random = address(123);
        vm.startPrank(random);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector , random, s_target.DEFAULT_ADMIN_ROLE()));
        s_target.unpause();
        vm.stopPrank();
    }
}