// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script,console2} from "forge-std/Script.sol";
import {USDCSwapV1} from "../src/USDCSwapV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MockUSDC} from "../test/mock/MockUSDC.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployUsdcSwap is Script {
    function run() external returns (address, address) {
        (address proxy, address usdc) = deployUsdcSwap(msg.sender);
        console2.log("proxy:",proxy);
        console2.log("usdc:",usdc);
        return (proxy, usdc);
    }

    function deployUsdcSwap(address owner) public returns (address, address) {
        vm.startBroadcast();

        //mock usdc
        MockUSDC usdc = new MockUSDC();
        
        //feed
        HelperConfig helperConfig = new HelperConfig();
        
        HelperConfig.NetworkConfig memory feedConfig = helperConfig.getConfigByChainId(block.chainid);

        //swap

        USDCSwapV1 swap = new USDCSwapV1(address(usdc), feedConfig.ethPriceFeed, feedConfig.usdcPriceFeed);
        ERC1967Proxy proxy = new ERC1967Proxy(address(swap), "");
        USDCSwapV1(address(proxy)).initialize(100, owner);
        vm.stopBroadcast();
        return (address(proxy), address(usdc) );
    }
}
