// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IZap {
    function zapIn(
        address _token,
        uint256 _amount,
        address _pool,
        uint256 _minPoolTokens,
        bytes memory _swapData
    ) external payable returns (uint256 poolTokens);

    function zapOut(
        address _tokenOut,
        address _pool,
        uint256 _poolTokens,
        uint256 _amountOutMin,
        bytes[] memory _swapData
    ) external returns (uint amountOut);

    function router() external view returns (address);
    function factory() external view returns (address);
}