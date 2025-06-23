// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { IUniswapV2Router02 } from "../src/interfaces/IUniswapV2Router02.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";
import { console } from "forge-std/src/console.sol";

contract SeedLiquidity is Script {
    function run() public {
        vm.startBroadcast();

        address routerAddress = vm.envAddress("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA");
        address tokenA = vm.envAddress("TOKEN_A_ADDRESS");
        address tokenB = vm.envAddress("TOKEN_B_ADDRESS");

        uint256 amountADesired = 100_000_000_000_000_000;
        uint256 amountBDesired = 100_000_000_000_000_000;

        console.log("Router address:", routerAddress);
        console.log("Token A:", tokenA);
        console.log("Token B:", tokenB);
        console.log("Amount A desired:", amountADesired);
        console.log("Amount B desired:", amountBDesired);

        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        IERC20(tokenA).approve(routerAddress, amountADesired);
        IERC20(tokenB).approve(routerAddress, amountBDesired);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            0, // amountAMin - no slippage protection for seeding
            0, // amountBMin - no slippage protection for seeding
            msg.sender,
            block.timestamp + 300
        );

        console.log("Added liquidity - Amount A:", amountA);
        console.log("Added liquidity - Amount B:", amountB);
        console.log("Liquidity tokens received:", liquidity);

        vm.stopBroadcast();
    }
}
