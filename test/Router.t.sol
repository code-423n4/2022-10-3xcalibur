// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./BaseTest.sol";
import "forge-std/Vm.sol";

contract RouterTest is BaseTest {

    Router _router;

    function setUp() public {
        deployCoins();
        deploy();
        mintStables(address(this));

        _router = Router(payable(router));
    }

    function testswapExactTokensForTokensSimple() public {
        addLiquidity();
        uint _amountIn = 1e18;
        (uint _amountOutMin, bool stable) = _router.getAmountOut(
            _amountIn,
            address(DAI),
            address(USDC)
        );

        _router.swapExactTokensForTokensSimple(
            _amountIn,
            _amountOutMin,
            address(DAI),
            address(USDC),
            stable,
            address(this),
            block.timestamp + 1 minutes
        );
    }

        function addLiquidity() public {
        {
        uint _amountA = 1000000e18;
        uint _amountB = 1000000e6;
        DAI.approve(router, type(uint).max);
        USDC.approve(router, type(uint).max);
        (
            uint _amountOutA,
            uint _amountOutB,
            uint _liquidity
        ) = _router.quoteAddLiquidity(
            address(DAI),
            address(USDC),
            true,
            _amountA,
            _amountB
        );
        _router.addLiquidity(
            address(DAI),
            address(USDC),
            true,
            _amountA,
            _amountB,
            _amountOutA,
            _amountOutB,
            address(this),
            block.timestamp + 1 minutes
        );
        } {
        uint _amountA = 1000000e18;
        uint _amountB = 1000000e6;
        DAI.approve(router, type(uint).max);
        USDC.approve(router, type(uint).max);
        (
            uint _amountOutA,
            uint _amountOutB,
            uint _liquidity
        ) = _router.quoteAddLiquidity(
            address(DAI),
            address(USDC),
            true,
            _amountA,
            _amountB
        );
        _router.addLiquidity(
            address(DAI),
            address(USDC),
            false,
            _amountA,
            _amountB,
            _amountOutA * 99 / 100,
            _amountOutB * 99 / 100,
            address(this),
            block.timestamp + 1 minutes
        );
    }
    }
}
