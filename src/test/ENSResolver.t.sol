// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./Hevm.sol";
import "./Namehash.sol";
import "ds-test/test.sol";
import "../ENSRegistry.sol";
import "../ENSResolver.sol";

contract User {}

contract ENSResolverTest is DSTest {
    User internal user;
    Hevm internal hevm;
    ENSRegistry internal registry;
    ENSResolver internal resolver;

    event AddrChanged(bytes32 indexed node, address a);

    function setUp() public {
        user = new User();
        hevm = Hevm(HEVM_ADDRESS);
        registry = new ENSRegistry(address(this));
        resolver = new ENSResolver(registry);
    }

    function testCanSetAddress() public {
        assertEq(resolver.addr(0), address(0));

        hevm.expectEmit(true, false, false, true);
        emit AddrChanged(0, address(this));

        resolver.setAddr(0, address(this));

        assertEq(resolver.addr(0), address(this));
    }

    function testNonOwnersCannotSetAddress() public {
        assertEq(resolver.addr(0), address(0));

        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
        resolver.setAddr(0, address(this));

        assertEq(resolver.addr(0), address(0));
    }

    function testSupportsInterfaceConformsToSpec() public {
        // supportsInterface
        assertTrue(resolver.supportsInterface(0x01ffc9a7));

        // addr
        assertTrue(resolver.supportsInterface(0x3b3b57de));
    }
}
