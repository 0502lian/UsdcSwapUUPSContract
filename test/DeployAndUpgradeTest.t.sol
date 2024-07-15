// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployUsdcSwap} from "../script/DeployUsdcSwap.s.sol";
import {UpgradeUsdcSwap} from "../script/UpgradeUsdcSwap.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {USDCSwapV1} from "../src/USDCSwapV1.sol";
import {USDCSwapV2} from "../src/USDCSwapV2.sol";

contract DeployAndUpgradeTest is StdCheats, Test {

    DeployUsdcSwap public deployUsdcSwap;
    address public proxyAddress;
    address public mockUsdc;
   
    UpgradeUsdcSwap public upgradeUsdcSwap;
    address public owner = makeAddr("owner"); 

    function setUp() public {
        deployUsdcSwap = new DeployUsdcSwap();
        upgradeUsdcSwap = new UpgradeUsdcSwap();
       
        (proxyAddress, mockUsdc) = deployUsdcSwap.deployUsdcSwap(owner);
    }

    function testUsdcSwapV1Works() public {
        uint256 expectedValue = 1;
        assertEq(expectedValue, USDCSwapV1(proxyAddress).version());
    }


    function testUpgradeWorks() public {
       
        address ethFeed = USDCSwapV1(proxyAddress).ethFeed();
        address usdcFeed = USDCSwapV1(proxyAddress).usdcFeed();

        USDCSwapV2 swapV2 = new USDCSwapV2(mockUsdc, ethFeed, usdcFeed);

        vm.prank(USDCSwapV1(proxyAddress).owner());

        USDCSwapV1(payable(proxyAddress)).upgradeToAndCall(address(swapV2), "");
       
        uint256 expectedValue = 2;
        assertEq(expectedValue, USDCSwapV2(proxyAddress).version());

    }
}
