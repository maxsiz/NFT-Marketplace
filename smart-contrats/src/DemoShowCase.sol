// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DemoShowCase is ERC721Holder, ReentrancyGuard {
    
    struct AssetOnSale {
    	address tokenOwner;
    	address asset;
    	uint256 price;

    }

    struct NFT {
    	address contractAddress;
    	uint256 tokenId;
    }

    error OnlyNFTOwner();

    event NFTOnSale(address indexed contractAddress, uint256 indexed tokenId);
    event NFTRemovedFromSale(address indexed contractAddress, uint256 indexed tokenId);
    event NFTSold(address indexed contractAddress, uint256 indexed tokenId, address payAsset, uint256 payAmount);

    mapping (address =>  mapping(uint256 => AssetOnSale)) public nftOnSale;

   function setForSale(NFT calldata _asset, address sellForToken, uint256 _price) external {
       // Only NFT owner can sell NFT on this ShowCase
        if (IERC721(_asset.contractAddress).ownerOf(_asset.tokenId) == msg.sender) {
           
            // Price must be more then 0
            require (_price > 0, "Cant sell for zero price");
            nftOnSale[_asset.contractAddress][_asset.tokenId] = AssetOnSale(
               msg.sender,
               sellForToken,
               _price
            );

       	    IERC721(_asset.contractAddress).transferFrom(msg.sender, address(this), _asset.tokenId);
            emit NFTRemovedFromSale(_asset.contractAddress, _asset.tokenId);
        } else {
       	   revert OnlyNFTOwner();
        }

   }

   function removeFromSale(NFT calldata _asset) external {
       
        AssetOnSale memory nft =  nftOnSale[_asset.contractAddress][_asset.tokenId];
        if (nft.tokenOwner == msg.sender) {
       	   IERC721(_asset.contractAddress).transferFrom(address(this), msg.sender, _asset.tokenId);
       	   emit NFTOnSale(_asset.contractAddress, _asset.tokenId);
       } else {
       	   revert OnlyNFTOwner();
       }	

   }

   function buyNFT(NFT calldata _asset) external payable nonReentrant {

   	AssetOnSale memory nft =  nftOnSale[_asset.contractAddress][_asset.tokenId];
       // Check  change in case NATIVE payment
        uint256 change;
        if (nft.asset == address(0)) {
            change = msg.value - nft.price;
            require(nft.price <= msg.value, "Not enough ether for buy");
        }
        
        //Get payment
        if (nft.asset == address(0)) {
        	// Native asset payment
        	address payable s = payable(nft.tokenOwner);
            s.transfer(nft.price);

        } else {
        	// ERC20 asset payment
        	require(
        	    IERC20(nft.asset).transferFrom(msg.sender, nft.tokenOwner, nft.price),
        	    "Fail get payment"
        	);

        }

        
        // Delivery asset from Order 
        IERC721(_asset.contractAddress).transferFrom(address(this), msg.sender, _asset.tokenId);
        
        if (change > 0) {
            address payable s = payable(msg.sender);
            s.transfer(change);
        }
        emit NFTSold(_asset.contractAddress, _asset.tokenId, nft.asset, nft.price);
   }

   function getNFTPrice(NFT calldata _asset) external view returns(AssetOnSale memory pr) {
       pr =  nftOnSale[_asset.contractAddress][_asset.tokenId];
   }
}
