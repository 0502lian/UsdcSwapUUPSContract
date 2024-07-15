// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {USDCSwapV1} from "../src/USDCSwapV1.sol";
import {USDCSwapV2} from "../src/USDCSwapV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract UpgradeUsdcSwap is Script {
    // function run() external returns (address) {
    //     address mostRecentlyDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

    //     vm.startBroadcast();
    //     USDCSwapV2 newSwap = new USDCSwapV2(address(0));
    //     vm.stopBroadcast();
    //     address proxy = upgradeSwap(mostRecentlyDeployedProxy, address(newSwap));
    //     return proxy;
    // }

    function upgradeSwap(address proxyAddress, address newSwap) public returns (address) {
    //    vm.startBroadcast();
        USDCSwapV1 proxy = USDCSwapV1(payable(proxyAddress));
        proxy.upgradeToAndCall(address(newSwap),"");
    //    vm.stopBroadcast();
        return address(proxy);
    }
}
