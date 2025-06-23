// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { LiqManager } from "../src/LiqManager.sol";
import { console } from "forge-std/src/console.sol";

contract DeployLiqManager is Script {
    function run() public returns (LiqManager liqManager) {
        address caller = vm.envAddress("DEV_ADDRESS");

        vm.startBroadcast(caller);

        address routerAddress = vm.envAddress("UNISWAP_V2_ROUTER_ADDRESS_SEPOLIA");
        address pairAddress = vm.envAddress("PAIR_ADDRESS");

        console.log("Deploying LiqManager with:");
        console.log("Router address:", routerAddress);
        console.log("Pair address:", pairAddress);
        console.log("Deployer:", caller);

        liqManager = new LiqManager(routerAddress, pairAddress);

        console.log("LiqManager deployed at:", address(liqManager));

        vm.stopBroadcast();
    }
}
