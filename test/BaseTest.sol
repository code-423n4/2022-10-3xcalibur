// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {SwapFactory} from "contracts/core/SwapFactory.sol";
import {SwapPair} from "contracts/core/SwapPair.sol";
import {SwapFees} from "contracts/core/SwapFees.sol";
import {BribeFactory} from "contracts/periphery/BribeFactory.sol";
import {Bribe} from "contracts/periphery/Bribe.sol";
import {GaugeFactory} from "contracts/periphery/GaugeFactory.sol";
import {Gauge} from "contracts/periphery/Gauge.sol";
import {Minter} from "contracts/periphery/Minter.sol";
import {Router} from "contracts/periphery/Router.sol";
import {Token} from "contracts/periphery/Token.sol";
import {Voter} from "contracts/periphery/Voter.sol";
import {VotingDist} from "contracts/periphery/VotingDist.sol";
import {VotingEscrow} from "contracts/periphery/VotingEscrow.sol";
import {Multiswap} from "contracts/periphery/Multiswap.sol";
import "./utils/TestWETH.sol";

abstract contract BaseTest is Test {
    address public swapFactory;
    address public bribeFactory;
    address public gaugeFactory;
    address public minter;
    address public router;
    address public voter;
    address public votingDist;
    address public votingEscrow;
    address public multiswap;
    address public nonReceiver = 0x00000000219ab540356cBB839Cbe05303d7705Fa;

    Token public token; // XCAL
    MockERC20 USDC;
    MockERC20 FRAX;
    MockERC20 DAI;
    TestWETH WETH; // Mock WETH token

    address admin = address(1);

    function deploy() public {

        swapFactory = address(new SwapFactory(admin));
        router = address(
            new Router(
                swapFactory,
                address(WETH)
            )
        );
        multiswap = address(new Multiswap(router));
        gaugeFactory = address(new GaugeFactory());
        bribeFactory = address(new BribeFactory());
        token = Token(new Token());
        votingEscrow = address(new VotingEscrow(address(token)));
        votingDist = address(new VotingDist(votingEscrow));
        voter = address(
            new Voter(
                votingEscrow,
                swapFactory,
                gaugeFactory,
                bribeFactory
            )
        );
        VotingEscrow(votingEscrow).setVoter(voter);
        minter = address(
            new Minter(
                voter,
                votingEscrow,
                votingDist,
                admin,
                169371e18
            )
        );
        token.mint(admin, 2690037e3);
        token.setMinter(minter);
        VotingDist(votingDist).setDepositor(minter);
        Voter(voter).initialize(minter);
        Minter(minter).initialize();
    }

    function deployCoins() public {
        USDC = new MockERC20("USDC", "USDC", 6);
        FRAX = new MockERC20("FRAX", "FRAX", 18);
        DAI = new MockERC20("DAI", "DAI", 18);
        WETH = new TestWETH();
    }

    function mintStables(address _account) public {
        USDC.mint(_account, 1e12 * 1e6);
        FRAX.mint(_account, 1e12 * 1e18);
        DAI.mint(_account, 1e12 * 1e18);
    }

    function mintXcal(address _account, uint256 _amount) public {
        vm.startPrank(address(minter));
        token.mint(_account, _amount);
        vm.stopPrank();
    }

    function mintWETH(address _account, uint256 _amount) public {
        WETH.mint(_account, _amount);
    }

    function dealETH(address _account, uint256 _amount) public {
        vm.deal(_account, _amount);
    }
}
