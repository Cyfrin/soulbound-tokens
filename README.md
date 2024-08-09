# Soulbound Tokens

## IssuerSoulboundToken

Simple Soulbound Token where the token issuer is responsible for minting and burning.

Source code: [`IssuerSoulboundToken`](./src/ERC5484/IssuerSoulboundToken.sol)

### Identity Usecase

**Key**: _soul = person._

As an issuer, I can verify multiple methods of authentication for a soul (OAuth, 2FA, Yubikey signature, Ethereum wallet signature, etc), and store the resulting connections between them offchain.

Once a certain threshold of authentication is reached, I can issue a Soulbound token to the chosen address of the soul, by calling the `issue` function.

If a soul who receives a token rotates their onchain private keys (or loses access to them for any reason), they put a request to me, the issuer, to burn from the previous address and reissue to the new address.

As the issuer, I must perform authentication on the soul via the previously verified authentication methods. Once authenticated via multiple means and the connections between them are verified, I can be confident that the soul is in fact the same soul as was previously issued the token. I can then reissue the token by calling the `reissue` function, to the new onchain address.

___

From the perspective of the soul, this token acts as a certificate of authenticity that a reputable issuer has issued me.

When I log into other web3 Dapps that support the ERC721 NFT standard, my Soulbound token will be supported.
It can be used in conjunction with other NFTs like ENS names, certifications, POAPs, social accounts, DeFi positions, Proof of Humanity, etc; to aggregate a sense of identity and confidence about personhood.

### ERC5484 Overview
_**[Original ERC Specification](https://eips.ethereum.org/EIPS/eip-5484).**_

This ERC extends the basic ERC721 NFT standard, imposing the following rules:
* Tokens cannot be transferred
* Tokens can only be minted and burned
* BurnAuth determines _who_ can burn.
