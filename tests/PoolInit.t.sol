// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console } from "forge-std/src/console.sol";
import { PoolInit } from "../script/PoolInit.s.sol";
import { Token } from "../src/TokenA.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";

contract PoolInitTest is Test {
    PoolInit public poolInit;

    Token public tokenA;
    Token public tokenB;
    address public pair;
    uint256 public liquidity;

    // Sepolia addresses
    address public constant UNISWAP_V2_FACTORY_SEPOLIA = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address public constant UNISWAP_V2_ROUTER_SEPOLIA = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    // Test account
    address public testUser = makeAddr("testUser");

    function setUp() public {
        // Fork Sepolia
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));

        // Set up test user
        vm.deal(testUser, 100 ether);

        // Deploy the script contract
        poolInit = new PoolInit();

        // Set environment variables
        vm.setEnv("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA", vm.toString(UNISWAP_V2_ROUTER_SEPOLIA));
        vm.setEnv("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA", vm.toString(UNISWAP_V2_FACTORY_SEPOLIA));
        vm.setEnv("DEV_ADDRESS", vm.toString(testUser));

        (tokenA, tokenB, pair, liquidity) = poolInit.run();
    }

    function test_PoolInit_DeployTokensAndAddLiquidity() public {
        // Debug: Check balances and approvals
        console.log("=== DEBUG INFO ===");
        console.log("Test user address:", testUser);
        console.log("Token A balance:", tokenA.balanceOf(testUser));
        console.log("Token B balance:", tokenB.balanceOf(testUser));
        console.log("Token A allowance for router:", tokenA.allowance(testUser, UNISWAP_V2_ROUTER_SEPOLIA));
        console.log("Token B allowance for router:", tokenB.allowance(testUser, UNISWAP_V2_ROUTER_SEPOLIA));

        // Verify tokens were deployed
        assertTrue(address(tokenA) != address(0), "Token A should be deployed");
        assertTrue(address(tokenB) != address(0), "Token B should be deployed");
        assertTrue(tokenA != tokenB, "Tokens should be different");

        // Verify pair was created
        assertTrue(pair != address(0), "Pair should be created");

        // Verify liquidity was added
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");

        // Verify token balances
        uint256 expectedMintAmount = 500_000_000_000_000_000; // 0.5 tokens with 18 decimals (remaining after adding
            // liquidity)
        assertEq(
            tokenA.balanceOf(testUser), expectedMintAmount, "User should have remaining tokens A after adding liquidity"
        );
        assertEq(
            tokenB.balanceOf(testUser), expectedMintAmount, "User should have remaining tokens B after adding liquidity"
        );

        // Verify pair reserves
        IUniswapV2Pair pairContract = IUniswapV2Pair(pair);
        (uint112 reserve0, uint112 reserve1,) = pairContract.getReserves();

        uint256 expectedLiquidityAmount = 500_000_000_000_000_000; // 0.5 tokens with 18 decimals
        assertTrue(
            reserve0 >= expectedLiquidityAmount && reserve1 >= expectedLiquidityAmount,
            "Both reserves should contain added liquidity"
        );
        assertEq(reserve0, expectedLiquidityAmount, "Reserve0 should equal expected liquidity amount");
        assertEq(reserve1, expectedLiquidityAmount, "Reserve1 should equal expected liquidity amount");

        // Verify pair tokens
        address token0 = pairContract.token0();
        address token1 = pairContract.token1();
        assertTrue(token0 == address(tokenA) || token0 == address(tokenB), "Pair should contain our tokens");
        assertTrue(token1 == address(tokenA) || token1 == address(tokenB), "Pair should contain our tokens");

        console.log("Reserve0:", reserve0);
        console.log("Reserve1:", reserve1);
    }

    function test_PoolInit_TokenNamesAndSymbols() public {
        assertEq(tokenA.name(), "Token A", "Token A should have correct name");
        assertEq(tokenA.symbol(), "TKA", "Token A should have correct symbol");
        assertEq(tokenB.name(), "Token B", "Token B should have correct name");
        assertEq(tokenB.symbol(), "TKB", "Token B should have correct symbol");
    }

    function test_PoolInit_MintFunctionality() public {
        // Test that anyone can mint (unrestricted mint)
        address randomUser = makeAddr("randomUser");
        vm.startPrank(randomUser);

        uint256 mintAmount = 100_000_000_000_000_000_000; // 100 tokens
        tokenA.mint(randomUser, mintAmount);
        tokenB.mint(randomUser, mintAmount);

        assertEq(tokenA.balanceOf(randomUser), mintAmount, "Random user should be able to mint token A");
        assertEq(tokenB.balanceOf(randomUser), mintAmount, "Random user should be able to mint token B");

        vm.stopPrank();
    }
}
