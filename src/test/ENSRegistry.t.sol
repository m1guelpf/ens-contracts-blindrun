// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./Hevm.sol";
import "./Namehash.sol";
import "ds-test/test.sol";
import "../ENSRegistry.sol";

contract User {}

contract ENSRegistryTest is DSTest {
    User internal user;
    Hevm internal hevm;
    ENSRegistry internal registry;

    event Transfer(bytes32 indexed node, address owner);
    event NewResolver(bytes32 indexed node, address resolver);
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    function setUp() public {
        user = new User();
        hevm = Hevm(HEVM_ADDRESS);
        registry = new ENSRegistry(address(this));
    }

    function testOwnersCanTransfer() public {
        assertEq(registry.owner(0), address(this));
        hevm.expectEmit(true, false, false, true);
        emit Transfer(0, address(user));

        registry.setOwner(0, address(user));

        assertEq(registry.owner(0), address(user));
    }

    function testNonOwnersCannotTransfer() public {
        assertEq(registry.owner(0), address(this));

        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        registry.setOwner(0, address(this));

        assertEq(registry.owner(0), address(this));
    }

    function testCanSetResolver() public {
        assertEq(registry.resolver(0), address(0));
        hevm.expectEmit(true, false, false, true);
        emit NewResolver(0, address(user));

        registry.setResolver(0, address(user));

        assertEq(registry.resolver(0), address(user));
    }

    function testNonOwnersCannotSetResolver() public {
        assertEq(registry.resolver(0), address(0));

        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        registry.setResolver(0, address(user));

        assertEq(registry.resolver(0), address(0));
    }

    function testCanSetTTL() public {
        assertEq(registry.ttl(0), 0);

        registry.setTTL(0, 1);

        assertEq(registry.ttl(0), 1);
    }

    function testNonOwnersCannotSetTTL() public {
        assertEq(registry.ttl(0), 0);

        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        registry.setTTL(0, 1);

        assertEq(registry.ttl(0), 0);
    }

    function testCanCreateSubnodes() public {
        hevm.expectEmit(true, true, false, true);
        emit NewOwner(0, keccak256("eth"), address(user));

        registry.setSubnodeOwner(0, keccak256("eth"), address(user));

        assertEq(registry.owner(Namehash.hash("eth")), address(user));
    }

    function testNonOwnersCannotCreateSubnodes() public {
        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("Unauthorized()"));

        registry.setSubnodeOwner(0, keccak256("eth"), address(user));

        assertEq(registry.owner(Namehash.hash("eth")), address(0));
    }
}
