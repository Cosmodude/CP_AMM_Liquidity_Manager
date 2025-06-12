**Interview task (Rust): Raydium Add/Remove Liquidity**
Write a Rust program which integrates with the Raydium CP-AMM on Solana Devnet and demonstrates the following:

Initialize a CP-AMM pool using an SPL token pair (you can use custom or existing Devnet SPL tokens)

Add liquidity to the CP-AMM pool by specifying the desired number of LP tokens.

Remove liquidity from the CP-AMM pool by redeeming the same amount of LP tokens.

(Bonus) Add and remove liquidity from the pool in a single Solana transaction.

You can choose if you want to do this off-chain (RPC client) or on-chain (CPI program).

Make a Pull Request to this repository with your solution. 


**Interview Task (Solidity ) — Uniswap-style CP-AMM Liquidity Manager**

Write a liquidity management assignment on an EVM chain using Solidity and a classic constant-product AMM (Uniswap V2-style).  
Work on Ethereum Sepolia, Goerli, or any compatible EVM dev-net (Base Sepolia, Polygon Amoy, etc.).  
Submit a Pull Request to this repo with your finished work.

Required Tasks

2.1 Pool Initialization
1. Deploy or obtain two ERC-20 tokens on your testnet.  
2. Use the Uniswap V2 Factor* to create a new pair (`createPair`).  
3. Seed it with initial reserves via the Router’s `addLiquidity`.  
4. Log the LP-token address & reserve amounts.

2.2 Add Liquidity by Target LP Amount
Create `LiquidityManager.sol` exposing

```solidity
function addLiquidityByMint(uint256 lpAmountDesired) external;
````

Steps inside:

1. Read `totalSupply()` and `getReserves()` to compute exact token amounts.
2. Transfer tokens from `msg.sender` (use `permit` if desired).
3. Call `router.addLiquidity` (or pair `mint`).
4. Revert if minted LP differs from `lpAmountDesired` by > 1 wei.

2.3 Remove the Same Liquidity

Add

```solidity
function removeExactLiquidity(uint256 lpAmount) external;
```

Steps inside:

1. Transfer `lpAmount` LP tokens from `msg.sender` to the pair.
2. Burn them (`pair.burn` via router).
3. Return underlying tokens to `msg.sender`.
4. Emit an event with redeemed amounts.

2.4 Unit Tests

Cover:

-Correct reserve maths for mint-targeting.
-Slippage and rounding edge cases.
-Reverts on missing approvals/balances.

3 · Bonus (+10 pts)

Implement a single-transaction add  and remove:

```solidity
function flashAddThenRemove(uint256 lpAmount) external;
```

It must add and immediately remove exactly `lpAmount` of liquidity in one atomic tx, leaving pool reserves unchanged (aside from fees).



4 · Submission Checklist

contracts/LiquidityManager.sol
scripts/00_deploy.js      (or Foundry script)
test/LiquidityManager.t.sol  (or .ts)
README.md                 (this file or equivalent)


Your README must include:

* Network & contract addresses
* Setup instructions (`npm i`, `npx hardhat test`, etc.)
* Gas summary (`hardhat-gas-reporter` or `forge test --gas-report`)

PR title format:
Solidity Liquidity Manager Task
