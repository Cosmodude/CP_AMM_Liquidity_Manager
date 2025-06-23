// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { LiqManager } from "../src/LiqManager.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";
import { IUniswapV2Pair } from "../src/interfaces/IUniswapV2Pair.sol";
import { console } from "forge-std/src/console.sol";

contract AddLiquidityThroughManager is Script {
    function run() public {
        address caller = vm.envAddress("DEV_ADDRESS");
        address liqManagerAddress = vm.envAddress("LIQ_MANAGER_ADDRESS");
        uint256 lpAmountDesired = 100_000_000_000_000_000; // 0.3

        vm.startBroadcast(caller);

        console.log("Adding liquidity through manager:");
        console.log("Caller:", caller);
        console.log("Manager address:", liqManagerAddress);
        console.log("LP amount desired:", lpAmountDesired);

        LiqManager liqManager = LiqManager(liqManagerAddress);
        IUniswapV2Pair pair = IUniswapV2Pair(liqManager.PAIR());
        IERC20 tokenA = IERC20(liqManager.TOKEN_A());
        IERC20 tokenB = IERC20(liqManager.TOKEN_B());

        console.log("Pair address:", address(pair));
        console.log("Token A address:", address(tokenA));
        console.log("Token B address:", address(tokenB));

        uint256 balanceA = tokenA.balanceOf(caller);
        uint256 balanceB = tokenB.balanceOf(caller);
        uint256 lpBalanceBefore = pair.balanceOf(caller);

        console.log("Balance A before:", balanceA);
        console.log("Balance B before:", balanceB);
        console.log("LP balance before:", lpBalanceBefore);

        tokenA.approve(liqManagerAddress, type(uint256).max);
        tokenB.approve(liqManagerAddress, type(uint256).max);

        liqManager.addLiquidityByMint(lpAmountDesired);

        uint256 balanceAAfter = tokenA.balanceOf(caller);
        uint256 balanceBAfter = tokenB.balanceOf(caller);
        uint256 lpBalanceAfter = pair.balanceOf(caller);

        console.log("Balance A after:", balanceAAfter);
        console.log("Balance B after:", balanceBAfter);
        console.log("LP balance after:", lpBalanceAfter);
        console.log("Tokens A spent:", balanceA - balanceAAfter);
        console.log("Tokens B spent:", balanceB - balanceBAfter);
        console.log("LP tokens received:", lpBalanceAfter - lpBalanceBefore);

        vm.stopBroadcast();
    }
}
