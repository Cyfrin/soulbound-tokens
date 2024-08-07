// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./IERC5484.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract SoulboundToken5484 is IERC5484, ERC721, Ownable2Step {
    error SoulboundRestricted();

    BurnAuth constant BURN_AUTH = BurnAuth.IssuerOnly;

    constructor() ERC721("Cyfrin Soulbound Token ERC5484", "CYFRIN5484") Ownable(msg.sender) {}

    // Issuer Only Soulbound Actions

    function mint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
        emit Issued(owner(), to, tokenId, BURN_AUTH);
    }

    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
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
