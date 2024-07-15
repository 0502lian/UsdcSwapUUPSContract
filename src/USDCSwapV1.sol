// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PriceConverter} from "./PriceConverter.sol";

//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract USDCSwapV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable{
    using SafeERC20 for IERC20;

    uint256 public constant ETH_PRECISION =1e18;
    uint8 public constant USDC_DECIMALs = 6;

    IERC20 public immutable usdcToken;
    address public immutable usdcFeed;
    address public immutable ethFeed;

    //AggregatorV3Interface internal priceFeed;
    uint256 public swapFeePercentage; // Fee percentage times 100 (e.g., 1% fee is 100)
    uint256 public constant FEE_PRECISION = 10000;

    event Deposited(address indexed user, uint256 ethAmount);
    event Swapped(address indexed user, uint256 ethAmount, uint256 usdcAmount);
    event Withdrawn(address indexed user, uint256 amount, bool isEth);

   constructor(address _usdcTokenAddress, address _ethFeed, address _usdcFeed) {
        require(_ethFeed!=address(0)&&_usdcFeed!=address(0),"error address");
        ethFeed = _ethFeed;
        usdcFeed = _usdcFeed;
        usdcToken = IERC20(_usdcTokenAddress);
        _disableInitializers();
    }

    function initialize(uint256 _swapFeePercentage, address _owner) public initializer {
        require(_owner!=address(0)," zero address!");
        require(_swapFeePercentage < FEE_PRECISION);
        swapFeePercentage = _swapFeePercentage;
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
    }



    function depositUSDC(uint256 amount) external onlyOwner {
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
    }

    //minOutAmount for Slippage protection
    function swapETHforUSDC(uint256 minOutAmount) external payable {
        uint256 ethAmount = msg.value;
        uint256 usdcAmount = getConvertedUSDCAmount(ethAmount);
        uint256 fee = (usdcAmount * swapFeePercentage) / FEE_PRECISION;
        usdcAmount -= fee;

        require(usdcAmount >= minOutAmount, "usdcAmount is too small ");

        usdcToken.transfer(msg.sender, usdcAmount);

        emit Swapped(msg.sender, ethAmount, usdcAmount);
    }

    function getConvertedUSDCAmount(uint256 ethAmount) public view returns (uint256) {
        // Assuming price is the amount of USDC for 1 ETH, scaled by 1e8, usdc decimals is 6
        uint256 price = PriceConverter.getDerivedPrice(ethFeed, usdcFeed, USDC_DECIMALs);
        return (ethAmount * price) / ETH_PRECISION;
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
        emit Withdrawn(owner(), amount, true);
    }

    function withdrawUSDC(uint256 amount) external onlyOwner {
        usdcToken.transfer(owner(), amount);
        emit Withdrawn(owner(), amount, false);
    }

    
    function version() public pure returns (uint256) {
        return 1;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}