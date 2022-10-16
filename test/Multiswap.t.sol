// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "./BaseTest.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/periphery/Multiswap.sol";
import "contracts/periphery/Router.sol";
import "contracts/periphery/interfaces/IRouter.sol";


contract MultiswapTest is BaseTest {

    Multiswap _multiswap;
    IRouter _router;
    
    receive() external payable {
    }

    function setUp() public {
        deployCoins();
        deploy();
        mintStables(address(this));

        // Deployed contracts
        _router = IRouter(router);
        _multiswap = Multiswap(multiswap);

        uint daiAmount = 100000 * 1e18;
        uint usdcAmount = 100000 * 1e6;
        uint ethAmount = 100 * 1e18;
        dealETH(address(this), ethAmount);
        DAI.approve(address(_router), type(uint).max);
        USDC.approve(address(_router), type(uint).max);

        _router.addLiquidity(
            address(DAI),
            address(USDC),
            true,
            daiAmount,
            usdcAmount,
            1,
            1,
            address(this),
            block.timestamp
            );

        _router.addLiquidityETH{value: 10 ether}(
            address(DAI),
            false,
            daiAmount,
            1,
            1,
            address(this),
            block.timestamp
            );

        _router.addLiquidityETH{value: 10 ether}(
            address(USDC),
            false,
            usdcAmount,
            1,
            1,
            address(this),
            block.timestamp
            );
    }

    route[] routes1;
    route[] routes2;
    bytes[] swapData;
    uint[] weights;
    // should multiswap from DAI to ETH and USDT with a 50/50 split
    function test_multiswap_tokenToTokens() public {
        uint256 daiToSwap = 1000 * 1e18;
        // 50%/50%
        weights.push(5000);
        weights.push(5000);
        uint256 amount1 = daiToSwap / 2;
        uint256 amount2 = daiToSwap / 2;
        route memory route1 = route(address(DAI), address(USDC), true);
        route memory route2 = route(address(DAI), address(WETH), false);
        routes1.push(route1);
        routes2.push(route2);
        bytes memory data1 = abi.encodeWithSelector(Router.swapExactTokensForTokens.selector, amount1, 1, routes1, address(this), block.timestamp);
        bytes memory data2 = abi.encodeWithSelector(Router.swapExactTokensForETH.selector, amount2, 1, routes2, address(this), block.timestamp);
        swapData.push(data1);
        swapData.push(data2);
        DAI.approve(address(_multiswap), daiToSwap);
        emit log_named_address("_router", _multiswap.router());
        uint[] memory amountsOut = _multiswap.multiswap(
            address(DAI),
            daiToSwap,
            swapData,
            weights
        );

        emit log_named_uint("USDC received", amountsOut[0]);
        emit log_named_uint("ETH received", amountsOut[1]);
        emit log_named_bytes("data1", data1);
    }



    route[] _routes1;
    route[] _routes2;
    bytes[] _swapData;
    uint[] _weights;
    // should multiswap from ETH to DAI and USDC with a 50/50 split
    function test_multiswap_ethToTokens() public {
        uint256 ethToSwap = 2 * 1e18;
        // 50%/50%
        _weights.push(5000);
        _weights.push(5000);
        emit log_named_uint("weights length", _weights.length);
        emit log_named_uint("balance", address(this).balance);
        route memory route1 = route(address(WETH), address(DAI), false);
        route memory route2 = route(address(WETH), address(USDC), false);
        _routes1.push(route1);
        _routes2.push(route2);
        bytes memory data1 = abi.encodeWithSelector(Router.swapExactETHForTokens.selector, 1, _routes1, address(this), block.timestamp);
        bytes memory data2 = abi.encodeWithSelector(Router.swapExactETHForTokens.selector, 1, _routes2, address(this), block.timestamp);
        _swapData.push(data1);
        _swapData.push(data2);
        emit log_named_uint("swapData length", _swapData.length);

        emit log_named_address("router", _multiswap.router());
        uint[] memory amountsOut = _multiswap.multiswap{value: ethToSwap}(
            address(0),
            0,
            _swapData,
            _weights
        );
        emit log_named_uint("DAI received", amountsOut[0]);
        emit log_named_uint("USDC received", amountsOut[1]);
    }

    uint[] __weights;
    route[] __routes1;
    route[] __routes2;
    bytes[] __swapData;
    // should try to multiswap with wrong weights and fail
    function testFail_wrong_weights() public {
        // 10%/20%
        __weights.push(1000);
        __weights.push(2000);
        bytes memory data = abi.encodeWithSelector(Router.swapExactETHForTokens.selector, 1, _routes1, address(this), block.timestamp);
        __swapData.push(data);
        data = abi.encodeWithSelector(Router.swapExactETHForTokens.selector, 1, _routes2, address(this), block.timestamp);
        __swapData.push(data);
        
        uint[] memory amounts = _multiswap.multiswap{value: 10 ether}(
            address(0),
            0,
            __swapData,
            __weights
        );
    }
}