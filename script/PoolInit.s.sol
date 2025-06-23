// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { Token } from "../src/TokenA.sol";
import { IUniswapV2Router02 } from "../src/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { console } from "forge-std/src/console.sol";

contract PoolInit is Script {
    error TokenABalanceMismatch();
    error TokenBBalanceMismatch();

    struct DeploymentData {
        address caller;
        address routerAddress;
        address factoryAddress;
        uint256 mintAmount;
        uint256 liquidityAmountA;
        uint256 liquidityAmountB;
    }

    function run() public returns (Token tokenA, Token tokenB, address pair, uint256 liquidity) {
        DeploymentData memory data = DeploymentData({
            caller: vm.envAddress("DEV_ADDRESS"),
            routerAddress: vm.envAddress("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA"),
            factoryAddress: vm.envAddress("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA"),
            mintAmount: 1_000_000_000_000_000_000,
            liquidityAmountA: 500_000_000_000_000_000,
            liquidityAmountB: 500_000_000_000_000_000
        });

        vm.startPrank(data.caller);

        console.log("Router address:", data.routerAddress);
        console.log("Mint amount per token:", data.mintAmount);
        console.log("Liquidity amount A:", data.liquidityAmountA);
        console.log("Liquidity amount B:", data.liquidityAmountB);

        // Deploy tokens
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");

        console.log("Token A deployed at:", address(tokenA));
        console.log("Token B deployed at:", address(tokenB));

        // Mint tokens to the caller
        tokenA.mint(data.caller, data.mintAmount);
        tokenB.mint(data.caller, data.mintAmount);

        if (tokenA.balanceOf(data.caller) != data.mintAmount) revert TokenABalanceMismatch();
        if (tokenB.balanceOf(data.caller) != data.mintAmount) revert TokenBBalanceMismatch();

        console.log("Minted", data.mintAmount, "tokens of each type to", data.caller);

        // Add liquidity through router (creates pair automatically)
        IUniswapV2Router02 router = IUniswapV2Router02(data.routerAddress);

        tokenA.approve(data.routerAddress, data.liquidityAmountA);
        tokenB.approve(data.routerAddress, data.liquidityAmountB);

        (uint256 amountA, uint256 amountB, uint256 liquidityReceived) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            data.liquidityAmountA,
            data.liquidityAmountB,
            0, // amountAMin - no slippage protection for seeding
            0, // amountBMin - no slippage protection for seeding
            data.caller,
            block.timestamp + 300
        );

        liquidity = liquidityReceived;

        // Get pair address
        IUniswapV2Factory factory = IUniswapV2Factory(data.factoryAddress);
        pair = factory.getPair(address(tokenA), address(tokenB));

        console.log("Added liquidity - Amount A:", amountA);
        console.log("Added liquidity - Amount B:", amountB);
        console.log("Liquidity pair:", pair);
        console.log("Liquidity tokens received:", liquidity);

        vm.stopPrank();
    }
}
