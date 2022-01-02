// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./ENSRegistry.sol";

contract ENSResolver {
    error Unauthorized();

    event AddrChanged(bytes32 indexed node, address a);

    address owner;
    ENSRegistry registry;
    mapping(bytes32 => address) addresses;

    constructor(ENSRegistry _registry) {
        owner = msg.sender;
        registry = _registry;
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x01ffc9a7 || interfaceID == 0x3b3b57de;
    }

    function addr(bytes32 node) public view returns (address) {
        return addresses[node];
    }

    function setAddr(bytes32 node, address addr) public {
        if (msg.sender != registry.owner(node)) revert Unauthorized();

        emit AddrChanged(node, addr);

        addresses[node] = addr;
    }
}
