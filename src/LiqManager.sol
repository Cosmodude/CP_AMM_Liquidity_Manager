// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { IUniswapV2Router02 } from "./interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Pair } from "./interfaces/IUniswapV2Pair.sol";
import { IERC20 } from "./interfaces/IERC20.sol";

contract LiqManager {
    error NoLiquidityExists();
    error InsufficientLiquidity();
    error LPAmountMismatch();

    IUniswapV2Router02 public immutable ROUTER;
    IUniswapV2Pair public immutable PAIR;
    IERC20 public immutable TOKEN_A;
    IERC20 public immutable TOKEN_B;

    event LiquidityAdded(address indexed user, uint256 lpAmount, uint256 amountA, uint256 amountB);

    event LiquidityRemoved(address indexed user, uint256 lpAmount, uint256 amountA, uint256 amountB);

    constructor(address _router, address _pair) {
        ROUTER = IUniswapV2Router02(_router);
        PAIR = IUniswapV2Pair(_pair);
        TOKEN_A = IERC20(PAIR.token0());
        TOKEN_B = IERC20(PAIR.token1());
    }

    function addLiquidityByMint(uint256 lpAmountDesired) external {
        (uint112 reserve0, uint112 reserve1,) = PAIR.getReserves();
        uint256 totalSupply = PAIR.totalSupply();

        if (totalSupply == 0) revert NoLiquidityExists();

        uint256 amountADesired = (lpAmountDesired * reserve0) / totalSupply;
        uint256 amountBDesired = (lpAmountDesired * reserve1) / totalSupply;

        if (amountADesired == 0 || amountBDesired == 0) revert InsufficientLiquidity();

        TOKEN_A.transferFrom(msg.sender, address(this), amountADesired);
        TOKEN_B.transferFrom(msg.sender, address(this), amountBDesired);

        TOKEN_A.approve(address(ROUTER), amountADesired);
        TOKEN_B.approve(address(ROUTER), amountBDesired);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = ROUTER.addLiquidity(
            address(TOKEN_A), address(TOKEN_B), amountADesired, amountBDesired, 0, 0, msg.sender, block.timestamp + 300
        );

        if (liquidity < lpAmountDesired - 1 || liquidity > lpAmountDesired + 1) revert LPAmountMismatch();

        if (amountA < amountADesired) {
            TOKEN_A.transfer(msg.sender, amountADesired - amountA);
        }
        if (amountB < amountBDesired) {
            TOKEN_B.transfer(msg.sender, amountBDesired - amountB);
        }

        emit LiquidityAdded(msg.sender, lpAmountDesired, amountA, amountB);
    }

    function removeExactLiquidity(uint256 lpAmount) external {
        PAIR.transferFrom(msg.sender, address(PAIR), lpAmount);
        (uint256 amountA, uint256 amountB) = PAIR.burn(msg.sender);

        emit LiquidityRemoved(msg.sender, lpAmount, amountA, amountB);
    }
}
