// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";


interface MintableToken {
    function mint(address, uint256) external;
}


contract TestOurToken is Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;
    DeployOurToken deployer;
    OurToken ourToken;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        alice = makeAddr("alice");
        bob = makeAddr("bob");

        vm.prank(msg.sender);
        ourToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(msg.sender, 1 ether);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 600;

        // transfers fail initially, because alice isn't allowed to transfer in bob's behalf
        assertGt(ourToken.balanceOf(bob), transferAmount);
        vm.expectRevert();
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        // now bob approves alice to transfer within an allowance limit
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        // another transfer should fail because the allowance is exceeded,
        // even though bob still has funds to cover the transfer
        assertGt(ourToken.balanceOf(bob), transferAmount);
        vm.expectRevert();
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        uint256 aliceFinalBalance = ourToken.balanceOf(alice);
        uint256 bobFinalBalance = ourToken.balanceOf(bob);

        assertEq(aliceFinalBalance, transferAmount);
        assertEq(bobFinalBalance, BOB_STARTING_AMOUNT - transferAmount);
    }
}