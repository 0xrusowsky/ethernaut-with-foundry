// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract King {

    address payable king;
    uint public prize;
    address payable public owner;

    event ChangedKing(uint256 newPrize, address newKing);

    constructor() payable {
        owner = payable(msg.sender);  
        king = payable(msg.sender);
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        king.transfer(msg.value);
        king = payable(msg.sender);
        prize = msg.value;
        emit ChangedKing(msg.value, msg.sender);
    }

    function _king() public view returns (address payable) {
        return king;
    }
}