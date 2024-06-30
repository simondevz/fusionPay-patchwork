// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@patchwork/Patchwork721.sol";
import "@patchwork/PatchworkUtils.sol";

contract FusionAttestation is Patchwork721 {
    
    struct Metadata {
        string bank;
        string emailAddress;
        string orderRef;
        address walletAddress;
        string accountNumber;
    }

    constructor(address _manager, address _owner)
        Patchwork721("FusionAttestation", "FusionAttestation", "FUSION", _manager, _owner)
    {}

    function schemaURI() pure external override returns (string memory) {
        return string.concat(_baseURI(), "fiat/attestation/schema");
    }

    function imageURI(uint256 tokenId) pure external override returns (string memory) {
        return string.concat(_baseURI(), "fiat/attestation/image");
    }

    function _baseURI() pure internal virtual override returns (string memory) {
        return "http://127.0.0.1:8000/";
    }

    function storeMetadata(uint256 tokenId, Metadata memory data) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId] = packMetadata(data);
    }

    function loadMetadata(uint256 tokenId) public view returns (Metadata memory data) {
        return unpackMetadata(_metadataStorage[tokenId]);
    }

    function schema() pure external override returns (MetadataSchema memory) {
        MetadataSchemaEntry[] memory entries = new MetadataSchemaEntry[](5);
        entries[0] = MetadataSchemaEntry(2, 0, FieldType.CHAR32, 1, FieldVisibility.PUBLIC, 0, 0, "bank");
        entries[1] = MetadataSchemaEntry(3, 0, FieldType.CHAR32, 1, FieldVisibility.PUBLIC, 1, 0, "emailAddress");
        entries[2] = MetadataSchemaEntry(5, 0, FieldType.CHAR32, 1, FieldVisibility.PUBLIC, 2, 0, "orderRef");
        entries[3] = MetadataSchemaEntry(4, 0, FieldType.ADDRESS, 1, FieldVisibility.PUBLIC, 3, 0, "walletAddress");
        entries[4] = MetadataSchemaEntry(1, 0, FieldType.CHAR16, 1, FieldVisibility.PUBLIC, 4, 0, "accountNumber");
        return MetadataSchema(1, entries);
    }

    function packMetadata(Metadata memory data) public pure returns (uint256[] memory slots) {
        slots = new uint256[](5);
        slots[0] = PatchworkUtils.strToUint256(data.bank);
        slots[1] = PatchworkUtils.strToUint256(data.emailAddress);
        slots[2] = PatchworkUtils.strToUint256(data.orderRef);
        slots[3] = uint256(uint160(data.walletAddress));
        slots[4] = PatchworkUtils.strToUint256(data.accountNumber) >> 128;
        return slots;
    }

    function unpackMetadata(uint256[] memory slots) public pure returns (Metadata memory data) {
        uint256 slot = slots[0];
        data.bank = PatchworkUtils.toString32(slot);
        slot = slots[1];
        data.emailAddress = PatchworkUtils.toString32(slot);
        slot = slots[2];
        data.orderRef = PatchworkUtils.toString32(slot);
        slot = slots[3];
        data.walletAddress = address(uint160(slot));
        slot = slots[4];
        data.accountNumber = PatchworkUtils.toString16(uint128(slot));
        return data;
    }

    // Load Only bank
    function loadBank(uint256 tokenId) public view returns (string memory) {
        uint256 value = uint256(_metadataStorage[tokenId][0]);
        return PatchworkUtils.toString32(value);
    }

    // Store Only bank
    function storeBank(uint256 tokenId, string memory bank) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][0] = PatchworkUtils.strToUint256(bank);
    }

    // Load Only emailAddress
    function loadEmailAddress(uint256 tokenId) public view returns (string memory) {
        uint256 value = uint256(_metadataStorage[tokenId][1]);
        return PatchworkUtils.toString32(value);
    }

    // Store Only emailAddress
    function storeEmailAddress(uint256 tokenId, string memory emailAddress) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][1] = PatchworkUtils.strToUint256(emailAddress);
    }

    // Load Only orderRef
    function loadOrderRef(uint256 tokenId) public view returns (string memory) {
        uint256 value = uint256(_metadataStorage[tokenId][2]);
        return PatchworkUtils.toString32(value);
    }

    // Store Only orderRef
    function storeOrderRef(uint256 tokenId, string memory orderRef) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        _metadataStorage[tokenId][2] = PatchworkUtils.strToUint256(orderRef);
    }

    // Load Only walletAddress
    function loadWalletAddress(uint256 tokenId) public view returns (address) {
        uint256 value = uint256(_metadataStorage[tokenId][3]);
        return address(uint160(value));
    }

    // Store Only walletAddress
    function storeWalletAddress(uint256 tokenId, address walletAddress) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        uint256 mask = (1 << 160) - 1;
        uint256 cleared = uint256(_metadataStorage[tokenId][3]) & ~(mask);
        _metadataStorage[tokenId][3] = cleared | (uint256(uint160(walletAddress)) & mask);
    }

    // Load Only accountNumber
    function loadAccountNumber(uint256 tokenId) public view returns (string memory) {
        uint256 value = uint256(_metadataStorage[tokenId][4]);
        return PatchworkUtils.toString16(uint128(value));
    }

    // Store Only accountNumber
    function storeAccountNumber(uint256 tokenId, string memory accountNumber) public {
        if (!_checkTokenWriteAuth(tokenId)) {
            revert IPatchworkProtocol.NotAuthorized(msg.sender);
        }
        uint256 mask = (1 << 128) - 1;
        uint256 cleared = uint256(_metadataStorage[tokenId][4]) & ~(mask);
        _metadataStorage[tokenId][4] = cleared | (PatchworkUtils.strToUint256(accountNumber) >> 128 & mask);
    }

    // Override transfer functions to prevent transfers
    function safeTransferFrom() public pure {
        require(false, "Attestations are non-transferable");
    }
}