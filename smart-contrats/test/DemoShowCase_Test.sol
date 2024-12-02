// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import "forge-std/console.sol";

import {DemoShowCase} from "../src/DemoShowCase.sol";

import {MockERC20} from "../src/mock/MockERC20.sol";
import {MockERC721} from "../src/mock/MockERC721.sol";



contract DemoShowCase_Test_m_01 is Test {
    uint256 public sendEtherAmount = 1e18;
    DemoShowCase public showCase;
    MockERC721 public erc721;
    MockERC20 public erc20;
    address public _beneficiary = address(100);
    //uint256 tokenId = 0;
    uint256 price = 1e18;

    receive() external payable virtual {}
    function setUp() public {
        showCase = new DemoShowCase();
        erc20 = new MockERC20('USDT', 'USDT');
        erc721 = new MockERC721('Mock ERC721', 'ERC');
        erc721.mint(address(this), 1);
        erc20.transfer(address(1),price);
    }
    
    function test_putOnSale_success() public {
        erc721.approve(address(showCase),1);
        assertEq(erc721.ownerOf(1), address(this));
        showCase.setForSale(
            DemoShowCase.NFT(address(erc721), 1),
            address(erc20),
            price
        );
        assertEq(erc721.ownerOf(1), address(showCase));
    }

    function test_putOnSale_fail() public {
        erc721.approve(address(showCase),1);
        vm.startPrank(address(12));
        vm.expectRevert();
        showCase.setForSale(
            DemoShowCase.NFT(address(erc721), 1),
            address(erc20),
            price
        );
        vm.stopPrank();
    }

    function test_buy_erc20_success() public {
        erc721.approve(address(showCase),1);
        assertEq(erc721.ownerOf(1), address(this));
        showCase.setForSale(
            DemoShowCase.NFT(address(erc721), 1),
            address(erc20),
            price
        );
        vm.startPrank(address(1));
        erc20.approve(address(showCase), price);
        showCase.buyNFT(DemoShowCase.NFT(address(erc721), 1));
        vm.stopPrank();
        assertEq(erc721.ownerOf(1), address(1));
    }

    function test_removeFromSale_success() public {
        erc721.approve(address(showCase),1);
        assertEq(erc721.ownerOf(1), address(this));
        showCase.setForSale(
            DemoShowCase.NFT(address(erc721), 1),
            address(erc20),
            price
        );
        assertEq(erc721.ownerOf(1), address(showCase));


        showCase.removeFromSale(
            DemoShowCase.NFT(address(erc721), 1)
        );
        assertEq(erc721.ownerOf(1), address(this));
    }

    function test_removeFromSale_fail() public {
        erc721.approve(address(showCase),1);
        assertEq(erc721.ownerOf(1), address(this));
        showCase.setForSale(
            DemoShowCase.NFT(address(erc721), 1),
            address(erc20),
            price
        );
        assertEq(erc721.ownerOf(1), address(showCase));

        vm.startPrank(address(1));
         vm.expectRevert();
        showCase.removeFromSale(
            DemoShowCase.NFT(address(erc721), 1)
        );
        vm.stopPrank();
    }
}