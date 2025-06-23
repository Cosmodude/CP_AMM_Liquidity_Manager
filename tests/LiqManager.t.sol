// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { LiqManager } from "../src/LiqManager.sol";
import { Token } from "../src/TokenA.sol";
import { PoolInit } from "../script/PoolInit.s.sol";
import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";

contract LiqManagerTest is Test {
    LiqManager public liqManager;
    Token public tokenA;
    Token public tokenB;
    address public pair;
    address public router;
    address public factory;
    uint256 public initialLiquidity;

    address public testUser = makeAddr("testUser");
    address public testUser2 = makeAddr("testUser2");

    uint256 public mintAmount = 1_000_000_000_000_000_000;
    uint256 public liquidityAmountA = 500_000_000_000_000_000;
    uint256 public liquidityAmountB = 500_000_000_000_000_000;

    function setUp() public {
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));

        vm.deal(testUser, 100 ether);
        vm.deal(testUser2, 100 ether);

        router = vm.envAddress("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA");
        factory = vm.envAddress("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA");

        vm.setEnv("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA", vm.toString(router));
        vm.setEnv("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA", vm.toString(factory));
        vm.setEnv("DEV_ADDRESS", vm.toString(testUser));

        PoolInit poolInit = new PoolInit();
        (tokenA, tokenB, pair, initialLiquidity) = poolInit.run();

        liqManager = new LiqManager(router, pair);

        tokenA.mint(testUser2, mintAmount);
        tokenB.mint(testUser2, mintAmount);
    }

    function test_AddLiquidityByMint() public {
        vm.startPrank(testUser);

        uint256 initialBalanceA = tokenA.balanceOf(testUser);
        uint256 initialBalanceB = tokenB.balanceOf(testUser);

        uint256 lpAmountDesired = 100_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        liqManager.addLiquidityByMint(lpAmountDesired);

        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        uint256 lpBalance = pairContract.balanceOf(testUser);

        assertTrue(
            lpBalance >= lpAmountDesired + initialLiquidity - 1 && lpBalance <= lpAmountDesired + initialLiquidity + 1,
            "LP amount mismatch"
        );
        assertTrue(tokenA.balanceOf(testUser) < initialBalanceA, "Token A should be spent");
        assertTrue(tokenB.balanceOf(testUser) < initialBalanceB, "Token B should be spent");

        vm.stopPrank();
    }

    function test_RemoveExactLiquidity() public {
        vm.startPrank(testUser);

        uint256 lpAmountDesired = 100_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        liqManager.addLiquidityByMint(lpAmountDesired);

        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        uint256 lpBalance = pairContract.balanceOf(testUser);

        uint256 balanceBeforeA = tokenA.balanceOf(testUser);
        uint256 balanceBeforeB = tokenB.balanceOf(testUser);

        pairContract.approve(address(liqManager), lpBalance);

        liqManager.removeExactLiquidity(lpBalance);

        uint256 balanceAfterA = tokenA.balanceOf(testUser);
        uint256 balanceAfterB = tokenB.balanceOf(testUser);

        assertTrue(balanceAfterA > balanceBeforeA, "Should receive token A back");
        assertTrue(balanceAfterB > balanceBeforeB, "Should receive token B back");
        assertEq(pairContract.balanceOf(testUser), 0, "LP tokens should be burned");

        vm.stopPrank();
    }

    function test_AddLiquidityByMint_RevertWhenNoLiquidity() public {
        Token newTokenA = new Token("New Token A", "NTKA");
        Token newTokenB = new Token("New Token B", "NTKB");

        IUniswapV2Factory factoryContract = IUniswapV2Factory(factory);
        address newPair = factoryContract.createPair(address(newTokenA), address(newTokenB));

        LiqManager newLiqManager = new LiqManager(router, newPair);

        vm.startPrank(testUser);

        newTokenA.mint(testUser, 1_000_000_000_000_000_000_000);
        newTokenB.mint(testUser, 1_000_000_000_000_000_000_000);

        newTokenA.approve(address(newLiqManager), type(uint256).max);
        newTokenB.approve(address(newLiqManager), type(uint256).max);

        vm.expectRevert(LiqManager.NoLiquidityExists.selector);
        newLiqManager.addLiquidityByMint(100_000_000_000_000_000);

        vm.stopPrank();
    }

    function test_AddLiquidityByMint_RevertWhenInsufficientBalance() public {
        vm.startPrank(testUser);

        // user has 0.5 of each token
        uint256 lpAmountDesired = 600_000_000_000_000_000; // 0.6

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        // Expect ERC20InsufficientBalance since user doesn't have enough tokens
        vm.expectRevert();
        liqManager.addLiquidityByMint(lpAmountDesired);

        vm.stopPrank();
    }

    function test_RemoveExactLiquidity_RevertWhenInsufficientAllowance() public {
        vm.startPrank(testUser);

        uint256 lpAmountDesired = 100_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        liqManager.addLiquidityByMint(lpAmountDesired);

        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        uint256 lpBalance = pairContract.balanceOf(testUser);

        vm.expectRevert();
        liqManager.removeExactLiquidity(lpBalance);

        vm.stopPrank();
    }

    function test_FlashAddThenRemove() public {
        vm.startPrank(testUser2);

        uint256 initialBalanceA = tokenA.balanceOf(testUser2);
        uint256 initialBalanceB = tokenB.balanceOf(testUser2);
        uint256 lpAmountDesired = 100_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        liqManager.flashAddThenRemove(lpAmountDesired);

        uint256 finalBalanceA = tokenA.balanceOf(testUser2);
        uint256 finalBalanceB = tokenB.balanceOf(testUser2);

        // User should receive approximately the same amount back (minus fees)
        assertTrue(finalBalanceA >= initialBalanceA - 1, "Should receive the same amount of token A back");
        assertTrue(finalBalanceB >= initialBalanceB - 1, "Should receive the same amount of token B back");

        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        assertEq(pairContract.balanceOf(testUser2), 0, "Should not have any LP tokens");

        vm.stopPrank();
    }

    function test_FlashAddThenRemove_WithSlippage() public {
        vm.startPrank(testUser2);

        uint256 initialBalanceA = tokenA.balanceOf(testUser2);
        uint256 initialBalanceB = tokenB.balanceOf(testUser2);
        uint256 lpAmountDesired = 50_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        liqManager.flashAddThenRemove(lpAmountDesired);

        uint256 finalBalanceA = tokenA.balanceOf(testUser2);
        uint256 finalBalanceB = tokenB.balanceOf(testUser2);

        assertTrue(finalBalanceA >= initialBalanceA, "Should not lose token A");
        assertTrue(finalBalanceB >= initialBalanceB, "Should not lose token B");

        vm.stopPrank();
    }

    function test_FlashAddThenRemove_RevertWhenNoLiquidity() public {
        Token newTokenA = new Token("New Token A", "NTKA");
        Token newTokenB = new Token("New Token B", "NTKB");

        IUniswapV2Factory factoryContract = IUniswapV2Factory(factory);
        address newPair = factoryContract.createPair(address(newTokenA), address(newTokenB));

        LiqManager newLiqManager = new LiqManager(router, newPair);

        vm.startPrank(testUser2);

        newTokenA.mint(testUser2, 1_000_000_000_000_000_000_000);
        newTokenB.mint(testUser2, 1_000_000_000_000_000_000_000);

        newTokenA.approve(address(newLiqManager), type(uint256).max);
        newTokenB.approve(address(newLiqManager), type(uint256).max);

        vm.expectRevert(LiqManager.NoLiquidityExists.selector);
        newLiqManager.flashAddThenRemove(100_000_000_000_000_000);

        vm.stopPrank();
    }

    function test_FlashAddThenRemove_RevertWhenInsufficientBalance() public {
        vm.startPrank(testUser2);

        uint256 lpAmountDesired = 2_000_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        vm.expectRevert();
        liqManager.flashAddThenRemove(lpAmountDesired);

        vm.stopPrank();
    }

    function test_FlashAddThenRemove_ContractStateCleanup() public {
        vm.startPrank(testUser2);

        uint256 lpAmountDesired = 100_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        liqManager.flashAddThenRemove(lpAmountDesired);

        assertEq(tokenA.balanceOf(address(liqManager)), 0, "Contract should have no token A");
        assertEq(tokenB.balanceOf(address(liqManager)), 0, "Contract should have no token B");

        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        assertEq(pairContract.balanceOf(address(liqManager)), 0, "Contract should have no LP tokens");

        vm.stopPrank();
    }

    function test_FlashAddThenRemove_EventEmission() public {
        vm.startPrank(testUser2);

        uint256 lpAmountDesired = 100_000_000_000_000_000;

        tokenA.approve(address(liqManager), type(uint256).max);
        tokenB.approve(address(liqManager), type(uint256).max);

        // Expect events to be emitted with the correct user and lpAmountDesired
        vm.expectEmit(true, false, false, false);
        emit LiqManager.LiquidityAdded(testUser2, lpAmountDesired, 0, 0);

        vm.expectEmit(true, false, false, false);
        emit LiqManager.LiquidityRemoved(testUser2, lpAmountDesired, 0, 0);

        liqManager.flashAddThenRemove(lpAmountDesired);

        vm.stopPrank();
    }
}
