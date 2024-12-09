// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PuzzleNFTCrafterV5 is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;
    address public signerAddress;
 
    mapping(bytes32 => bool) public usedHashes;
 
    mapping(address => uint256) public nonces;

    constructor(address _signerAddress) ERC721("Puzzle NFT Crafter", "PZNCR") Ownable(msg.sender) {
        tokenCounter = 0;
        signerAddress = _signerAddress;
    }

    function mintNFT(
        address recipient,   
        string memory uri,  
        bytes memory signature, 
        bytes32 imageHash  
    ) public returns (uint256) {
     
        bytes32 messageHash = keccak256(abi.encodePacked(recipient, uri, nonces[recipient], imageHash, address(this)));
 
        require(recoverSigner(messageHash, signature) == signerAddress, "Invalid signature");
 
        require(!usedHashes[imageHash], "This image has already been minted");

        uint256 newItemId = tokenCounter;
 
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, uri);
 
        usedHashes[imageHash] = true;

        nonces[recipient] += 1;

        tokenCounter += 1;

        return newItemId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function recoverSigner(bytes32 messageHash, bytes memory signature) internal pure returns (address) {
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function updateSignerAddress(address newSigner) external onlyOwner {
        signerAddress = newSigner;
    }
}