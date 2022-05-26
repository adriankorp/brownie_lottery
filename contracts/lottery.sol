//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    address payable[] public players;
    uint256 public minUsdEntry;
    AggregatorV3Interface internal ethUsdPriceFeed;

    constructor(address _priceFeedAddress) public {
        minUsdEntry = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function enterLottery() public payable {
        require(msg.value > minUsdEntryCost(), "Not enough msg.value");
        players.push(msg.sender);
    }

    function minUsdEntryCost() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10;
        uint256 costToEnter = (minUsdEntry * 10**18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public {}

    function endLottety() public {}
}
