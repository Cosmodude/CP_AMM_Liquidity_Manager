# Foundry Template [![Open in Gitpod][gitpod-badge]][gitpod] [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gitpod]: https://gitpod.io/#https://github.com/Cosmodude/CP_AMM_Liquidity_Manager
[gitpod-badge]: https://img.shields.io/badge/Gitpod-Open%20in%20Gitpod-FFB45B?logo=gitpod
[gha]: https://github.com/Cosmodude/CP_AMM_Liquidity_Manager/actions
[gha-badge]: https://github.com/Cosmodude/CP_AMM_Liquidity_Manager/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Foundry-based template for developing Solidity smart contracts, with sensible defaults.

## What's Inside

- [Forge](https://github.com/foundry-rs/foundry/blob/master/forge): compile, test, fuzz, format, and deploy smart
  contracts
- [Bun]: Foundry defaults to git submodules, but this template uses Node.js packages for managing dependencies
- [Forge Std](https://github.com/foundry-rs/forge-std): collection of helpful contracts and utilities for testing
- [Prettier](https://github.com/prettier/prettier): code formatter for non-Solidity files
- [Solhint](https://github.com/protofire/solhint): linter for Solidity code

# Setup

Contracts and scripts are preconfigured for Sepolia testnet.

Install Dependencies:

```sh
bun install
```

Setup a secure secret key setup using `cast wallet import`. And fund it with ETH.

# Usage

Build

```sh
forge build
```

Test

```sh
forge test
```

## Deploy

Check balance sepolia:

```sh
cast balance <wallet_address> --rpc-url sepolia
```

Run combined setup script:

```sh
# Get your private key from Cast wallet and use it directly
forge script script/PoolInit.s.sol --rpc-url sepolia --broadcast --verify -vvvv --account <saved_wallet_name>
```

Deploy Liqudity Manager

```sh
   forge script script/DeployLiqManager.s.sol --rpc-url sepolia --broadcast --verify -vvvv --account <saved_wallet_name>
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ bun run lint
```

### Test Coverage

Generate test coverage and output result to the terminal:

```sh
$ bun run test:coverage
```

# Active deployments 

### Tokens:
https://sepolia.etherscan.io/address/0x797ec03c3b6e684a1c231f9f4047ea4ecc388f26
https://sepolia.etherscan.io/address/0x722a61c9cc95b48b3a75024d55f4e8d0e50ce994

Mint functions permissionlessly enabled for both

### Pair
https://sepolia.etherscan.io/address/0x4d3fe708c572e92237a58280bd5eef8f438125bc

### Manager 
https://sepolia.etherscan.io/address/0xd205df6f243f27855bf9b68d0c67a9ba4abf3d40#code

### Sensible Defaults

This template comes with a set of sensible default configurations for you to use. These defaults can be found in the
following files:

```text
├── .editorconfig
├── .gitignore
├── .prettierignore
├── .prettierrc.yml
├── .solhint.json
├── foundry.toml
└── remappings.txt
```

### GitHub Actions

This template comes with GitHub Actions pre-configured. Your contracts will be linted and tested on every push and pull
request made to the `main` branch.

You can edit the CI script in [.github/workflows/ci.yml](./.github/workflows/ci.yml).

## License

This project is licensed under MIT.
