// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DemoShowCase is ERC721Holder {
    
    struct AssetPrice {
    	address asset;
    	uint256 price;
    }

    struct NFT {
    	address contractAddress;
    	uint256 tokenId;
    }

    mapping (address =>  mapping(uint256 => AssetPrice)) public nftOnSale;

   function setForSale (NFT calldata _asset, AssetPrice calldata _price) external {

   }

   function removeFromSale(NFT calldata _asset) external {

   }

   function buyNFT(NFT calldata _asset) external {

   }

   function getNFTPrice(NFT calldata _asset) external view returns(AssetPrice memory pr) {

   }
}
