// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { console } from "forge-std/src/console.sol";
import { Script } from "forge-std/src/Script.sol";

contract CreatePairOnly is Script {
    function run() public returns (address pair) {
        vm.startBroadcast();

        address factoryAddress = vm.envAddress("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA");
        address tokenA = vm.envAddress("TOKEN_A_ADDRESS");
        address tokenB = vm.envAddress("TOKEN_B_ADDRESS");

        console.log("Factory address:", factoryAddress);
        console.log("Token A address:", tokenA);
        console.log("Token B address:", tokenB);

        IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);

        address existingPair = factory.getPair(tokenA, tokenB);
        if (existingPair != address(0)) {
            console.log("Pair already exists at:", existingPair);
            return existingPair;
        }

        pair = factory.createPair(tokenA, tokenB);

        console.log("Created new pair at address:", pair);

        vm.stopBroadcast();
    }
}
