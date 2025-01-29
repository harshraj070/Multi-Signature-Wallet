// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSigWallet {
    address[] public owners;
    uint256 public approvalsRequired;

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

    event TransactionSubmitted(
        uint256 txId,
        address to,
        uint256 value,
        bytes data
    );
    event TransactionApproved(uint256 txId, address owner);
    event TransactionExecuted(uint256 txId);
    event ApprovalRevoked(uint256 txId, address owner);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owner can call this function");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactionCount, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Transaction already executed");
        _;
    }

    modifier notApproved(uint256 txId) {
        require(
            !approvals[txId][msg.sender],
            "Transaction already approved by this owner"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _approvalsRequired) {
        require(_owners.length > 0, "At least one owner required");
        require(
            _approvalsRequired <= _owners.length,
            "Approvals required cannot exceed number of owners"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner address");

            isOwner[owner] = true;
            owners.push(owner);
        }
        approvalsRequired = _approvalsRequired;
    }

    function submitTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlyOwner {
        uint256 txId = transactionCount;
        transactions[txId] = Transaction(to, value, data, false);
        transactionCount++;

        emit TransactionSubmitted(txId, to, value, data);
    }

    function approveTransaction(
        uint256 txId
    ) external onlyOwner txExists(txId) notExecuted(txId) notApproved(txId) {
        approvals[txId][msg.sender] = true;
        emit TransactionApproved(txId, msg.sender);

        if (getApprovalCount(txId) >= approvalsRequired) {
            executeTransaction(txId);
        }
    }

    function revokeApproval(
        uint256 txId
    ) external onlyOwner txExists(txId) notExecuted(txId) {
        require(
            approvals[txId][msg.sender],
            "Transaction not approved by this owner"
        );
        approvals[txId][msg.sender] = false;

        emit ApprovalRevoked(txId, msg.sender);
    }

    function executeTransaction(
        uint256 txId
    ) public txExists(txId) notExecuted(txId) {
        require(
            getApprovalCount(txId) >= approvalsRequired,
            "Not enough approvals"
        );

        Transaction storage transaction = transactions[txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "Transaction failed");

        emit TransactionExecuted(txId);
    }

    function getApprovalCount(
        uint256 txId
    ) public view returns (uint256 count) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (approvals[txId][owners[i]]) {
                count++;
            }
        }
    }

    function getTransaction(
        uint256 txId
    )
        external
        view
        returns (address to, uint256 value, bytes memory data, bool executed)
    {
        Transaction storage transaction = transactions[txId];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed
        );
    }

    receive() external payable {}
}
