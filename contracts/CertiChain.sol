// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertiChain {
    address public admin;
    mapping(address => bool) public isIssuer;

    struct Certificate {
        address issuer;
        uint64 issuedAt;
        bool revoked;
        string studentId;
        string program;
    }
    mapping(bytes32 => Certificate) private certs;

    event IssuerAdded(address indexed issuer);
    event IssuerRemoved(address indexed issuer);
    event CertificateIssued(bytes32 indexed certHash, address indexed issuer, string studentId);
    event CertificateRevoked(bytes32 indexed certHash, address indexed by);

    modifier onlyAdmin() { require(msg.sender == admin, "Not admin"); _; }
    modifier onlyIssuer() { require(isIssuer[msg.sender], "Not issuer"); _; }

    constructor() {
        admin = msg.sender;
        isIssuer[msg.sender] = true;
    }

    function addIssuer(address a) external onlyAdmin {
        isIssuer[a] = true;
        emit IssuerAdded(a);
    }

    function removeIssuer(address a) external onlyAdmin {
        isIssuer[a] = false;
        emit IssuerRemoved(a);
    }

    function issueCertificate(
        bytes32 h, string calldata studentId, string calldata program
    ) external onlyIssuer {
        require(certs[h].issuedAt == 0, "Already issued");
        certs[h] = Certificate(msg.sender, uint64(block.timestamp), false, studentId, program);
        emit CertificateIssued(h, msg.sender, studentId);
    }

    function revokeCertificate(bytes32 h) external onlyIssuer {
        Certificate storage c = certs[h];
        require(c.issuedAt != 0, "Not found");
        require(c.issuer == msg.sender || msg.sender == admin, "Not allowed");
        require(!c.revoked, "Already revoked");
        c.revoked = true;
        emit CertificateRevoked(h, msg.sender);
    }

    function verifyCertificate(bytes32 h) external view returns (
        bool exists, bool revoked, address issuer,
        uint64 issuedAt, string memory studentId, string memory program
    ) {
        Certificate storage c = certs[h];
        return (c.issuedAt != 0, c.revoked, c.issuer, c.issuedAt, c.studentId, c.program);
    }
}