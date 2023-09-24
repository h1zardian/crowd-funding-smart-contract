// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // latestRoundData() returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)

        // price of ETH in terms of USD
        return uint256(answer * 1e10);
    }

    // How does this work?
    // Let's ask, what's the value of 1 ETH?
    // Say if the priceFeed.latestRoundData() gave us the value of $2000_00000000,
    // we will need to multiply it by 1e10 to match its decimal places with msg.value which is in Wei.

    function getConversionRate(
        uint256 ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    // Now that we have the value of 1 ETH, is $2000_000000000000000000
    // We can do some maths to find the value of ETH we intend to send
    // (2000_000000000000000000 * 1_000000000000000000(1 ETH in Wei)) / 1e18
    // will give us the value $2000_000000000000000000 = 1ETH
}

