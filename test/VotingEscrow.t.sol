// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./BaseTest.sol";
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract EscrowTest is BaseTest {

    VotingEscrow _ve;
    Token _token;
    
    function setUp() public {
        deployCoins();
        deploy();
        mintStables(address(this));
        _ve = VotingEscrow(votingEscrow);
        _token = Token(token);
        vm.startPrank(minter);
        _token.mint(address(this), 1000e18);
        vm.stopPrank();
        _token.approve(votingEscrow, 110e18);
        _ve.create_lock(100e18, 3 weeks);
        _ve.create_lock(10e18, 4 weeks);

    }

    // Should mint a veNFT to a contract that implements onERC721Received
    function test_mint_to_ERC721Receiver() public {
        address receiver = address(this);
        _token.approve(votingEscrow, 100e18);
        _ve.create_lock(100e18, 2 weeks);
    }

    // Should not mint a veNFT to a contract that does not implement onERC721Received
    function testFail_mint_to_non_ERC721Receiver() public { 
        address nonReceiver = address(WETH);
        _token.transfer(nonReceiver, 100e18);
        _token.approve(votingEscrow, 100e18);
        _ve.create_lock_for(100e18, 2 weeks, nonReceiver);
    }

    // Should not transfer a veNFT to a contract that does not implement onERC721Received 
    function testFail_safeTransferFrom_to_non_ERC72Receiver() public {
        _ve.safeTransferFrom(address(this), address(USDC), 1); // contract that does not implement onERC721Received
    }

    function test_owner_can_withdraw() public {
        uint tokenId = 1;
        uint lock_end = _ve.locked__end(tokenId);
        vm.warp(lock_end + 1);
        _ve.withdraw(tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function testMerge() public {
        _ve.merge(1,2);
    }

    function testDeposit_for() public {
        uint _value = 10e18;
        _token.approve(votingEscrow, _value);
        _ve.deposit_for(1, _value);
    }

    function testIncrease_amount() public {
        uint _value = 10e18;
        _token.approve(votingEscrow, _value);
        _ve.increase_amount(1, _value);
    }

    function testIncrease_unlock_time() public {
        _ve.increase_unlock_time(1, 5 weeks);
    }

    function testBalanceOfAtNFT() public {
        _ve.balanceOfAtNFT(1, block.number-1);
    }

    function testTokenURI() public {
        _ve.tokenURI(1);
    }

    function testTransferFrom() public {
        _ve.transferFrom(address(this),admin,1);
        _ve.safeTransferFrom(address(this),admin,2,"");
    }

    function testSupportedInterface() public {
        bool res = _ve.supportsInterface(0x01ffc9a7);
        assert (res);
    }

    function testGet_last_user_slope() public {
        _ve.get_last_user_slope(1);
    }

    function testgetApproved() public {
        _ve.getApproved(1);
    }

    function testIsApprovedForAll() public {
        _ve.setApprovalForAll(admin,true);
        _ve.isApprovedForAll(address(this),admin);
    }

    function testbalanceOf() public {
        _ve.balanceOf(address(this));
    }

    function testtotalSupplyAt() public {
        _ve.totalSupplyAt(block.number-1);
    }

}
