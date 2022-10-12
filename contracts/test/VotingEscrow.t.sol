// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "../periphery/interfaces/IVotingEscrow.sol";
import "../periphery/VotingEscrow.sol";
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IToken} from "./Interfaces.sol";

import "forge-std/Test.sol";

contract EscrowTest is Test {

    IVotingEscrow ve;
    IToken token;
    address nonReceiver = 0x00000000219ab540356cBB839Cbe05303d7705Fa; // contract that does not implement onERC721Received
    address minter = 0x1D13fF25b10C9a6741DFdce229073bed652197c7;
    
    function setUp() public {
        ve = IVotingEscrow(0x74Df809b1dfC099E8cdBc98f6a8D1F5c2C3f66f8);
        token = IToken(0xeC827421505972a2AE9C320302d3573B42363C26);
        vm.startPrank(minter);
        token.mint(address(this), 1000e18);
        vm.stopPrank();
        token.approve(address(ve), 100e18);
        ve.create_lock(100e18, 3 weeks);
    }

    // Should mint a veNFT to a contract that implements onERC721Received
    function test_mint_to_ERC721Receiver() public {
        address receiver = address(this);
        token.approve(address(ve), 100e18);
        ve.create_lock(100e18, 2 weeks);
    }

    // Should not mint a veNFT to a contract that does not implement onERC721Received
    function testFail_mint_to_non_ERC721Receiver() public { 
        token.transfer(address(nonReceiver), 100e18);
        token.approve(address(ve), 100e18);
        ve.create_lock_for(100e18, 2 weeks, nonReceiver);
    }

    // Should not transfer a veNFT to a contract that does not implement onERC721Received 
    function testFail_safeTransferFrom_to_non_ERC72Receiver() public {
        ve.safeTransferFrom(address(this), nonReceiver, 1); // contract that does not implement onERC721Received
    }

    // Should let an operator merge 2 locks on behalf of the owner
    // function test_operator_can_merge() public {
    //     address alice = address(0x1);
    //     uint tokenId = 1;
    //     ve.approve(alice, tokenId);

    // }

    // function test_operator_can_withdraw() public {
    //     address alice = address(0x1);
    //     uint tokenId = 1;
    //     uint lock_end = ve.locked__end(tokenId);
    //     emit log_named_uint("lock_end", lock_end);
    //     emit log_named_uint("time", block.timestamp + 3 weeks);
    //     ve.approve(alice, tokenId);
    //     vm.warp(lock_end + 1);
    //     emit log_named_uint("time2", block.timestamp);
    //     assertTrue(ve.isApprovedOrOwner(alice, tokenId));
    //     vm.startPrank(alice);
    //     ve.withdraw(tokenId);
    // }

    function test_owner_can_withdraw() public {
        uint tokenId = 1;
        uint lock_end = ve.locked__end(tokenId);
        vm.warp(lock_end + 1);
        ve.withdraw(tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

}