// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { Token } from "../src/TokenA.sol";
import { IUniswapV2Router02 } from "../src/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";
import { console } from "forge-std/src/console.sol";

contract PoolInit is Script {
    function run() public returns (Token tokenA, Token tokenB, address pair, uint256 liquidity) {
        vm.startBroadcast();

        address routerAddress = vm.envAddress("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA");
        uint256 mintAmount = 1_000_000_000_000_000_000;
        uint256 liquidityAmountA = 500_000_000_000_000_000;
        uint256 liquidityAmountB = 500_000_000_000_000_000;

        console.log("Router address:", routerAddress);
        console.log("Mint amount per token:", mintAmount);
        console.log("Liquidity amount A:", liquidityAmountA);
        console.log("Liquidity amount B:", liquidityAmountB);

        // Deploy tokens
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");
        
        console.log("Token A deployed at:", address(tokenA));
        console.log("Token B deployed at:", address(tokenB));

        // Mint tokens to msg.sender
        tokenA.mint(msg.sender, mintAmount);
        tokenB.mint(msg.sender, mintAmount);
        
        console.log("Minted", mintAmount, "tokens of each type to", msg.sender);

        // Add liquidity through router (creates pair automatically)
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        tokenA.approve(routerAddress, liquidityAmountA);
        tokenB.approve(routerAddress, liquidityAmountB);

        (uint256 amountA, uint256 amountB, uint256 liquidityReceived) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            liquidityAmountA,
            liquidityAmountB,
            0, // amountAMin - no slippage protection for seeding
            0, // amountBMin - no slippage protection for seeding
            msg.sender,
            block.timestamp + 300
        );

        liquidity = liquidityReceived;

        // Get pair address
        address factoryAddress = vm.envAddress("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA");
        IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);
        pair = factory.getPair(address(tokenA), address(tokenB));

        console.log("Added liquidity - Amount A:", amountA);
        console.log("Added liquidity - Amount B:", amountB);
        console.log("Liquidity pair:", pair);
        console.log("Liquidity tokens received:", liquidity);

        vm.stopBroadcast();
    }
} 