// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "./interfaces/IENS.sol";

contract ENSRegistry is IENS {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32 => Record) records;

    constructor(address owner) {
        records[0].owner = owner;
    }

    function owner(bytes32 node) public view returns (address) {
        return records[node].owner;
    }

    function resolver(bytes32 node) public view returns (address) {
        return records[node].resolver;
    }

    function ttl(bytes32 node) public view returns (uint64) {
        return records[node].ttl;
    }

    function recordExists(bytes32 node) external virtual view returns (bool) {
        return records[node].owner != address(0);
    }

    function setOwner(bytes32 node, address owner) public {
        Record storage record = records[node];

        require(msg.sender == record.owner, "Unauthorized.");

        emit Transfer(node, owner);

        record.owner = owner;
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public {
        require(msg.sender == records[node].owner, "Unauthorized.");

        emit NewOwner(node, label, owner);

        records[keccak256(abi.encodePacked(node, label))].owner = owner;
    }

    function setResolver(bytes32 node, address resolver) public {
        Record storage record = records[node];

        require(msg.sender == record.owner, "Unauthorized.");

        emit NewResolver(node, resolver);

        record.resolver = resolver;
    }

    function setTTL(bytes32 node, uint64 ttl) public {
        Record storage record = records[node];

        require(msg.sender == record.owner, "Unauthorized.");

        record.ttl = ttl;
    }
}
