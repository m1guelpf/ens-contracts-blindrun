// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./Hevm.sol";
import "./Namehash.sol";
import "ds-test/test.sol";
import "../ENSRegistry.sol";
import "../ENSRegistrar.sol";

contract User {}

contract ENSRegistrarTest is DSTest {
    User internal user;
    Hevm internal hevm;
    ENSRegistry internal registry;
    ENSRegistrar internal registrar;

    function setUp() public {
        user = new User();
        hevm = Hevm(HEVM_ADDRESS);
        registry = new ENSRegistry(address(this));
        registrar = new ENSRegistrar(registry, 0);

        registry.setOwner(0, address(registrar));

        registrar.register(keccak256("test"), address(this));
    }

    function testCanRegisterNames() public {
        bytes32 namehash = Namehash.hash("test2");

        assertEq(registry.owner(namehash), address(0));
        registrar.register(keccak256("test2"), address(this));
        assertEq(registry.owner(namehash), address(this));
    }

    function testCanTransferNames() public {
        assertEq(registry.owner(Namehash.hash("test")), address(this));
        registrar.register(keccak256("test"), address(user));
        assertEq(registry.owner(Namehash.hash("test")), address(user));
    }

    function testCannotTransferSomeonesName() public {
        assertEq(registry.owner(Namehash.hash("test")), address(this));

        hevm.prank(address(user));
        hevm.expectRevert("Unauthorized.");
        registrar.register(keccak256("test"), address(user));

        assertEq(registry.owner(Namehash.hash("test")), address(this));
    }
}
