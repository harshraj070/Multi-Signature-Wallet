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
    uint245 approvalsRequired = 2;

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[2] = owner2;
        owners[3] = owner3;
        wallet = new MultiSigWallet(owners, approvalsRequired);
    }

    function testSubmitTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(receipient, 1 ether, "");
        (address to, uint256 value, , bool executed) = wallet.getTransaction(0);

        assertEq(to, receipient);
        assertEq(value, 1 ether);
        assertFalse(executed);
    }
}
