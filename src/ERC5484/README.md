# IssuerSoulboundToken (ERC5484)

- [IssuerSoulboundToken (ERC5484)](#issuersoulboundtoken-erc5484)
  - [ERC5484 Overview](#erc5484-overview)
  - [Roles and Actions](#roles-and-actions)
    - [Role 1: ADMIN](#role-1-admin)
    - [Role 2: ISSUER](#role-2-issuer)


## ERC5484 Overview
_**[Original ERC Specification](https://eips.ethereum.org/EIPS/eip-5484).**_

This ERC extends the basic ERC721 NFT standard, imposing the following rules:
* Tokens cannot be transferred
* Tokens can only be minted and burned
* BurnAuth determines _who_ can burn.

## Roles and Actions

### Role 1: ADMIN

The administrator/owner address of the contract.

**Requirements**

Must be a multisig or equivalent.

**Purpose**

If a new contract is developed and deployed to replace this one, the administrator is responsible for pausing all actions here, collecting the data from this contract, and deploying the new contract pre-loaded with token information. This enables seamless upgrade without requiring any action from token holders. (There is a final step where this contract is then unpaused, and the ISSUER revokes all old tokens from this decommissioned contract).

**Actions**

* `pause()` - Pause all activity on the contract. No issuing, revoking or reissuing can occur.
* `unpause()` - The opposite of `pause()`.

### Role 2: ISSUER

The address responsible for issuing and revoking soulbound tokens.

**Requirements**

Most likely an EOA, so that offchain systems can automate the issuance and revoking of tokens.

**Purpose**

This role is purposefully separate from the ADMIN role. Issuing, revoking and reissuing will ideally be automated by offchain systems. An EOA is best suited for this. Pausing, on the other hand, should only be enacted in the event of an upgrade, which is a decision that should not be accessible by automated systems.

**Actions**

* `issue(address to, uint256 tokenId)`
* `revoke(address from, uint256 tokenId)`
* `reissue(address from, address to, uint256 tokenId)` - A combination of both `revoke` and `issue`.