# Soulbound Tokens

## IssuerSoulboundToken

Simple Soulbound Token where the token issuer is responsible for minting and burning.

Source code: [`IssuerSoulboundToken`](./src/ERC5484/IssuerSoulboundToken.sol)

### Identity Usecase

As an issuer of an identity, I can verify multiple methods of authentication for a "soul" (Web2 logins, 2FA, Yubikey, Ethereum wallet signature, etc), and store the resulting connections between them.

Once a certain threshold of authentication is reached, I can issue a soulbound token to the chosen address of the "soul", by calling the `issue` function.

In the event that a receiver of a token rotates their onchain private keys (or loses access to them for any reason), they must put a request to the issuer (me) to burn from the previous address, and reissue to the new address.

As the issuer, I must perform authentication via the previously verified authentication methods for that "soul". Once authenticated, I can be confident that the "soul" is in fact the same "soul" as was previously issued the token. I can then reissue the token by calling the `reissue` function.

### ERC5484 Overview
_**[Original ERC Specification](https://eips.ethereum.org/EIPS/eip-5484).**_

This ERC extends the basic ERC721 NFT standard, imposing the following rules:
* Tokens cannot be transferred
* Tokens can only be minted and burned
* BurnAuth determines _who_ can burn.
