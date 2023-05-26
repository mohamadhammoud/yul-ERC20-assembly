// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// The name of the token "Mohamad" .
bytes32 constant nameData = 0x4D6F68616D616400000000000000000000000000000000000000000000000000;
bytes32 constant nameLength = 0x0000000000000000000000000000000000000000000000000000000000000007;

// The symbol of the token "Mo Token".
bytes32 constant symbolData = 0x4D6F20546F6B656E000000000000000000000000000000000000000000000000;
bytes32 constant symbolLength = 0x0000000000000000000000000000000000000000000000000000000000000008;

// error hash
// keccak256("InsufficientAllowance()")
bytes32 constant allowanceError = 0x13be252bc8f22c3de689f75d88d90b4c4aeb9cd39d50c39ae82df3b19f85cf73;

// error hash
// keccak256("InsufficientBalance()")
bytes32 constant balanceError = 0xf4d678b8ce6b5157126b1484a53523762a93571537a7d5ae97d8014a44715c94;

// Transfer hash
// keccak256("Transfer(address,address,uint256)")
// The hash of the Transfer event signature.
bytes32 constant transferHash = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

// Approval hash
// keccak256("Approval(address,address,uint256)")
// The hash of the Approval event signature.
bytes32 constant approvalHash = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

contract ERC20 {
    /// Mapping to store token balances for each address.
    mapping(address => uint256) internal _balances;

    /// Mapping to store token allowances for each pair of owner and spender addresses.
    mapping(address => uint256) internal _allowances;

    /// The total supply of the token.
    uint internal _totalSupply;

    constructor() {}

    function name() external pure returns (string memory) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // store the offset value for the name length
            mstore(memptr, 0x20)

            // store the name length value
            mstore(add(memptr, 0x20), nameLength)

            // store the name data
            mstore(add(memptr, 0x40), nameData)

            return(memptr, 0x60)
        }
    }

    function symbol() external pure returns (string memory) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // store the offset value for the name length
            mstore(memptr, 0x20)

            // store the name length value
            mstore(add(memptr, 0x20), symbolLength)

            // store the name data
            mstore(add(memptr, 0x40), symbolData)

            return(memptr, 0x60)
        }
    }
}
