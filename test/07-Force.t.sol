// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/07-Force/ForceFactory.sol";

contract BaseSetUp is Test {
    Ethernaut ethernaut;
    address payable attacker;

    function setUp() public virtual {
        // Initialize Ethernaut contract
        ethernaut = new Ethernaut();

        // Initialize Attacker EOA
        attacker = payable(vm.addr(1));      
        vm.deal(attacker, 10 ether);
        vm.label(attacker, "Attacker");
    }
}

contract Attack is BaseSetUp {
    Force ethernautForce;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(forceFactory));
        ethernautForce = Force(levelAddress);
        console.log("Ethernaut Force Challenge!");
    }

    function testAttack() public {

        

    }
}