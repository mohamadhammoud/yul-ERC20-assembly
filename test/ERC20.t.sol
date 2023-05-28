// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 public erc20;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        erc20 = new ERC20();
    }

    function testName() public {
        assertEq(erc20.name(), "Mohamad");
    }

    function testSymbol() public {
        assertEq(erc20.symbol(), "Mo Token");
    }

    function testDecimals() public {
        assertEq(erc20.decimals(), 18);
    }

    function testTotalSupply() public {
        assertEq(erc20.totalSupply(), type(uint256).max);
    }

    function testBalanceOf() public {
        assertEq(erc20.balanceOf(address(this)), type(uint256).max);
    }

    function testTransfer() public {
        erc20.transfer(address(0), type(uint256).max);

        assertEq(erc20.balanceOf(address(0)), type(uint256).max);
    }

    function testApprove() public {
        erc20.approve(address(0), 456);

        assertEq(erc20.allowance(address(this), address(0)), 456);
    }

    function testTransferFrom() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(address(this), address(0), 456);
        erc20.approve(address(0), 456);

        vm.expectEmit(true, true, false, true);
        vm.prank(address(0));
        emit Transfer(address(this), address(2), 456);
        erc20.transferFrom(address(this), address(2), 456);

        assertEq(erc20.balanceOf(address(2)), 456);
    }

    function testFailTransfer() public {
        vm.prank(address(0));

        erc20.transfer(address(2), 1000);
    }

    function testFailTransferFrom() public {
        erc20.approve(address(0), 456);

        vm.prank(address(0));
        erc20.transferFrom(address(this), address(2), 1000);
    }
}
