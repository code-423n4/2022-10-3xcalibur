// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

// Router address: 0x871ACbEabBaf8Bed65c22ba7132beCFaBf8c27B5
// RouterUtil address: 0x6A59CC73e334b018C9922793d96Df84B538E6fD5
// MultiSwap address: 0xC1e0A9DB9eA830c52603798481045688c8AE99C2

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interfaces.sol";
import "../periphery/interfaces/IRouter.sol";
import "../periphery/Router.sol";
import "forge-std/Test.sol";
import "../periphery/interfaces/IZap.sol";

contract ZapTest is Test {

    IERC20 usdc;
    IERC20 dai;
    uint256 f = 1e18;
    IFactory factory;
    IRouter router;
    address whale = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;
    IZap zap;
    address pool;

    receive() external payable {
    }

    function setUp() public {
        router = IRouter(0x00CAC06Dd0BB4103f8b62D280fE9BCEE8f26fD59);
        zap = IZap(0x2e8880cAdC08E9B438c6052F5ce3869FBd6cE513);
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        factory = IFactory(0xAD2935E147b61175D5dc3A9e7bDa93B0975A43BA);
        vm.startPrank(whale);
        uint maxDai = dai.balanceOf(whale);
        uint maxUsdc = usdc.balanceOf(whale);
        dai.transfer(address(this), maxDai);
        usdc.transfer(address(this), maxUsdc);
        vm.stopPrank();
        uint daiAmount = 10000 * 1e18;
        uint usdcAmount = 10000 * 1e6;
        uint ethAmount = 10 * 1e18;
        vm.deal(address(this), ethAmount);
        dai.approve(address(router), daiAmount * 2);
        usdc.approve(address(router), usdcAmount * 2);

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
        pool = factory.getPair(address(dai), address(usdc), true);

        router.addLiquidityETH{value: 1 ether}(
            address(dai),
            false,
            daiAmount,
            1,
            1,
            address(this),
            block.timestamp
            );

        // router.addLiquidityETH{value: 1 ether}(
        //     address(usdc),
        //     true,
        //     usdcAmount,
        //     1,
        //     1,
        //     address(this),
        //     block.timestamp
        //     );
    }
    route[] routes;
    function test_zap() public {
        route memory route1 = route(address(dai), address(usdc), true);
        routes.push(route1);
        uint amount = 1000 * 1e6;
        uint amountOutMin = 1;
        usdc.approve(address(zap), amount);
        bytes memory data = abi.encodeWithSelector(
            Router.swapExactTokensForTokens.selector,
            amount,
            amountOutMin,
            routes,
            address(this),
            block.timestamp
            );
        emit log_named_uint("usdc", usdc.balanceOf(address(this)));
        emit log_named_uint("dai", dai.balanceOf(address(this)));
        emit log_named_address("router", zap.router());
        emit log_named_address("factory", zap.factory());
        zap.zapIn(
            address(usdc),
            amount,
            pool,
            1,
            data
        );
    }
}