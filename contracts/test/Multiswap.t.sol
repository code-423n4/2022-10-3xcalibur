// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

// Router address: 0x871ACbEabBaf8Bed65c22ba7132beCFaBf8c27B5
// RouterUtil address: 0x6A59CC73e334b018C9922793d96Df84B538E6fD5
// MultiSwap address: 0xC1e0A9DB9eA830c52603798481045688c8AE99C2

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interfaces.sol";
import "../periphery/Multiswap.sol";
import "../periphery/Router.sol";
import "../periphery//interfaces/IRouter.sol";



contract MultiswapTest is Test {

    IERC20 usdc;
    IERC20 dai;
    uint256 f = 1e18;
    Multiswap multi;
    IFactory factory;
    IRouter router;
    address whale = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;
    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    
    receive() external payable {
    }

    function setUp() public {
        // Deployed contracts
        router = IRouter(0x00CAC06Dd0BB4103f8b62D280fE9BCEE8f26fD59);
        multi = Multiswap(0xb007167714e2940013EC3bb551584130B7497E22);
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        factory = IFactory(0xAD2935E147b61175D5dc3A9e7bDa93B0975A43BA);

        // Setup
        vm.startPrank(whale);
        uint maxDai = dai.balanceOf(whale);
        uint maxUsdc = usdc.balanceOf(whale);
        dai.transfer(address(this), maxDai);
        usdc.transfer(address(this), maxUsdc);
        vm.stopPrank();
        uint daiAmount = 100000 * 1e18;
        uint usdcAmount = 100000 * 1e6;
        uint ethAmount = 100 * 1e18;
        vm.deal(address(this), ethAmount);
        dai.approve(address(router), type(uint).max);
        usdc.approve(address(router), type(uint).max);

        router.addLiquidity(
            address(dai),
            address(usdc),
            true,
            daiAmount,
            usdcAmount,
            1,
            1,
            address(this),
            block.timestamp
            );

        router.addLiquidityETH{value: 10 ether}(
            address(dai),
            false,
            daiAmount,
            1,
            1,
            address(this),
            block.timestamp
            );

        router.addLiquidityETH{value: 10 ether}(
            address(usdc),
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
        //vm.startPrank(whale);
        uint256 daiToSwap = 1000 * 1e18;
        // 50%/50%
        weights.push(5000);
        weights.push(5000);
        uint256 amount1 = daiToSwap / 2;
        uint256 amount2 = daiToSwap / 2;
        route memory route1 = route(address(dai), address(usdc), true);
        route memory route2 = route(address(dai), address(weth), false);
        routes1.push(route1);
        routes2.push(route2);
        bytes memory data1 = abi.encodeWithSelector(Router.swapExactTokensForTokens.selector, amount1, 1, routes1, address(this), block.timestamp);
        bytes memory data2 = abi.encodeWithSelector(Router.swapExactTokensForETH.selector, amount2, 1, routes2, address(this), block.timestamp);
        swapData.push(data1);
        swapData.push(data2);
        dai.approve(address(multi), daiToSwap);
        emit log_named_address("router", multi.router());
        uint[] memory amountsOut = multi.multiswap(
            address(dai),
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
        route memory route1 = route(address(weth), address(dai), false);
        route memory route2 = route(address(weth), address(usdc), false);
        _routes1.push(route1);
        _routes2.push(route2);
        bytes memory data1 = abi.encodeWithSelector(Router.swapExactETHForTokens.selector, 1, _routes1, address(this), block.timestamp);
        bytes memory data2 = abi.encodeWithSelector(Router.swapExactETHForTokens.selector, 1, _routes2, address(this), block.timestamp);
        _swapData.push(data1);
        _swapData.push(data2);
        emit log_named_uint("swapData length", _swapData.length);

        emit log_named_address("router", multi.router());
        uint[] memory amountsOut = multi.multiswap{value: ethToSwap}(
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
        
        uint[] memory amounts = multi.multiswap{value: 10 ether}(
            address(0),
            0,
            __swapData,
            __weights
        );
    }
}