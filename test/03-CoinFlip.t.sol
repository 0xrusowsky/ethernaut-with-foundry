// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/03-CoinFlip/CoinFlipFactory.sol";
import "src/03-CoinFlip/Attacker.sol";

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

    CoinFlip ethernautCoinFlip;
    Attacker attackerContract;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        // Initialize level
        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(coinFlipFactory));
        ethernautCoinFlip = CoinFlip(levelAddress);
        console.log("Ethernaut CoinFlip Challenge!");
    }

    function testAttack() public {
        
        vm.startPrank(attacker);

        assert(ethernautCoinFlip.consecutiveWins() == 0);
        
        // Initialize and use the Attacker contract to predict the outcome 10 times
        attackerContract = new Attacker(address(ethernautCoinFlip));

        for (uint i = 1; i<=10; i++) {
            vm.roll(1234*(i));
            attackerContract.flipAttack();
        }
        assert(ethernautCoinFlip.consecutiveWins() == 10);

        // Submit Level
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);

        vm.stopPrank();
    }
}

