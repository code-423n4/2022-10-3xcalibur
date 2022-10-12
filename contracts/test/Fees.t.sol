// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../periphery/interfaces/IRouter.sol";
import "../core/interfaces/ISwapFactory.sol";
import "../core/libraries/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FeesTest is Test {

    address whale = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;
    address feeCollector = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ISwapFactory swapFactory = ISwapFactory(0xAD2935E147b61175D5dc3A9e7bDa93B0975A43BA);
    IRouter router = IRouter(0x00CAC06Dd0BB4103f8b62D280fE9BCEE8f26fD59);
    address stablePair;
    address variablePair;

    function setUp() public {
        vm.startPrank(whale);

        usdc.transfer(address(this), usdc.balanceOf(whale));
        dai.transfer(address(this), dai.balanceOf(whale));
        vm.stopPrank();
        usdc.approve(address(router), type(uint).max);
        dai.approve(address(router), type(uint).max);
        router.addLiquidity(
            address(usdc),
            address(dai),
            true,
            1000000 * 1e6,
            1000000 * 1e18,
            0,
            0,
            address(this),
            block.timestamp
            );
        stablePair = swapFactory.getPair(address(usdc), address(dai), true);
        router.addLiquidity(
            address(usdc),
            address(dai),
            false,
            1000000 * 1e6,
            1000000 * 1e18,
            0,
            0,
            address(this),
            block.timestamp
            );
        variablePair = swapFactory.getPair(address(usdc), address(dai), false);

    }

    // Should calculate the right fee for a stable swap
    function test_stablePair_fee() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(usdc), address(dai), true);
        uint amount = 1000 * 1e6;
        usdc.approve(address(router), type(uint).max);
        uint balBefore = usdc.balanceOf(stablePair);
        router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = usdc.balanceOf(stablePair);
        uint amountMinusFee = amount - amount * 369 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);

        emit log_named_uint("balanceBef", balBefore);
        emit log_named_uint("balanceAf", balAfter);
    }


    function test_stablePair_fee2() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(usdc), address(dai), true);
        uint amount = 100001;
        usdc.approve(address(router), type(uint).max);
        uint balBefore = usdc.balanceOf(stablePair);
        router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = usdc.balanceOf(stablePair);
        uint amountMinusFee = amount - amount * 369 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);
        
    }

    function test_variablePair_fee() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(usdc), address(dai), false);
        uint amount = 1000 * 1e6;
        usdc.approve(address(router), type(uint).max);
        uint balBefore = usdc.balanceOf(variablePair);
        router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = usdc.balanceOf(variablePair);
        uint amountMinusFee = amount - amount * 2700 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);

        emit log_named_uint("balanceBef", balBefore);
        emit log_named_uint("balanceAf", balAfter);
    }

    function test_variablePair_fee2() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(usdc), address(dai), false);
        uint amount = 100001;
        usdc.approve(address(router), type(uint).max);
        uint balBefore = usdc.balanceOf(variablePair);
        router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = usdc.balanceOf(variablePair);
        uint amountMinusFee = amount - amount * 2700 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);

        emit log_named_uint("balanceBef", balBefore);
        emit log_named_uint("balanceAf", balAfter);
    }
}