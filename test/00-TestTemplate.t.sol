// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/16-Preservation/PreservationFactory.sol";
import "src/16-Preservation/Attacker.sol";

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

    Preservation ethernautPreservation;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        PreservationFactory preservationFactory = new PreservationFactory();
        ethernaut.registerLevel(preservationFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(preservationFactory));
        ethernautPreservation = Preservation(levelAddress);
        console.log("Ethernaut Preservation Challenge!");
    }

    function testAttack() public {


        
        // Submit Level
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);

        vm.stopPrank();
    }
}