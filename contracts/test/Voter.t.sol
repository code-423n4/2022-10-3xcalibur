// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "forge-std/Test.sol";
import "../core/interfaces/ISwapFactory.sol";
import "../periphery/interfaces/IVoter.sol";
import "../periphery/interfaces/IVotingEscrow.sol";
import "./Interfaces.sol";
//import {IRouter} from "./Interfaces.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../periphery/interfaces/IMinter.sol";
import "../periphery/interfaces/IBribe.sol";
import "../periphery/interfaces/IRouter.sol";
import "../periphery/interfaces/IGauge.sol";
import "../core/interfaces/ISwapPair.sol";
import "../core/interfaces/ISwapFactory.sol";

contract VoterTest is IERC721Receiver, Test {

    IERC20 dai;
    IERC20 usdc;
    IERC20 usdt;
    IERC20 busd;
    ISwapFactory swapFactory;
    IToken token;
    IVoter voter;
    IVotingEscrow ve;
    IMinter minter;
    IRouter router;
    address whale = 0x5777d92f208679DB4b9778590Fa3CAB3aC9e2168;
    address deployer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // State
    address swapGauge;
    
    uint DURATION = 7 days;
    uint nextPeriod = (block.timestamp + DURATION) / DURATION * DURATION;

    address alice = address(0x1);
    
    function setUp() public {
        swapFactory = ISwapFactory(0xAD2935E147b61175D5dc3A9e7bDa93B0975A43BA);
        token = IToken(0x74Df809b1dfC099E8cdBc98f6a8D1F5c2C3f66f8);
        voter = IVoter(0x4DAf17c8142A483B2E2348f56ae0F2cFDAe22ceE);
        ve = IVotingEscrow(0x3f9A1B67F3a3548e0ea5c9eaf43A402d12b6a273);
        minter = IMinter(0x24d41dbc3d60d0784f8a937c59FBDe51440D5140);
        router = IRouter(0x00CAC06Dd0BB4103f8b62D280fE9BCEE8f26fD59);
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        // Mint tokens
        uint mintAmount = 10000 * 1e18;
        vm.startPrank(address(minter));
        token.mint(address(this), mintAmount);
        token.mint(alice, mintAmount);
        vm.stopPrank();
        // Get ERC20s
        uint maxDai = dai.balanceOf(whale);
        uint maxUsdc = usdc.balanceOf(whale);

        vm.startPrank(whale);
        usdc.transfer(address(this), maxUsdc);
        dai.transfer(address(this), maxDai);
        vm.stopPrank();
        // Whitelist tokens
        uint fee = voter.listing_fee();
        token.approve(address(voter), fee * 3);
        voter.whitelist(address(usdc), 0);
        voter.whitelist(address(dai), 0);
        // Create gauges
        swapGauge = _createSwapGauge(dai, usdc, true);
        // Create lock
        _createLock(4 weeks, 5 * 1e18);
    }

    // Should create a gauge for a swap pair
    function test_createSwapGauge() public {
        address swapPair = _createSwapPair(dai, usdc, false);
        address swapGauge = voter.createSwapGauge(swapPair);
        // Sanity checks
        address gauge = voter.gauges(swapPair);
        assertEq(gauge, swapGauge);
        // 1 since already created 1 gauge in setUp()
        assertEq(swapGauge, voter.allGauges(1));
        assertTrue(voter.isGauge(swapGauge));
    }


    address[] gaugesVotesSwap;
    uint[] gaugesWeightsSwap;
    // Should vote for a swap gauge
    function test_vote_swapGauge() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        uint _votes = voter.votes(1, swapGauge);
        uint _weights = voter.weights(swapGauge);
        uint _usedWeights = voter.usedWeights(1);
        uint _totalWeight = voter.totalWeight();
        uint _lastVote = voter.lastVote(1);
        assertTrue(ve.voted(1));
        assertTrue(voter.isGauge(swapGauge));
        assertEq(gaugesVotesSwap[0], swapGauge);
        assertEq(_votes, _weights);
        assertEq(_votes, _usedWeights);
        assertEq(_weights, _totalWeight);
        assertEq(_lastVote, block.timestamp);
        // Bribe check
        address _bribe = voter.bribes(swapGauge);
        uint _bribeBalance = IBribe(_bribe).balanceOf(1);
        assertEq(_votes, _bribeBalance);
    }

    // Should be able to vote during next period
    function test_vote_canVoteDuringNextPeriod() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        vm.warp(nextPeriod);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
    }

    // Should not let a `tokenId` vote more than once per period
    function testFail_vote_cannotVoteBeforeNextPeriod() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        vm.warp(nextPeriod - 1);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
    }


    // Should not let a `tokenId` vote if its lock expires before next period
    function testFail_vote_lockEnd() public {
        _createLock(1 days, 1 * 1e18);
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        // 2 since already created a lock in setUp()
        voter.vote(2, gaugesVotesSwap, gaugesWeightsSwap);
    }

    // Should be able to reset votes during next period
    function test_reset() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        vm.warp(nextPeriod + 1);
        voter.reset(1);
        uint _totalWeight = voter.totalWeight();
        uint _votes = voter.votes(1, swapGauge);
        uint _lastVote = voter.lastVote(1);
        assertEq(_totalWeight, 0);
        assertEq(_votes, 0);
        assertEq(_lastVote, block.timestamp);
        assertTrue(!ve.voted(1));
    }

    // Should not be able to reset votes before next period
    function testFail_reset_cannotResetBeforeNextPeriod() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        uint _votesBefore = voter.votes(1, swapGauge);
        vm.warp(nextPeriod - 1);
        voter.reset(1);
    }

    // *** FEE CLAIM ON BRIBE ***
    
    // Should be able to let the LP claim fees via SwapPair.claimsFees()
    function test_claimFees_viaPair() public {
        _addLiquidity(address(this));
        _doSwaps(10);
        address pair = swapFactory.getPair(address(dai), address(usdc), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        ISwapPair(pair).approve(address(router), maxLp);
        // Just in order to pair._updateFor()
        router.removeLiquidity(
            address(dai),
            address(usdc),
            true,
            maxLp,
            1,
            1,
            address(this),
            block.timestamp
            );
        uint claimable0Before = ISwapPair(pair).claimable0(address(this));
        uint claimable1Before = ISwapPair(pair).claimable1(address(this));
        uint index0 = ISwapPair(pair).index0();
        uint index1 = ISwapPair(pair).index1();
        uint bal0Before = dai.balanceOf(address(this));
        uint bal1Before = usdc.balanceOf(address(this));
        ISwapPair(pair).claimFees();
        uint bal0After = dai.balanceOf(address(this));
        uint bal1After = usdc.balanceOf(address(this));
        uint claimable0After = ISwapPair(pair).claimable0(address(this));
        uint claimable1After = ISwapPair(pair).claimable1(address(this));
        uint diff0 = bal0After - bal0Before;
        uint diff1 = bal1After - bal1Before;
        assertEq(0, claimable0After);
        assertEq(0, claimable1After);
        assertEq(diff0, claimable0Before);
        assertEq(diff1, claimable1Before);
    }

    // Should be able to distribute fees to bribes via Voter.distributeFees()
    function test_distributeFees() public {
        _addLiquidity(address(this));
        address pair = swapFactory.getPair(address(dai), address(usdc), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        address gauge = voter.gauges(pair);
        ISwapPair(pair).approve(gauge, maxLp);
        IGauge(gauge).deposit(maxLp, 0);
        ISwapPair(pair).approve(address(router), maxLp);
        _doSwaps(10);
        IGauge(gauge).withdrawAll();
        uint claimable0 = ISwapPair(pair).claimable0(gauge);
        uint claimable1 = ISwapPair(pair).claimable1(gauge);
        address[] memory gauges = new address[](1);
        gauges[0] = gauge;
        voter.distributeFees(gauges);
        uint daiBribeBal = dai.balanceOf(voter.bribes(gauge));
        uint usdcBribeBal = usdc.balanceOf(voter.bribes(gauge));
        assertEq(daiBribeBal, claimable0);
        assertEq(usdcBribeBal, claimable1);
    }

    address[][] tokens1;
    // Should be able to claim fees if a user voted for a gauge
    function test_claimsFees_viaVoter() public {
        _addLiquidity(address(this));
        address[] memory gaugeVote = new address[](1);
        gaugeVote[0] = swapGauge;
        uint[] memory gaugeWeight = new uint[](1);
        gaugeWeight[0] = 2 * 1e18;
        voter.vote(1, gaugeVote, gaugeWeight);
        address pair = swapFactory.getPair(address(dai), address(usdc), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        address gauge = voter.gauges(pair);
        address bribe = voter.bribes(gauge);
        ISwapPair(pair).approve(gauge, maxLp);
        IGauge(gauge).deposit(maxLp, 0);
        ISwapPair(pair).approve(address(router), maxLp);
        _doSwaps(100);
        IGauge(gauge).withdrawAll();
        uint claimable0 = ISwapPair(pair).claimable0(gauge);
        uint claimable1 = ISwapPair(pair).claimable1(gauge);
        address[] memory gauges = new address[](1);
        gauges[0] = gauge;
        voter.distributeFees(gauges);
        address[] memory fees = new address[](1);
        fees[0] = voter.bribes(gauge);
        tokens1.push([address(dai), address(usdc)]);
        vm.warp(block.timestamp + DURATION + 1);
        uint earned0 = IBribe(bribe).earned(address(dai), 1);
        uint earned1 = IBribe(bribe).earned(address(usdc), 1);
        uint bal0Before = dai.balanceOf(address(this));
        uint bal1Before = usdc.balanceOf(address(this));
        voter.claimFees(fees, tokens1, 1);
        uint bal0After = dai.balanceOf(address(this));
        uint bal1After = usdc.balanceOf(address(this));
        assertEq(bal0After, bal0Before + earned0);
        assertEq(bal1After, bal1Before + earned1);
    }

    address[][] tokens2;
    // Should be able to claim fees if multiple users vote for a gauge
    function test_claimFees_viaVoter_multiplayer() public {
        // Alice creates lock
        uint lockAmount = 5 * 1e18;
        vm.startPrank(alice);
        _createLock(4 weeks, lockAmount);
        vm.stopPrank();
        _addLiquidity(address(this));
        address[] memory gaugeVote = new address[](1);
        gaugeVote[0] = swapGauge;
        uint[] memory gaugeWeight1 = new uint[](1);
        uint[] memory gaugeWeight2 = new uint[](1);
        gaugeWeight1[0] = ve.balanceOfNFT(1);
        gaugeWeight2[0] = ve.balanceOfNFT(2);
        voter.vote(1, gaugeVote, gaugeWeight1);
        vm.prank(alice);
        voter.vote(2, gaugeVote, gaugeWeight2);
        address pair = swapFactory.getPair(address(dai), address(usdc), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        address gauge = voter.gauges(pair);
        address bribe = voter.bribes(gauge);
        ISwapPair(pair).approve(gauge, maxLp);
        IGauge(gauge).deposit(maxLp, 0);
        ISwapPair(pair).approve(address(router), maxLp);
        _doSwaps(100);
        IGauge(gauge).withdrawAll();
        address[] memory gauges = new address[](1);
        gauges[0] = gauge;
        voter.distributeFees(gauges);
        address[] memory fees = new address[](1);
        fees[0] = voter.bribes(gauge);
        tokens2.push([address(dai), address(usdc)]);
        vm.warp(block.timestamp + DURATION + 1);
        uint earned0_1 = IBribe(bribe).earned(address(dai), 1);
        uint earned1_1 = IBribe(bribe).earned(address(usdc), 1);
        uint earned0_2 = IBribe(bribe).earned(address(dai), 2);
        uint earned1_2 = IBribe(bribe).earned(address(usdc), 2);
        assertTrue(earned0_1 == earned0_2 && earned1_1 == earned1_2);
    }

    // Should be able to claim earned rewards
    address[][] rewards;
    function test_claimsRewards() public {
        emit log_named_uint("period", minter.active_period());
        _addLiquidity(address(this));
        address pair = swapFactory.getPair(address(dai), address(usdc), true);
        uint balanceThis = ISwapPair(pair).balanceOf(address(this));
        ISwapPair(pair).approve(swapGauge, balanceThis);
        IGauge(swapGauge).deposit(ISwapPair(pair).balanceOf(address(this)), 0);
        address[] memory gaugeVote = new address[](1);
        gaugeVote[0] = swapGauge;
        uint[] memory gaugeWeight = new uint[](1);
        gaugeWeight[0] = ve.balanceOfNFT(1);
        voter.vote(1, gaugeVote, gaugeWeight);

        dai.transfer(alice, 100_000e18);
        usdc.transfer(alice, 100_000e6);

        vm.startPrank(alice);
        _addLiquidity(alice);
        ISwapPair(pair).balanceOf(alice);
        uint balanceAlice = ISwapPair(pair).balanceOf(alice);
        ISwapPair(pair).approve(swapGauge, balanceAlice);
        IGauge(swapGauge).deposit(ISwapPair(pair).balanceOf(alice), 0);
        vm.stopPrank();

        uint activePeriod = minter.active_period();
        emit log_named_uint("activePeriod", activePeriod);
        vm.warp(activePeriod + DURATION + 1);
        minter.update_period();
        emit log_named_uint("period", minter.active_period());
        // only to test voter.claimableclaimable 
        voter.updateGauge(swapGauge);
        emit log_named_uint("claimable", voter.claimable(swapGauge));
        voter.distribute(swapGauge);
        emit log_named_uint("balance0", IGauge(swapGauge).totalSupply());
        emit log_named_uint("gauge balance", token.balanceOf(swapGauge));
        
        address[] memory gauges = new address[](1);
        gauges[0] = swapGauge;
        rewards.push([address(token)]);
        uint balance0Before = token.balanceOf(address(this));
        uint balance1Before = token.balanceOf(alice);
        //voter.claimRewards(gauges, rewards);
        // vm.startPrank(alice);
        //voter.claimRewards(gauges, rewards);
        // vm.stopPrank();
        //vm.warp(block.timestamp + DURATION + 1);
        // uint balance0After = token.balanceOf(address(this));
        // uint balance1After = token.balanceOf(alice);
        // uint earned0 = balance0After - balance0Before;
        // uint earned1 = balance1After - balance1Before;
        // emit log_named_uint("earned0", earned0);
        // emit log_named_uint("earned1", earned1);

        uint earned0 = IGauge(swapGauge).earned(address(token), address(this));
        uint earned1 = IGauge(swapGauge).earned(address(token), alice);
        emit log_named_uint("earned0", earned0);
        emit log_named_uint("earned1", earned1);
    }

    




    
    // ***** INTERNAL *****
    
    // Add liquidity to swap DAI/USDC stable
    function _addLiquidity(address _to) public {
        uint amountA = 100_000 * 10 ** 18;
        uint amountB = 100_000 * 10 ** 6;
        dai.approve(address(router), amountA);
        usdc.approve(address(router), amountB);
        router.addLiquidity(
           address(dai),
           address(usdc),
           true,
           100_000 * 10 ** 18,
           100_000 * 10 ** 6,
           1,
           1,
           _to,
           block.timestamp
           );
    }

    // Do `num` number of swaps in DAI/USDC stable
    function _doSwaps(uint num) public {
        route memory route1 = route(address(dai), address(usdc), true);
        route memory route2 = route(address(usdc), address(dai), true);
        route[] memory _route1 = new route[](1);
        _route1[0] = route1;
        route[] memory _route2 = new route[](1);
        _route2[0] = route2;
        uint daiAmount = 5000 * 10 ** 18;
        uint usdcAmount = 5000 * 10 ** 6;
        dai.approve(address(router), daiAmount * num);
        usdc.approve(address(router), usdcAmount * num);
        for (uint i = 0; i < num; i++) {
            router.swapExactTokensForTokens(
                daiAmount,
                1,
                _route1,
                address(this),
                block.timestamp
                );
            router.swapExactTokensForTokens(
                usdcAmount,
                1,
                _route2,
                address(this),
                block.timestamp
                );
        }
    }

    // Create a swap pair
    function _createSwapPair(IERC20 tokenA, IERC20 tokenB, bool stable) internal returns(address swapPair) {
        swapPair = swapFactory.createPair(address(tokenA), address(tokenB), stable);
        assertTrue(swapFactory.isPair(swapPair));
    }

    function _createSwapGauge(IERC20 tokenA, IERC20 tokenB, bool stable) internal returns(address swapGauge) {
        address swapPair = _createSwapPair(tokenA, tokenB, stable);
        swapGauge = voter.createSwapGauge(swapPair);
    }

    // Create a lock
    function _createLock(uint time, uint amount) internal {
        token.approve(address(ve), amount);
        ve.create_lock(amount, time);
        address owner = ve.ownerOf(1);
        assertEq(owner, address(this));
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return 0x150b7a02;
    }
}