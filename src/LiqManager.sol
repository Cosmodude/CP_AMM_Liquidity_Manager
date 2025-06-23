// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract LiqManager {
    IUniswapV2Router02 public immutable router;
    IUniswapV2Pair public immutable pair;
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    event LiquidityAdded(address indexed user, uint256 lpAmount, uint256 amountA, uint256 amountB);

    event LiquidityRemoved(address indexed user, uint256 lpAmount, uint256 amountA, uint256 amountB);

    constructor(address _router, address _pair) {
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Pair(_pair);
        tokenA = IERC20(pair.token0());
        tokenB = IERC20(pair.token1());
    }

    function addLiquidityByMint(uint256 lpAmountDesired) external {
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint256 totalSupply = pair.totalSupply();

        require(totalSupply > 0, "No liquidity exists");

        uint256 amountADesired = (lpAmountDesired * reserve0) / totalSupply;
        uint256 amountBDesired = (lpAmountDesired * reserve1) / totalSupply;

        require(amountADesired > 0 && amountBDesired > 0, "Insufficient liquidity");

        tokenA.transferFrom(msg.sender, address(this), amountADesired);
        tokenB.transferFrom(msg.sender, address(this), amountBDesired);

        tokenA.approve(address(router), amountADesired);
        tokenB.approve(address(router), amountBDesired);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity(
            address(tokenA), address(tokenB), amountADesired, amountBDesired, 0, 0, msg.sender, block.timestamp + 300
        );

        require(liquidity >= lpAmountDesired - 1 && liquidity <= lpAmountDesired + 1, "LP amount mismatch");

        if (amountA < amountADesired) {
            tokenA.transfer(msg.sender, amountADesired - amountA);
        }
        if (amountB < amountBDesired) {
            tokenB.transfer(msg.sender, amountBDesired - amountB);
        }

        emit LiquidityAdded(msg.sender, lpAmountDesired, amountA, amountB);
    }

    function removeExactLiquidity(uint256 lpAmount) external {
        pair.transferFrom(msg.sender, address(pair), lpAmount);
        (uint256 amountA, uint256 amountB) = pair.burn(msg.sender);

        emit LiquidityRemoved(msg.sender, lpAmount, amountA, amountB);
    }
}
