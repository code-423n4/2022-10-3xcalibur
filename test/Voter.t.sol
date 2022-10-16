// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "./BaseTest.sol";
import "contracts/periphery/interfaces/IVoter.sol";
import "contracts/periphery/interfaces/IVotingEscrow.sol";
import "contracts/periphery/interfaces/IMinter.sol";
import "contracts/periphery/interfaces/IBribe.sol";
import "contracts/periphery/interfaces/IRouter.sol";
import "contracts/periphery/interfaces/IGauge.sol";
import "contracts/core/interfaces/ISwapFactory.sol";
import "contracts/core/interfaces/ISwapPair.sol";
import "contracts/core/interfaces/ISwapFactory.sol";

contract VoterTest is IERC721Receiver, BaseTest {

    ISwapFactory _swapFactory;
    IVoter _voter;
    IVotingEscrow _ve;
    IMinter _minter;
    IRouter _router;

    // State
    address swapGauge;
    
    uint DURATION = 7 days;
    uint nextPeriod = (block.timestamp + DURATION) / DURATION * DURATION;

    address alice = address(0x1);
    
    function setUp() public {
        deployCoins();
        deploy();
        mintStables(address(this));

        _swapFactory = ISwapFactory(swapFactory);
        _voter = IVoter(voter);
        _ve = IVotingEscrow(votingEscrow);
        _minter = IMinter(minter);
        _router = IRouter(router);
        
        // Mint XCAL
        uint mintAmount = 10000 * 1e18;
        mintXcal(address(this), mintAmount);
        mintXcal(alice, mintAmount);
        
        // Whitelist tokens
        uint fee = _voter.listing_fee();
        token.approve(address(_voter), fee * 3);
        // _ve.create_lock(fee * 3, 4 weeks);
        _voter.whitelist(address(USDC));
        _voter.whitelist(address(DAI));
        // // Create gauges
        swapGauge = _createSwapGauge(address(DAI), address(USDC), true);
        // // Create lock
        _createLock(4 weeks, 5 * 1e18);
    }

    // Should create a gauge for a swap pair
    function test_createSwapGauge() public {
        address swapPair = _createSwapPair(address(DAI), address(USDC), false);
        address swapGauge = _voter.createSwapGauge(swapPair);
        (address _token0, address _token1) = ISwapPair(swapPair).tokens();
        
        // Sanity checks
        address gauge = _voter.gauges(swapPair);
        assertEq(gauge, swapGauge);
        address _bribe = _voter.bribes(swapGauge);
        // 1 since already created 1 gauge in setUp()
        assertEq(swapGauge, _voter.allGauges(1));
        assertTrue(_voter.isGauge(swapGauge));
        assertTrue(_voter.isLive(swapGauge));
        assertTrue(_voter.isReward(swapGauge, _token0));
        assertTrue(_voter.isReward(swapGauge, _token1));
        assertTrue(_voter.isBribe(_bribe, _token0));
        assertTrue(_voter.isBribe(_bribe, _token1));
        
        

    }


    address[] gaugesVotesSwap;
    uint[] gaugesWeightsSwap;
    // Should vote for a swap gauge
    function test_vote_swapGauge() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        uint _votes = _voter.votes(1, swapGauge);
        uint _weights = _voter.weights(swapGauge);
        uint _usedWeights = _voter.usedWeights(1);
        uint _totalWeight = _voter.totalWeight();
        uint _lastVote = _voter.lastVote(1);
        assertTrue(_ve.voted(1));
        assertTrue(_voter.isGauge(swapGauge));
        assertEq(gaugesVotesSwap[0], swapGauge);
        assertEq(_votes, _weights);
        assertEq(_votes, _usedWeights);
        assertEq(_weights, _totalWeight);
        assertEq(_lastVote, block.timestamp);
        // Bribe check
        address _bribe = _voter.bribes(swapGauge);
        uint _bribeBalance = IBribe(_bribe).balanceOf(1);
        assertEq(_votes, _bribeBalance);
    }

    // Should be able to vote during next period
    function test_vote_canVoteDuringNextPeriod() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        vm.warp(nextPeriod);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
    }

    // Should not let a `tokenId` vote more than once per period
    function testFail_vote_cannotVoteBeforeNextPeriod() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        vm.warp(nextPeriod - 1);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
    }


    // Should not let a `tokenId` vote if its lock expires before next period
    function testFail_vote_lockEnd() public {
        _createLock(1 days, 1 * 1e18);
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        // 2 since already created a lock in setUp()
        _voter.vote(2, gaugesVotesSwap, gaugesWeightsSwap);
    }

    // Should be able to reset votes during next period
    function test_reset() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        vm.warp(nextPeriod + 1);
        _voter.reset(1);
        uint _totalWeight = _voter.totalWeight();
        uint _votes = _voter.votes(1, swapGauge);
        uint _lastVote = _voter.lastVote(1);
        assertEq(_totalWeight, 0);
        assertEq(_votes, 0);
        assertEq(_lastVote, block.timestamp);
        assertTrue(!_ve.voted(1));
    }

    // Should not be able to reset votes before next period
    function testFail_reset_cannotResetBeforeNextPeriod() public {
        gaugesVotesSwap.push(swapGauge);
        uint weights = 2 * 1e18;
        gaugesWeightsSwap.push(weights);
        _voter.vote(1, gaugesVotesSwap, gaugesWeightsSwap);
        uint _votesBefore = _voter.votes(1, swapGauge);
        vm.warp(nextPeriod - 1);
        _voter.reset(1);
    }

    // *** FEE CLAIM ON BRIBE ***
    
    // Should be able to let the LP claim fees via SwapPair.claimsFees()
    function test_claimFees_viaPair() public {
        _addLiquidity(address(this));
        _doSwaps(10);
        address pair = _swapFactory.getPair(address(DAI), address(USDC), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        ISwapPair(pair).approve(address(_router), maxLp);
        // Just in order to pair._updateFor()
        _router.removeLiquidity(
            address(DAI),
            address(USDC),
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
        uint bal0Before = DAI.balanceOf(address(this));
        uint bal1Before = USDC.balanceOf(address(this));
        ISwapPair(pair).claimFees();
        uint bal0After = DAI.balanceOf(address(this));
        uint bal1After = USDC.balanceOf(address(this));
        uint claimable0After = ISwapPair(pair).claimable0(address(this));
        uint claimable1After = ISwapPair(pair).claimable1(address(this));
        uint diff0 = bal0After - bal0Before;
        uint diff1 = bal1After - bal1Before;
        assertEq(0, claimable0After);
        assertEq(0, claimable1After);

        (address _token0,) = ISwapPair(pair).tokens();
        if (_token0 == address(DAI)) {
            assertEq(diff0, claimable0Before);
            assertEq(diff1, claimable1Before);
        } else {
            assertEq(diff0, claimable1Before);
            assertEq(diff1, claimable0Before);
        }
    }

    // Should be able to distribute fees to bribes via Voter.distributeFees()
    function test_distributeFees() public {
        _addLiquidity(address(this));
        address pair = _swapFactory.getPair(address(DAI), address(USDC), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        address gauge = _voter.gauges(pair);
        ISwapPair(pair).approve(gauge, maxLp);
        IGauge(gauge).deposit(maxLp, 0);
        ISwapPair(pair).approve(address(_router), maxLp);
        _doSwaps(10);
        IGauge(gauge).withdrawAll();
        uint claimable0 = ISwapPair(pair).claimable0(gauge);
        uint claimable1 = ISwapPair(pair).claimable1(gauge);
        address[] memory gauges = new address[](1);
        gauges[0] = gauge;
        _voter.distributeFees(gauges);
        uint daiBribeBal = DAI.balanceOf(_voter.bribes(gauge));
        uint usdcBribeBal = USDC.balanceOf(_voter.bribes(gauge));

        (address _token0,) = ISwapPair(pair).tokens();
        if (_token0 == address(DAI)) {
            assertEq(daiBribeBal, claimable0);
            assertEq(usdcBribeBal, claimable1);
        } else {
            assertEq(daiBribeBal, claimable1);
            assertEq(usdcBribeBal, claimable0);
        }
    }

    address[][] tokens1;
    // Should be able to claim fees if a user voted for a gauge
    function test_claimsFees_viaVoter() public {
        _addLiquidity(address(this));
        address[] memory gaugeVote = new address[](1);
        gaugeVote[0] = swapGauge;
        uint[] memory gaugeWeight = new uint[](1);
        gaugeWeight[0] = 2 * 1e18;
        _voter.vote(1, gaugeVote, gaugeWeight);
        address pair = _swapFactory.getPair(address(DAI), address(USDC), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        address gauge = _voter.gauges(pair);
        address bribe = _voter.bribes(gauge);
        ISwapPair(pair).approve(gauge, maxLp);
        IGauge(gauge).deposit(maxLp, 0);
        ISwapPair(pair).approve(address(_router), maxLp);
        _doSwaps(100);
        IGauge(gauge).withdrawAll();
        uint claimable0 = ISwapPair(pair).claimable0(gauge);
        uint claimable1 = ISwapPair(pair).claimable1(gauge);
        address[] memory gauges = new address[](1);
        gauges[0] = gauge;
        _voter.distributeFees(gauges);
        address[] memory fees = new address[](1);
        fees[0] = _voter.bribes(gauge);
        tokens1.push([address(DAI), address(USDC)]);
        vm.warp(block.timestamp + DURATION + 1);
        uint earned0 = IBribe(bribe).earned(address(DAI), 1);
        uint earned1 = IBribe(bribe).earned(address(USDC), 1);
        uint bal0Before = DAI.balanceOf(address(this));
        uint bal1Before = USDC.balanceOf(address(this));
        _voter.claimFees(fees, tokens1, 1);
        uint bal0After = DAI.balanceOf(address(this));
        uint bal1After = USDC.balanceOf(address(this));
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
        gaugeWeight1[0] = _ve.balanceOfNFT(1);
        gaugeWeight2[0] = _ve.balanceOfNFT(2);
        _voter.vote(1, gaugeVote, gaugeWeight1);
        vm.prank(alice);
        _voter.vote(2, gaugeVote, gaugeWeight2);
        address pair = _swapFactory.getPair(address(DAI), address(USDC), true);
        uint maxLp = ISwapPair(pair).balanceOf(address(this));
        address gauge = _voter.gauges(pair);
        address bribe = _voter.bribes(gauge);
        ISwapPair(pair).approve(gauge, maxLp);
        IGauge(gauge).deposit(maxLp, 0);
        ISwapPair(pair).approve(address(_router), maxLp);
        _doSwaps(100);
        IGauge(gauge).withdrawAll();
        address[] memory gauges = new address[](1);
        gauges[0] = gauge;
        _voter.distributeFees(gauges);
        address[] memory fees = new address[](1);
        fees[0] = _voter.bribes(gauge);
        tokens2.push([address(DAI), address(USDC)]);
        vm.warp(block.timestamp + DURATION + 1);
        uint earned0_1 = IBribe(bribe).earned(address(DAI), 1);
        uint earned1_1 = IBribe(bribe).earned(address(USDC), 1);
        uint earned0_2 = IBribe(bribe).earned(address(DAI), 2);
        uint earned1_2 = IBribe(bribe).earned(address(USDC), 2);
        assertTrue(earned0_1 == earned0_2 && earned1_1 == earned1_2);
        IBribe(bribe).batchRewardPerToken(address(DAI), 3);
    }

    // Should be able to claim earned rewards
    address[][] rewards;
    function test_claimsRewards() public {
        emit log_named_uint("period", _minter.active_period());
        _addLiquidity(address(this));
        address pair = _swapFactory.getPair(address(DAI), address(USDC), true);
        uint balanceThis = ISwapPair(pair).balanceOf(address(this));
        ISwapPair(pair).approve(swapGauge, balanceThis);
        IGauge(swapGauge).deposit(ISwapPair(pair).balanceOf(address(this)), 0);
        address[] memory gaugeVote = new address[](1);
        gaugeVote[0] = swapGauge;
        uint[] memory gaugeWeight = new uint[](1);
        gaugeWeight[0] = _ve.balanceOfNFT(1);
        _voter.vote(1, gaugeVote, gaugeWeight);

        DAI.transfer(alice, 100_000e18);
        USDC.transfer(alice, 100_000e6);

        vm.startPrank(alice);
        _addLiquidity(alice);
        ISwapPair(pair).balanceOf(alice);
        uint balanceAlice = ISwapPair(pair).balanceOf(alice);
        ISwapPair(pair).approve(swapGauge, balanceAlice);
        IGauge(swapGauge).deposit(ISwapPair(pair).balanceOf(alice), 0);
        vm.stopPrank();

        uint activePeriod = _minter.active_period();
        emit log_named_uint("activePeriod", activePeriod);
        vm.warp(activePeriod + DURATION + 1 weeks);
        _minter.update_period();
        emit log_named_uint("period", _minter.active_period());
        // only to test voter.claimableclaimable 
        _voter.updateGauge(swapGauge);
        emit log_named_uint("claimable", _voter.claimable(swapGauge));
        _voter.distribute(swapGauge);
        emit log_named_uint("balance0", IGauge(swapGauge).totalSupply());
        emit log_named_uint("gauge balance", token.balanceOf(swapGauge));
        
        address[] memory gauges = new address[](1);
        gauges[0] = swapGauge;
        rewards.push([address(token)]);
        uint balance0Before = token.balanceOf(address(this));
        uint balance1Before = token.balanceOf(alice);

        _voter.claimRewards(gauges, rewards);
        vm.startPrank(alice);
        _voter.claimRewards(gauges, rewards);
        vm.stopPrank();
        // vm.warp(block.timestamp + DURATION + 1);
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
        IGauge(swapGauge).withdrawAll();
        vm.warp(block.timestamp + 1 weeks);
        IGauge(swapGauge).batchRewardPerToken(address(token), 3);
        vm.warp(block.timestamp + 1 weeks);
        IGauge(swapGauge).getPriorBalanceIndex(address(this), block.timestamp - 1 days);
        vm.warp(block.timestamp + 1 weeks);
        emit log_named_uint("prior supply index", IGauge(swapGauge).getPriorSupplyIndex(block.timestamp - 1 days));
        emit log_named_uint("supply checkpoint", IGauge(swapGauge).supplyCheckpoints(0).timestamp);
        emit log_named_uint("block timestamp", block.timestamp);
        emit log_named_uint("last checkpoint timestamp", IGauge(swapGauge).checkpoints(address(this), IGauge(swapGauge).numCheckpoints(address(this))).timestamp);
        IGauge(swapGauge).getPriorRewardPerToken(address(token), block.timestamp - 5 days);
        vm.startPrank(alice);
        IGauge(swapGauge).withdrawAll();
        vm.stopPrank();
        token.approve(swapGauge, 100 * 1e18);
        IGauge(swapGauge).notifyRewardAmount(address(token), 100 * 1e18);
        emit log_named_uint("supply num checkpoint", IGauge(swapGauge).supplyNumCheckpoints());

    }

    function test_whitelist_tokens() public {
        vm.startPrank(_voter.admin());
        _voter.whitelist(address(token));
        _voter.whitelist(address(FRAX));
    }

    function test_set_reward() public {
        vm.startPrank(_voter.admin());
        _voter.setReward(swapGauge, address(FRAX), true);
    }

    function test_set_bribe() public {
        vm.startPrank(_voter.admin());
        _voter.setReward(swapGauge, address(FRAX), true);
    }

    function test_cancel_reward() public {
        vm.startPrank(_voter.admin());
        _voter.setReward(_voter.bribes(swapGauge), address(FRAX), false);
    }

    function test_cancel_bribe() public {
        vm.startPrank(_voter.admin());
        _voter.setBribe(_voter.bribes(swapGauge), address(FRAX), false);
    }

    function test_kill_gauge() public {
        vm.startPrank(_voter.admin());
        _voter.killGauge(swapGauge);
        assertEq(_voter.claimable(swapGauge), 0);
        assertFalse(_voter.isLive(swapGauge));
    }

    function test_revive_gauge() public {
        vm.startPrank(_voter.admin());
        _voter.killGauge(swapGauge);
        _voter.reviveGauge(swapGauge);
        assertTrue(_voter.isLive(swapGauge));
    }

    
    // ***** INTERNAL *****
    
    // Add liquidity to swap DAI/USDC stable
    function _addLiquidity(address _to) public {
        uint amountA = 100_000 * 10 ** 18;
        uint amountB = 100_000 * 10 ** 6;
        DAI.approve(address(_router), amountA);
        USDC.approve(address(_router), amountB);
        _router.addLiquidity(
           address(DAI),
           address(USDC),
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

    // Create a swap pair
    function _createSwapPair(address tokenA, address tokenB, bool stable) internal returns(address swapPair) {
        swapPair = _swapFactory.createPair(tokenA, tokenB, stable);
        assertTrue(_swapFactory.isPair(swapPair));
    }

    function _createSwapGauge(address tokenA, address tokenB, bool stable) internal returns(address swapGauge) {
        address swapPair = _createSwapPair(tokenA, tokenB, stable);
        swapGauge = _voter.createSwapGauge(swapPair);
    }

    // Create a lock
    function _createLock(uint time, uint amount) internal {
        token.approve(address(_ve), amount);
        _ve.create_lock(amount, time);
        address owner = _ve.ownerOf(1);
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
