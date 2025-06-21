// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { Token } from "../src/TokenA.sol";
import { IUniswapV2Factory } from "../src/interfaces/IUniswapV2Factory.sol";
import { console } from "forge-std/src/console.sol";

contract DeployTokensAndPair is Script {
    function run() public returns (Token tokenA, Token tokenB, address pair) {
        vm.startBroadcast();

        address factoryAddress = vm.envAddress("UNISWAP_V2_FACTORY_ADDRESS_SEPOLIA");
        
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");
        
        console.log("Token A deployed at:", address(tokenA));
        console.log("Token B deployed at:", address(tokenB));
        
        IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);
        
        address existingPair = factory.getPair(address(tokenA), address(tokenB));
        require(existingPair == address(0), "Pair already exists");

        pair = factory.createPair(address(tokenA), address(tokenB));
        
        console.log("Created pair at address:", pair);
        console.log("Factory address:", factoryAddress);

        vm.stopBroadcast();
    }
} 