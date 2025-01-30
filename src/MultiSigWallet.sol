// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MultiSigWallet.sol";

contract DeployMultiSig is Script {
    function run() external {
        // Get deployment private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Convert owner addresses from strings to address type
        address[] memory owners = new address[](3);
        owners[0] = vm.envAddress("OWNER_1");
        owners[1] = vm.envAddress("OWNER_2");
        owners[2] = vm.envAddress("OWNER_3");

        // Get required approvals from environment
        uint256 requiredApprovals = vm.envUint("REQUIRED_APPROVALS");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        MultiSigWallet multiSig = new MultiSigWallet(owners, requiredApprovals);

        vm.stopBroadcast();
    }
}
