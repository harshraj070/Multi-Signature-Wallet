//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract TestMultiSig is Test {
    MultiSigWallet wallet;
    address owner1 = address(0x1);
    address owner2 = address(0x2);
    address owner3 = address(0x3);
    address nonOwner = address(0x4);
    address recipient = address(0x5);
    uint256 approvalsRequired = 2;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[2] = owner2;
        owners[3] = owner3;
        wallet = new MultiSigWallet(owners, approvalsRequired);
    }

    function testSubmitTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");
        (address to, uint256 value, , bool executed) = wallet.getTransaction(0);

        assertEq(to, recipient);
        assertEq(value, 1 ether);
        assertFalse(executed);
    }

    function testApproveTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner2);
        wallet.approveTransaction(0);

        assertEq(wallet.getApprovalCount(0), 1);
    }

    function testTransactionExecuted() public {
        vm.deal(address(wallet), 2 ether);
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner2);
        wallet.approveTransaction(0);

        vm.prank(owner3);
        wallet.approveTransaction(0);

        (, , , bool executedBefore) = wallet.getTransaction(0);
        assertFalse(executedBefore);

        wallet.executeTransaction(0);
        (, , , bool executedAfter) = wallet.getTransaction(0);
        assertTrue(executedAfter);
    }

    function testRevokeAppeal() public {
        vm.prank(owner1);
        wallet.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner2);
        wallet.approveTransaction(0);

        assertEq(wallet.getApprovalCount(0), 1);

        vm.prank(owner2);
        wallet.revokeApproval(0);
        assertEq(wallet.getApprovalCount(0), 0);
    }

    function testNonOwnerCannotSubmitTransaction() public {
        vm.expectRevert("Only Owner can call this function");
        vm.prank(nonOwner);
        wallet.submitTransaction(recipient, 1 ether, "");
    }
}
