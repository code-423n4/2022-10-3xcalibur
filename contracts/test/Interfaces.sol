// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface TempIVoter {
    function poolForGauge(address gauge) external view returns (address pool);
}

interface IFactory {
    function getPair(address tokenA, address tokenB, bool stable) external view returns (address);
    function isPair(address pair) external view returns (bool);
}

interface Hevm {
    // Set block.timestamp
    function warp(uint256) external;
    // Sets the *next* call's msg.sender to be the input address
    function prank(address) external;

    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address) external;

    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address, address) external;

    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address, address) external;

    // Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;

    // Sets an address' balance
    function deal(address who, uint256 newBalance) external;

    // Expects an error on next call
    function expectRevert() external;
}

interface IToken {
    function mint(address to, uint amount) external returns (bool);
    function minter() external view returns (address);
    function approve(address spender, uint amount) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function setMinter(address minter) external;
    function transfer(address to, uint amount) external returns (bool);
}


interface IMultiswap {
    function multiswap(
        address _token,
        uint _amount,
        bytes[] calldata _swapData,
        uint[] calldata _weights
    ) external payable returns (uint[] memory);

    function router() external view returns (address);
}

