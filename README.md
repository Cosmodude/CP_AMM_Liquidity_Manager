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

Setup a secure secret key setup using `cast wallet`. And fund it with ETH.

# Run

Check balance sepolia: 
```sh
cast balance <wallet_address> --rpc-url sepolia
```

Run combined setup script:
```sh 
# Get your private key from Cast wallet and use it directly
forge script script/PoolInit.s.sol --rpc-url sepolia --account <saved_wallet_name> --broadcast
```

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

## Usage

This is a list of the most frequently needed Forge commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
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

## Related Efforts

- [foundry-rs/forge-template](https://github.com/foundry-rs/forge-template)
- [abigger87/femplate](https://github.com/abigger87/femplate)
- [cleanunicorn/ethereum-smartcontract-template](https://github.com/cleanunicorn/ethereum-smartcontract-template)
- [FrankieIsLost/forge-template](https://github.com/FrankieIsLost/forge-template)

## License

This project is licensed under MIT.
