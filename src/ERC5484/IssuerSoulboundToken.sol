// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./IERC5484.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract IssuerSoulboundToken is IERC5484, ERC721, Ownable2Step {
    /// @notice Thrown when a function that is disallowed for soulbound tokens is called.
    error SoulboundRestricted();
    /// @notice Thrown when the issuer attempts to revoke a token that does not belong to the address
    /// that the token is being revoked from.
    error TokenDoesNotBelongToAddress();

    /// @notice Emitted when a soulbound token is revoked by the issuer.
    /// @param revoker The issuer/revoker
    /// @param from The receiver/owner of the token
    /// @param tokenId The id of the revoked token
    event Revoked(address indexed revoker, address indexed from, uint256 indexed tokenId);

    BurnAuth constant BURN_AUTH = BurnAuth.IssuerOnly;

    constructor() ERC721("Cyfrin Soulbound Token ERC5484", "CYFRIN5484") Ownable(msg.sender) {}

    // External Issuer Only Soulbound Actions

    /// @notice Issues a soulbound token to the receiver.
    /// @dev Can only be called by the owner (issuer) of this contract.
    /// @dev Each tokenID is a unique unsigned integer. It is not incremented automatically.
    /// Tracking the tokenID is the responsibility of the issuer, offchain.
    /// This enables flexibility in the tokenID schema.
    /// @param to The receiver of the token
    /// @param tokenId The id of the token
    function issue(address to, uint256 tokenId) external onlyOwner {
        _issue(to, tokenId);
    }

    /// @notice Revokes a soulbound token from the receiver.
    /// @dev Can only be called by the owner (issuer) of this contract.
    /// @dev The token must belong to the address that the token is being revoked from.
    /// @param from The current owner of the token to revoke
    /// @param tokenId The id of the token to revoke
    function revoke(address from, uint256 tokenId) external onlyOwner {
        _revoke(from, tokenId);
    }

    /// @notice Reissues a soulbound token from the current owner (from) to the new receiver (to).
    /// @dev Can only be called by the owner (issuer) of this contract.
    /// @dev The token must belong to the address that the token is being reissued from.
    /// @param from The current owner of the token to reissue.
    /// @param to The new receiver of the token.
    /// @param tokenId The id of the token to reissue.
    function reissue(address from, address to, uint256 tokenId) external onlyOwner {
        _revoke(from, tokenId);
        _issue(to, tokenId);
    }

    // Private Issuer Only Soulbound Actions

    function _issue(address to, uint256 tokenId) private {
        _safeMint(to, tokenId);
        emit Issued(msg.sender, to, tokenId, BURN_AUTH);
    }

    function _revoke(address from, uint256 tokenId) private {
        address previousOwner = ownerOf(tokenId);
        if (from != previousOwner) revert TokenDoesNotBelongToAddress();
        _burn(tokenId);
        emit Revoked(msg.sender, previousOwner, tokenId);
    }

    // ERC 721

    function _baseURI() internal pure override returns (string memory) {
        // Implement this
        return "";
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override {
        revert SoulboundRestricted();
    }

    function transferFrom(address, address, uint256) public pure override {
        revert SoulboundRestricted();
    }

    function approve(address, uint256) public pure override {
        revert SoulboundRestricted();
    }

    function setApprovalForAll(address, bool) public pure override {
        revert SoulboundRestricted();
    }

    // ERC 5484

    function burnAuth(uint256) external pure override returns (BurnAuth) {
        return BURN_AUTH;
    }

    // ERC 165

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC5484).interfaceId || super.supportsInterface(interfaceId);
    }
}
