//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;
    uint256 public minUsdEntry;
    uint256 public fee;
    bytes32 public keyhash;

    AggregatorV3Interface internal ethUsdPriceFeed;

    enum LOTTERY_STATE {
        open,
        close,
        calculating_winner
    }

    LOTTERY_STATE public lotteryState;

    event RequestedRandomness(bytes32 requestId);

    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
        minUsdEntry = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lotteryState = LOTTERY_STATE.close;
        fee = _fee;
        keyhash = _keyhash;
    }

    function enterLottery() public payable {
        require(lotteryState == LOTTERY_STATE.open, "Lottery not open");
        require(msg.value > minUsdEntryCost(), "Not enough msg.value");
        players.push(msg.sender);
    }

    function minUsdEntryCost() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10;
        uint256 costToEnter = (minUsdEntry * 10**18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public onlyOwner {
        require(lotteryState == LOTTERY_STATE.close);
        lotteryState = LOTTERY_STATE.open;
    }

    function endLottety() public onlyOwner {
        lotteryState = LOTTERY_STATE.calculating_winner;
        bytes32 requestId = requestRandomness(keyhash, fee);
        emit RequestedRandomness(requestId);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(
            lotteryState == LOTTERY_STATE.calculating_winner,
            "You aren't there yet!"
        );
        require(_randomness > 0, "random-not-found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.close;
        randomness = _randomness;
    }
}
