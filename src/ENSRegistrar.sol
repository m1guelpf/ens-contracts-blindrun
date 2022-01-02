// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./ENSRegistry.sol";

contract ENSRegistrar {
    bytes32 rootNode;
    ENSRegistry registry;

    constructor(ENSRegistry _registry, bytes32 node) {
        rootNode = node;
        registry = _registry;
    }

    function register(bytes32 subnode, address owner) public {
        address currentOwner = registry.owner(
            keccak256(abi.encodePacked(rootNode, subnode))
        );

        require(
            currentOwner == address(0) || currentOwner == msg.sender,
            "Unauthorized"
        );

        registry.setSubnodeOwner(rootNode, subnode, owner);
    }
}
