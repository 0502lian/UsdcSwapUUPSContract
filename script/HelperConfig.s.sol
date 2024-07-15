// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {Script, console2} from "forge-std/Script.sol";

abstract contract CodeConstants {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    int256 public constant USDC_INITIAL_PRICE = 102e6;

    /*//////////////////////////////////////////////////////////////
                               CHAIN IDS
    //////////////////////////////////////////////////////////////*/
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}


contract HelperConfig is CodeConstants, Script {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig {
        address ethPriceFeed;
        address usdcPriceFeed;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    // Local network state variables
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        // Note: We skip doing the local config
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].ethPriceFeed != address(0)&&networkConfigs[chainId].usdcPriceFeed != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            ethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            usdcPriceFeed:0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
        });
    }

  

    /*//////////////////////////////////////////////////////////////
                              LOCAL CONFIG
    //////////////////////////////////////////////////////////////*/
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Check to see if we set an active network config
        if (localNetworkConfig.ethPriceFeed != address(0)&&localNetworkConfig.usdcPriceFeed != address(0)) {
            return localNetworkConfig;
        }

        console2.log(unicode"⚠️ You have deployed a mock conract!");
        console2.log("Make sure this was intentional");
        //vm.startBroadcast();
        MockV3Aggregator mockEthFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        MockV3Aggregator mockUSDCFeed = new MockV3Aggregator(DECIMALS, USDC_INITIAL_PRICE);
        //vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            ethPriceFeed: address(mockEthFeed),
            usdcPriceFeed:address(mockUSDCFeed)
        });
        return localNetworkConfig;
    }
}