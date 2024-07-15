// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 digit
        require(answer > 0, "Invalid price");
        return uint256(answer);
    }

   //notice: usdc is not usd. ethusd/usdcusd
    function getDerivedPrice(
        address _base,
        address _quote,
        uint8 _decimals
    ) public view returns (uint256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        uint256 decimals = uint256(10 ** uint256(_decimals));

        (, int256 basePrice, , , ) = AggregatorV3Interface(_base)
            .latestRoundData();

        require(basePrice > 0, "Invalid price");    
        uint8 baseDecimals = AggregatorV3Interface(_base).decimals();
        

        (, int256 quotePrice, , , ) = AggregatorV3Interface(_quote)
            .latestRoundData();
        require(quotePrice > 0, "Invalid price");  
        uint8 quoteDecimals = AggregatorV3Interface(_quote).decimals();


        uint256 basePricePrecision = uint256(10 ** uint256(baseDecimals));
        uint256 quotePricePrecision = uint256(10 ** uint256(quoteDecimals));
        
       
        return (uint256(basePrice) * decimals *quotePricePrecision) / (uint256(quotePrice) * basePricePrecision);
    }

  
}