// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script,console2} from "forge-std/Script.sol";
import {USDCSwapV1} from "../src/USDCSwapV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MockUSDC} from "../test/mock/MockUSDC.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployUsdcSwap is Script {

    address constant proxy = 0x6E05420d6E7E6b2ebCeE9B97B1E9E1d4179ce505;
    address constant usdc = 0xf3F1bA94A626d6F92E60a89152F1D4Ee5ceC42e2;

    function run() public {


        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        USDCSwapV1 swap = USDCSwapV1(proxy);
        MockUSDC usdc = MockUSDC(usdc);

        vm.startBroadcast(deployerPrivateKey);

        //Provide liquidity
        // usdc.approve(proxy, 100000e6);
        // swap.depositUSDC(100000e6); 

        //change a account, swap usdc
        swap.swapETHforUSDC{value: 1e17}(200e6);

        vm.stopBroadcast();
    }



}