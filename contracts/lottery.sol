//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

contract Lottery {
    address payable[] public players;

    function enterLottery() public payable{
        players.push(msg.sender);
    }

    function getEntranceFee() public {}

    function startLottery() public {}

    function endLottety() public {}
}
