// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 public erc20;

    function setUp() public {
        erc20 = new ERC20();
    }

    function testName() public {
        assertEq(erc20.name(), "Mohamad");
    }

    function testSymbol() public {
        assertEq(erc20.symbol(), "Mo Token");
    }

    function testTotalSupply() public {
        assertEq(erc20.totalSupply(), type(uint256).max);
    }
}
