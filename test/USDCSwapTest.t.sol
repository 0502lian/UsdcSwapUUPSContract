// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "./mock/MockV3Aggregator.sol";

import {DeployUsdcSwap} from "../script/DeployUsdcSwap.s.sol";
import {UpgradeUsdcSwap} from "../script/UpgradeUsdcSwap.s.sol";
import {USDCSwapV1} from "../src/USDCSwapV1.sol";
import {USDCSwapV2} from "../src/USDCSwapV2.sol";

contract USDCSwapTest is CodeConstants, StdCheats, Test {
 
    DeployUsdcSwap public deployUsdcSwap;
    address public proxyAddress;

    address public mockUsdc;

    address public  user = makeAddr("user");
    address public  owner = makeAddr("owner");

    function setUp() external {
        deployUsdcSwap = new DeployUsdcSwap();
        (proxyAddress, mockUsdc) = deployUsdcSwap.deployUsdcSwap(owner);
    }

    function testUsdcSwapV1Works() public {
        uint256 expectedValue = 1;
        assertEq(expectedValue, USDCSwapV1(proxyAddress).version());
    }

    function testTransferOwner() public{
        vm.prank(owner);
        USDCSwapV1(proxyAddress).transferOwnership(user);
        assertEq(user, USDCSwapV1(proxyAddress).owner());
    }

    function testOwnerDeposit() public{
        uint256 usdcAmount = 10000e6;
        
        ownerDepositUSDC(usdcAmount);
        assertEq(usdcAmount, IERC20(mockUsdc).balanceOf(proxyAddress));
        
    }

    function testNotOwnerDeposit() public{
        uint256 usdcAmount = 10000e6;
        deal(mockUsdc, user, usdcAmount);
        vm.startPrank(user);
        IERC20(mockUsdc).approve(proxyAddress, usdcAmount);

        vm.expectRevert();
        USDCSwapV1(proxyAddress).depositUSDC(usdcAmount);
        vm.stopPrank();
    }


    function testUserSwap() public{
        uint256 usdcAmount = 1000000e6;
        ownerDepositUSDC(usdcAmount);

        uint256 minUsdcOut = 1900e6;

        deal(user, 1e18);//1 eth
        vm.prank(user);
        USDCSwapV1(proxyAddress).swapETHforUSDC{value: 1e18}(minUsdcOut);

        console2.log(IERC20(mockUsdc).balanceOf(user));
        
        uint256 fee = USDCSwapV1(proxyAddress).getConvertedUSDCAmount(1e18) * USDCSwapV1(proxyAddress).swapFeePercentage()/USDCSwapV1(proxyAddress).FEE_PRECISION();
        uint256 expectUsdc = USDCSwapV1(proxyAddress).getConvertedUSDCAmount(1e18) - fee;

        assertEq(expectUsdc, IERC20(mockUsdc).balanceOf(user));

    }


    function testOwnerWithdraw() public{
        uint256 usdcAmount = 1000000e6;
        ownerDepositUSDC(usdcAmount);

        uint256 minUsdcOut = 1900e6;

        deal(user, 1e18);//1 eth
        vm.prank(user);
        USDCSwapV1(proxyAddress).swapETHforUSDC{value: 1e18}(minUsdcOut);

        console2.log(IERC20(mockUsdc).balanceOf(user));
        
        uint256 fee = USDCSwapV1(proxyAddress).getConvertedUSDCAmount(1e18) * USDCSwapV1(proxyAddress).swapFeePercentage()/USDCSwapV1(proxyAddress).FEE_PRECISION();
        uint256 expectUsdc = USDCSwapV1(proxyAddress).getConvertedUSDCAmount(1e18) - fee;

        assertEq(expectUsdc, IERC20(mockUsdc).balanceOf(user));

        //withdraw eth
        uint256 ethBalance = owner.balance;
        vm.prank(owner);
        USDCSwapV1(proxyAddress).withdrawETH(1e18);
        uint256 ethBalanceAfter = owner.balance;
        assertEq(ethBalance+1e18, ethBalanceAfter);

        //withdraw usdc
        uint256 usdcBalance = IERC20(mockUsdc).balanceOf(proxyAddress);
        vm.prank(owner);
        USDCSwapV1(proxyAddress).withdrawUSDC(usdcBalance);
        assertEq(usdcBalance, IERC20(mockUsdc).balanceOf(owner));

    }




    function ownerDepositUSDC(uint256 usdcAmount) internal{
        deal(mockUsdc, owner, usdcAmount);
        vm.startPrank(owner);
        IERC20(mockUsdc).approve(proxyAddress, usdcAmount);
        USDCSwapV1(proxyAddress).depositUSDC(usdcAmount);
        vm.stopPrank();
    }







}