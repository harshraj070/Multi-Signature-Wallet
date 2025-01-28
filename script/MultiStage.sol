// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiStage2 {
    address[] public owners; // Fixed from uint256[] to address[]
    uint256 public approvalLimit;

    mapping(address => bool) public isOwner;
    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public approvals;

    uint256 public transactionCount;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Sender is not an owner");
        _;
    }

    modifier TransactionEx(uint256 txId) {
        require(txId < transactionCount, "Transaction does not exist");
        _;
    }

    modifier TransactionExecuted(uint256 txId) {
        require(
            !transactions[txId].executed,
            "Transaction has already been executed"
        );
        _;
    }

    modifier transactionApproved(uint256 txId) {
        require(
            !approvals[txId][msg.sender],
            "Transaction already approved by this owner"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _approvalsRequired) {
        require(_owners.length > 0, "The number of signers can't be zero");
        require(
            _approvalsRequired <= _owners.length,
            "Approvals can't be more than total owners"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner address");
            isOwner[owner] = true;
            owners.push(owner);
        }

        approvalLimit = _approvalsRequired;
    }
}
