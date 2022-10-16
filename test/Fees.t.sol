// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./BaseTest.sol";
import "forge-std/Vm.sol";
import "contracts/periphery/interfaces/IRouter.sol";
import "contracts/core/interfaces/ISwapFactory.sol";
import "contracts/core/interfaces/ISwapPair.sol";
import "contracts/core/libraries/Math.sol";

contract FeesTest is BaseTest {

    address stablePair;
    address variablePair;
    IRouter _router;
    ISwapFactory _swapFactory;

    function setUp() public {
        deployCoins();
        deploy();
        mintStables(address(this));

        _router = IRouter(router);
        _swapFactory = ISwapFactory(swapFactory);

        USDC.approve(address(_router), type(uint).max);
        DAI.approve(address(_router), type(uint).max);
        _router.addLiquidity(
            address(USDC),
            address(DAI),
            true,
            1000000 * 1e6,
            1000000 * 1e18,
            0,
            0,
            address(this),
            block.timestamp
            );
        stablePair = _swapFactory.getPair(address(USDC), address(DAI), true);
        _router.addLiquidity(
            address(USDC),
            address(DAI),
            false,
            1000000 * 1e6,
            1000000 * 1e18,
            0,
            0,
            address(this),
            block.timestamp
            );
        variablePair = _swapFactory.getPair(address(USDC), address(DAI), false);

    }

    // Should calculate the right fee for a stable swap
    function test_stablePair_fee() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(USDC), address(DAI), true);
        uint amount = 1000 * 1e6;
        USDC.approve(address(_router), type(uint).max);
        uint balBefore = USDC.balanceOf(stablePair);
        _router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = USDC.balanceOf(stablePair);
        uint amountMinusFee = amount - amount * 369 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);

        emit log_named_uint("balanceBef", balBefore);
        emit log_named_uint("balanceAf", balAfter);
    }


    function test_stablePair_fee2() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(USDC), address(DAI), true);
        uint amount = 100001;
        USDC.approve(address(_router), type(uint).max);
        uint balBefore = USDC.balanceOf(stablePair);
        _router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = USDC.balanceOf(stablePair);
        uint amountMinusFee = amount - amount * 369 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);
        
    }

    function test_variablePair_fee() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(USDC), address(DAI), false);
        uint amount = 1000 * 1e6;
        USDC.approve(address(_router), type(uint).max);
        uint balBefore = USDC.balanceOf(variablePair);
        _router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = USDC.balanceOf(variablePair);
        uint amountMinusFee = amount - amount * 2700 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);

        emit log_named_uint("balanceBef", balBefore);
        emit log_named_uint("balanceAf", balAfter);
    }

    function test_variablePair_fee2() public {
        route[] memory routes = new route[](1);
        routes[0] = route(address(USDC), address(DAI), false);
        uint amount = 100001;
        USDC.approve(address(_router), type(uint).max);
        uint balBefore = USDC.balanceOf(variablePair);
        _router.swapExactTokensForTokens(amount, 1, routes, address(this), block.timestamp);
        uint balAfter = USDC.balanceOf(variablePair);
        uint amountMinusFee = amount - amount * 2700 / 1e6;
        assertApproxEqAbs(balAfter, balBefore + amountMinusFee, 2);

        emit log_named_uint("balanceBef", balBefore);
        emit log_named_uint("balanceAf", balAfter);
    }

    function test_current() public {
        _doSwaps(10);
        vm.warp(block.timestamp + 1000);
        _doSwaps(10);
        ISwapPair(stablePair).current(address(DAI), 100 *1e18);
    }

    function test_currentCumulativePrices() public {
        _doSwaps(10);
        vm.warp(block.timestamp + 1000);
        ISwapPair(stablePair).currentCumulativePrices();
    }

    function test_sample() public {
        _doSwaps(10);
        vm.warp(block.timestamp + 1000);
        _doSwaps(10);
        vm.warp(block.timestamp + 1000);
        _doSwaps(10);
        ISwapPair(stablePair).sample(address(DAI), 100 *1e18, 1,1);
    }

    function test_quote() public {
        _doSwaps(10);
        vm.warp(block.timestamp + 1000);
        _doSwaps(10);
        vm.warp(block.timestamp + 1000);
        _doSwaps(10);
        ISwapPair(stablePair).sample(address(DAI), 100 *1e18, 1,1);
        ISwapPair(stablePair).quote(address(DAI), 100 *1e18, 1);
    }

    function test_setFees() public {
        uint newStableFee = 100;
        uint newVariableFee = 3000;
        vm.startPrank(_swapFactory.admin());
        _swapFactory.setFeeTier(true, newStableFee);
        _swapFactory.setFeeTier(false, newVariableFee);
        vm.stopPrank();
        assertEq(_swapFactory.fee(true), newStableFee);
        assertEq(_swapFactory.fee(false), newVariableFee);

        
    }

    function testFail_setFeesNotAdmin() public {
        uint newStableFee = 100;
        uint newVariableFee = 3000;
        vm.startPrank(address(1));
        _swapFactory.setFeeTier(true, newStableFee);
        _swapFactory.setFeeTier(false, newVariableFee);
        vm.stopPrank();
    }

    function test_setAdmin() public {
        address newAdmin = address(1);
        vm.startPrank(_swapFactory.admin());
        _swapFactory.setAdmin(newAdmin);
        vm.stopPrank();
        assertEq(_swapFactory.admin(), newAdmin);
    }

    // ***** INTERNAL *****

    function _doSwaps(uint num) public {
        route memory route1 = route(address(DAI), address(USDC), true);
        route memory route2 = route(address(USDC), address(DAI), true);
        route[] memory _route1 = new route[](1);
        _route1[0] = route1;
        route[] memory _route2 = new route[](1);
        _route2[0] = route2;
        uint daiAmount = 5000 * 10 ** 18;
        uint usdcAmount = 5000 * 10 ** 6;
        DAI.approve(address(_router), daiAmount * num);
        USDC.approve(address(_router), usdcAmount * num);
        for (uint i = 0; i < num; i++) {
            _router.swapExactTokensForTokens(
                daiAmount,
                1,
                _route1,
                address(this),
                block.timestamp
                );
            _router.swapExactTokensForTokens(
                usdcAmount,
                1,
                _route2,
                address(this),
                block.timestamp
                );
        }
    }

    

}