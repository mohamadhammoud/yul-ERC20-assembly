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
    mapping(address => mapping(address => uint256)) internal allowances;

    /// The total supply of the token.
    uint internal _totalSupply;

    /// @notice Constructor initializes the contract, setting the initial balance for the deployer.
    constructor() {
        assembly {
            // Store the initial balance for the deployer (caller) in the balances mapping
            mstore(0x00, caller())
            mstore(0x20, 0x00)
            let slot := keccak256(0x00, 0x40)

            // Set the balance of caller to the maximum possible value (not(0))
            sstore(slot, not(0))

            // Set the total supply to the maximum possible value (not(0))
            sstore(0x02, not(0))

            // Emit Transfer event for the initial token distribution
            mstore(0x00, not(0))
            log3(0x00, 0x20, transferHash, 0x00, caller())
        }
    }

    /// @notice Approves `spender` to spend `amount` tokens on behalf of the `caller()`.
    // @param spender The address of the spender who is allowed to spend tokens on behalf of the caller.
    // @param amount The number of tokens that the spender is allowed to spend.
    /// @return A boolean value indicating whether the operation succeeded.
    function approve(address, uint256) external returns (bool) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // Get the the slot
            // Calculate allowance inner hash slot for sender
            let sender := caller()
            mstore(memptr, sender)
            mstore(add(memptr, 0x20), 0x01)
            let innerHash := keccak256(memptr, 0x40)

            // Get the injected location in the injected mapping
            let spender := calldataload(0x04)
            // keccak256(slot)
            mstore(memptr, spender)
            mstore(add(memptr, 0x20), innerHash)

            let locationSlot := keccak256(memptr, 0x40)

            let amount := calldataload(0x24)

            // Update allowance value
            sstore(locationSlot, amount)

            // Emit Approval event
            mstore(memptr, amount)
            log3(memptr, 0x20, approvalHash, sender, spender)

            // Set return value to true (success) and return
            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    /// @notice Transfers `amount` tokens from `sender` to `receiver` on behalf of the `caller()`.
    // @param  The address of the token holder.
    // @param  The address of the token recipient.
    // @param  The number of tokens to transfer.
    /// @return A boolean value indicating whether the operation succeeded.
    function transferFrom(address, address, uint256) external returns (bool) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            let sender := calldataload(0x04)

            // Get the the slot
            // Calculate allowance inner hash slot for sender
            mstore(memptr, sender)
            mstore(add(memptr, 0x20), 0x01)
            let innerHash := keccak256(memptr, 0x40)

            // Get the injected location in the injected mapping
            let spender := caller()
            // keccak256(slot)
            mstore(memptr, spender)
            mstore(add(memptr, 0x20), innerHash)

            let locationSlot := keccak256(memptr, 0x40)

            // Load allowance value
            let allowanceAmount := sload(locationSlot)

            let amount := calldataload(0x44)

            // Check if allowance is sufficient
            if lt(allowanceAmount, amount) {
                mstore(memptr, allowanceError)
                revert(memptr, 0x20) // revert with the insufficient balance
            }

            sstore(locationSlot, sub(allowanceAmount, amount))

            // Calculate sender's balance storage slot
            mstore(memptr, sender)
            mstore(add(memptr, 0x20), 0)
            let senderBalanceSlot := keccak256(memptr, 0x40)

            // Load sender's balance
            let senderBalance := sload(senderBalanceSlot)

            // Check if sender's balance is sufficient
            if gt(amount, senderBalance) {
                mstore(memptr, balanceError)
                revert(memptr, 0x20) // revert with the insufficient balance
            }

            // Update sender's balance
            sstore(senderBalanceSlot, sub(senderBalance, amount))

            // Calculate receiver's balance storage slot
            let recipient := calldataload(0x24)
            mstore(memptr, recipient)
            mstore(add(memptr, 0x20), 0)
            let recipientBalanceSlot := keccak256(memptr, 0x40)

            // Load receiver's balance
            let recipientBalance := sload(recipientBalanceSlot)

            // Update receiver's balance
            sstore(recipientBalanceSlot, add(recipientBalance, amount))

            // Emit Transfer event
            mstore(memptr, amount)
            log3(memptr, 0x20, transferHash, sender, recipient)

            // Set return value to true (success) and return
            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    /// @notice Transfers tokens from the caller to the specified address.
    /// @return A boolean indicating whether the transfer was successful.
    function transfer(address, uint256) external returns (bool) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            let sender := caller()

            // Store the caller's address in memory
            mstore(memptr, caller())

            // Set the second memory word to zero
            mstore(add(memptr, 0x20), 0)

            // Calculate the storage slot for the caller's (sender) balance
            let senderBalanceSlot := keccak256(memptr, 0x40)

            // Load the caller's balance from storage
            let senderBalance := sload(senderBalanceSlot)

            // Load the input transfer amount
            let amount := calldataload(0x24)

            if gt(amount, senderBalance) {
                mstore(memptr, balanceError)
                revert(memptr, 0x20) // revert with the insufficient balance
            }

            let recipient := calldataload(0x04)
            // Store the recipient address in memory
            mstore(memptr, recipient)

            // Set the second memory word to zero (balance slot)
            mstore(add(memptr, 0x20), 0)

            // Calculate the storage slot for the recipient's balance
            let recipientBalanceSlot := keccak256(memptr, 0x40)

            let recipientBalance := sload(recipientBalanceSlot)

            // Store the new sender balance
            sstore(senderBalanceSlot, sub(senderBalance, amount))

            // Store the new recipient balance
            sstore(recipientBalanceSlot, add(recipientBalance, amount))

            // Store the transfer amount in memory
            mstore(memptr, amount)

            log3(memptr, 0x20, transferHash, sender, recipient)

            // Set return value to true (success) and return
            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    function allowance(address, address) external view returns (uint256) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // Get the inner hash
            // Load the sender address into memory at position memptr
            let sender := calldataload(0x04)
            mstore(memptr, sender)
            // Load the constant value 0x01 (slot 1) into memory at position add(memptr, 0x20)
            mstore(add(memptr, 0x20), 0x01)
            // Compute the inner hash by hashing the memory contents at positions memptr and add(memptr, 0x20) (64 bytes)
            let innerHash := keccak256(memptr, 0x40)

            // Get the injected location in the injected mapping
            let spender := calldataload(0x24)
            // Load the spender address into memory at position memptr
            mstore(memptr, spender)
            // Load the inner hash into memory at position add(memptr, 0x20)
            mstore(add(memptr, 0x20), innerHash)
            // keccak256(slot)
            let locationSlot := keccak256(memptr, 0x40)

            // Load the allowance value from the computed storage slot
            let amount := sload(locationSlot)

            // Store the allowance value in memory at position memptr
            mstore(memptr, amount)

            // Return the allowance value stored in memory at position memptr
            // The second argument, 0x20, specifies the size of the returned data (32 bytes)
            return(memptr, 0x20)
        }
    }

    /// @notice Returns the total supply of tokens.
    /// @return The total supply of tokens.
    function totalSupply() external view returns (uint256) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // Load the value stored at storage slot 0x02
            let totalSupply := sload(0x02)

            // store total supply into memory at position memptr
            mstore(memptr, totalSupply)

            // Return the value stored in memory at position memptr
            // The second argument, 0x20, specifies the size of the returned data (32 bytes)
            return(memptr, 0x20)
        }
    }

    /// @notice Returns the balance of the given address.
    /// @return The balance of the given address as a uint256.
    function balanceOf(address) external view returns (uint256) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // Load the input address into memory
            mstore(memptr, calldataload(0x04))
            let account := mload(memptr)

            // Set the second memory word to zero
            mstore(add(memptr, 0x20), 0)

            // Load the balance from storage using the hash of slot and the input address
            let slot := keccak256(memptr, 0x40)
            mstore(memptr, sload(slot))

            // Return the memory containing the balance
            return(memptr, 0x20)
        }
    }

    /// @notice Returns the name of the token.
    /// @return The name of the token as a string.
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

    /// @notice Returns the symbol of the token.
    /// @return The symbol of the token as a string.
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

    /// @notice Returns the number of decimals for the token.
    /// @return The number of decimals as a uint8.
    function decimals() external pure returns (uint8) {
        assembly {
            // Store the number of decimals
            mstore(0, 18)
            // Return the memory containing the decimals value
            return(0x00, 0x20)
        }
    }
}
