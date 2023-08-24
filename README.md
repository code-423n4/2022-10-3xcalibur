# 3xcalibur contest details

- $47,500 USDC main award pot
- $2,500 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-10-3xcalibur-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 18, 2022 20:00 UTC
- Ends October 23, 2022 20:00 UTC

## Bounty Scope

The following changes makes up the scope of the **3xcalibur 10-2022** contest:

- Changed the whitelisting mechanism in [Voter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Voter.sol)
- Changed the fee rate for stable and variable swaps in [SwapFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapFactory.sol) and [SwapPair.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapPair.sol)
- Allow to change emission strategy every epoch (26 weeks) in [Minter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Minter.sol)
- Added an optional boost to the global weekly emission amount in [Minter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Minter.sol)
- Added the [Multiswap.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Multiswap.sol) contract to allow for swaps targeting multiple tokens at once
- Corrected rewards calculation [Bribe.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Bribe.sol) and [Gauge.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Gauge.sol)

## Contracts

## Scope
### Files in scope
|File|[SLOC](#nowhere "(nSLOC, SLOC, Lines)")|[Coverage](#nowhere "(Lines hit / Total)")|
|:-|:-:|:-:|
|_Contracts (7)_|
|[contracts/periphery/Multiswap.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Multiswap.sol) [🧪](#nowhere "Experimental Features") [💰](#nowhere "Payable Functions")|[59](#nowhere "(nSLOC:54, SLOC:59, Lines:80)")|[100.00%](#nowhere "(Hit:30 / Total:30)")|
|[contracts/Core/SwapFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapFactory.sol) [🧮](#nowhere "Uses Hash-Functions")|[76](#nowhere "(nSLOC:76, SLOC:76, Lines:94)")|[68.00%](#nowhere "(Hit:17 / Total:25)")|
|[contracts/periphery/Minter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Minter.sol) [📤](#nowhere "Initiates ETH Value Transfer")|[106](#nowhere "(nSLOC:105, SLOC:106, Lines:148)")|[77.42%](#nowhere "(Hit:24 / Total:31)")|
|[contracts/periphery/Voter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Voter.sol)|[339](#nowhere "(nSLOC:339, SLOC:339, Lines:439)")|[79.63%](#nowhere "(Hit:129 / Total:162)")|
|[contracts/periphery/Bribe.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Bribe.sol)|[354](#nowhere "(nSLOC:354, SLOC:354, Lines:466)")|[62.62%](#nowhere "(Hit:129 / Total:206)")|
|[contracts/Core/SwapPair.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapPair.sol) [🧮](#nowhere "Uses Hash-Functions") [🔖](#nowhere "Handles Signatures: ecrecover") [🌀](#nowhere "create/create2")|[432](#nowhere "(nSLOC:430, SLOC:432, Lines:543)")|[90.52%](#nowhere "(Hit:210 / Total:232)")|
|[contracts/periphery/Gauge.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Gauge.sol)|[452](#nowhere "(nSLOC:452, SLOC:452, Lines:586)")|[68.70%](#nowhere "(Hit:180 / Total:262)")|
|Total (over 7 files):| [1818](#nowhere "(nSLOC:1810, SLOC:1818, Lines:2356)")| [75.84%](#nowhere "Hit:719 / Total:948")|


### All other source contracts (not in scope)
|File|[SLOC](#nowhere "(nSLOC, SLOC, Lines)")|[Coverage](#nowhere "(Lines hit / Total)")|
|:-|:-:|:-:|
|_Contracts (7)_|
|[contracts/periphery/BribeFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/BribeFactory.sol) [🌀](#nowhere "create/create2")|[9](#nowhere "(nSLOC:9, SLOC:9, Lines:14)")|[100.00%](#nowhere "(Hit:2 / Total:2)")|
|[contracts/periphery/GaugeFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/GaugeFactory.sol) [🌀](#nowhere "create/create2")|[9](#nowhere "(nSLOC:9, SLOC:9, Lines:17)")|[100.00%](#nowhere "(Hit:2 / Total:2)")|
|[contracts/Core/SwapFees.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapFees.sol)|[28](#nowhere "(nSLOC:28, SLOC:28, Lines:38)")|[100.00%](#nowhere "(Hit:7 / Total:7)")|
|[contracts/periphery/Token.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Token.sol)|[53](#nowhere "(nSLOC:53, SLOC:53, Lines:68)")|[86.36%](#nowhere "(Hit:19 / Total:22)")|
|[contracts/periphery/VotingDist.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingDist.sol)|[264](#nowhere "(nSLOC:264, SLOC:264, Lines:320)")|[29.49%](#nowhere "(Hit:46 / Total:156)")|
|[contracts/periphery/Router.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Router.sol) [💰](#nowhere "Payable Functions") [📤](#nowhere "Initiates ETH Value Transfer") [🧮](#nowhere "Uses Hash-Functions")|[357](#nowhere "(nSLOC:266, SLOC:357, Lines:428)")|[73.19%](#nowhere "(Hit:101 / Total:138)")|
|[contracts/periphery/VotingEscrow.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingEscrow.sol) [🖥](#nowhere "Uses Assembly") [📤](#nowhere "Initiates ETH Value Transfer")|[647](#nowhere "(nSLOC:619, SLOC:647, Lines:1043)")|[90.53%](#nowhere "(Hit:306 / Total:338)")|
|_Libraries (3)_|
|[contracts/periphery/libraries/Math.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/libraries/Math.sol)|[21](#nowhere "(nSLOC:21, SLOC:21, Lines:25)")|[20.00%](#nowhere "(Hit:2 / Total:10)")|
|[contracts/Core/libraries/Math.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/libraries/Math.sol)|[26](#nowhere "(nSLOC:26, SLOC:26, Lines:31)")|[0.00%](#nowhere "(Hit:0 / Total:13)")|
|[contracts/periphery/libraries/Base64.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/libraries/Base64.sol) [🖥](#nowhere "Uses Assembly")|[39](#nowhere "(nSLOC:39, SLOC:39, Lines:71)")|[100.00%](#nowhere "(Hit:5 / Total:5)")|
|_Interfaces (15)_|
|[contracts/Core/interfaces/callback/ISwapCallee.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/interfaces/callback/ISwapCallee.sol)|[4](#nowhere "(nSLOC:4, SLOC:4, Lines:6)")|-|
|[contracts/periphery/interfaces/IBribeFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IBribeFactory.sol)|[4](#nowhere "(nSLOC:4, SLOC:4, Lines:6)")|-|
|[contracts/periphery/interfaces/IGaugeFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IGaugeFactory.sol)|[4](#nowhere "(nSLOC:4, SLOC:4, Lines:6)")|-|
|[contracts/Core/interfaces/IERC20.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/interfaces/IERC20.sol)|[5](#nowhere "(nSLOC:5, SLOC:5, Lines:10)")|-|
|[contracts/periphery/interfaces/IVotingDist.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IVotingDist.sol)|[5](#nowhere "(nSLOC:5, SLOC:5, Lines:7)")|-|
|[contracts/periphery/interfaces/IWETH.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IWETH.sol) [💰](#nowhere "Payable Functions")|[6](#nowhere "(nSLOC:6, SLOC:6, Lines:14)")|-|
|[contracts/periphery/interfaces/IMinter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IMinter.sol)|[7](#nowhere "(nSLOC:7, SLOC:7, Lines:10)")|-|
|[contracts/periphery/interfaces/IUnderlying.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IUnderlying.sol)|[8](#nowhere "(nSLOC:8, SLOC:8, Lines:10)")|-|
|[contracts/periphery/interfaces/IBribe.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IBribe.sol)|[11](#nowhere "(nSLOC:11, SLOC:11, Lines:13)")|-|
|[contracts/Core/interfaces/ISwapFactory.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/interfaces/ISwapFactory.sol)|[13](#nowhere "(nSLOC:13, SLOC:13, Lines:15)")|-|
|[contracts/Core/interfaces/ISwapPair.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/interfaces/ISwapPair.sol)|[24](#nowhere "(nSLOC:24, SLOC:24, Lines:26)")|-|
|[contracts/periphery/interfaces/IGauge.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IGauge.sol)|[27](#nowhere "(nSLOC:27, SLOC:27, Lines:32)")|-|
|[contracts/periphery/interfaces/IVotingEscrow.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IVotingEscrow.sol)|[36](#nowhere "(nSLOC:36, SLOC:36, Lines:40)")|-|
|[contracts/periphery/interfaces/IVoter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IVoter.sol)|[44](#nowhere "(nSLOC:44, SLOC:44, Lines:47)")|-|
|[contracts/periphery/interfaces/IRouter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IRouter.sol) [💰](#nowhere "Payable Functions")|[46](#nowhere "(nSLOC:13, SLOC:46, Lines:53)")|-|
|Total (over 25 files):| [1697](#nowhere "(nSLOC:1545, SLOC:1697, Lines:2350)")| [70.71%](#nowhere "Hit:490 / Total:693")|


## External imports
* **@openzeppelin/contracts/token/ERC20/IERC20.sol**
  * ~~[contracts/Core/SwapFees.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapFees.sol)~~
  * [contracts/Core/SwapPair.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/Core/SwapPair.sol)
  * [contracts/periphery/Bribe.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Bribe.sol)
  * [contracts/periphery/Gauge.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Gauge.sol)
  * [contracts/periphery/Multiswap.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Multiswap.sol)
  * ~~[contracts/periphery/Router.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Router.sol)~~
  * [contracts/periphery/Voter.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Voter.sol)
  * ~~[contracts/periphery/VotingDist.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingDist.sol)~~
  * ~~[contracts/periphery/VotingEscrow.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingEscrow.sol)~~
  * ~~[contracts/periphery/interfaces/IWETH.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/interfaces/IWETH.sol)~~
* **@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol**
  * ~~[contracts/periphery/VotingEscrow.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingEscrow.sol)~~
* **@openzeppelin/contracts/token/ERC721/IERC721.sol**
  * ~~[contracts/periphery/VotingEscrow.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingEscrow.sol)~~
* **@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol**
  * ~~[contracts/periphery/VotingEscrow.sol](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/VotingEscrow.sol)~~

## Description

**3xcalibur** is a decentralized exchange and liquidity protocol on Arbitrum nitro.  
It is a fork of the Solidly protocol, which notably introduced `x3y + y3x = k` pools for concentrated stable-swaps, and improved on the Curve's emission mechanism.  
  
We further improved on Solidly by allowing to use more complex emisson schedule strategies, added modifications to the governance mechanism, added convenience contracts to improve user experience, correcting bugs and redesigned tokenomics.  

## Tokens

The **XCAL** token is an ERC20 token with 18 decimals.  
It is the main token of the protocol.  
It can be locked in exchange for a VeNFT token that grants user voting power to direct the protocol's emissions, proportional to the locked amount and lock duration.

**VeNFTs** are ERC721 tokens.  
They encode the amount and duration of the lock, and can be transferred to other users.  
Can be used to direct emissions by voting for gauges (through the [Voter](https://github.com/code-423n4/2022-10-3xcalibur/blob/main/contracts/periphery/Voter.sol) contract).  

**LP tokens** are ERC20 tokens.  
They represent a share in a liquidity pool.

## Deployment

Set environment variables in a .env file:

```bash
$ export PRIVATE_KEY=<ur private key>
$ export ALCHEMY_API_KEY=<your alchemy api key>
```

In root of repo:

```bash
$ yarn
$ npx hardhat run ./scripts/deploy.ts [--network <network>]
```

Deployed addresses will be in `./scipts/config/<network>.json`

## Tests

The test suite uses the [foundry](https://book.getfoundry.sh/) framework.  

to install foundry, run:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

the all-in-one command to clone, build the repo, test and get gas reports is the following:

```bash
rm -Rf 2022-10-3xcalibur || true && git clone https://github.com/code-423n4/2022-10-3xcalibur.git && cd 2022-10-3xcalibur && mv contracts/Core contracts/core && npm install && foundryup && forge install foundry-rs/forge-std --no-commit && forge install transmissions11/solmate --no-commit && forge test --gas-report --fork-url https://arb1.arbitrum.io/rpc
```

*note:* if you have an issue where Cloudflare intercepts the rpc URL, an Infura Ethereum mainnet url works as well.

run tests:

```bash
# example
forge test -f https://arb1.arbitrum.io/rpc --force --gas-report
```

To get code coverage:

```bash
forge coverage
```

### Slither

NOTE: Slither does not currently work on the repo. If you find a workaround, please share in the discord.

## Details

```
- Your company/team/project's name? Do share a link if you have one:   3xcalibur (3xcalibur.com)
- Do you have a link to the repo that the contest will cover?:   It is currently private.
- If you have a public code repo, please share it here:   N/A
- How many core contracts are in scope?:   7
- Total SLoC for these contracts?:   1748
- How many external imports are there?:   4
- How many separate interfaces and struct definitions are there for the contracts within scope?:   Interfaces: 29 and Structs: 6
- Does most of your code generally use composition or inheritance?:   Composition
- How many external calls?:   0
- What is the overall line coverage percentage provided by your tests?:   71%
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:   false
- Does it use an oracle?:   false
- Does the token conform to the ERC20 standard?:   Yes
- Are there any novel or unique curve logic or mathematical models?:   Yes, the solidly stableswap invariant by Andre Cronje
- Does it use a timelock function?:   No
- Is it an NFT?:   No
- Does it have an AMM?:   Yes
- Is it a fork of a popular project?:   true
- If yes, please describe your customisations:   Bribe: added functions to update rewards for all tokens at once and fixed bad rewards accounting. Pair: added a protocol fee tier. Gauge: remove hard-coded calculation in derivedBalance(),  added functions to update rewards by batch, or for all tokens at once. Minter: added functions to update emissions state.
- Does it use rollups?:   false
- Is it multi-chain?:   false
- Does it use a side-chain?:   false
```
## Contact Us

*Xen Discord*: 🗡禅🗡#0369  
*Fly Discord*: flyjgh#0741  
*Scam Discord*: scamilcar#0983  
*Leez Discord*: 0xLeez#7456  
*Rev Discord*: RevolverOcelot#1548  
*7e1e Discord*: 🗡 0x7e1e 🗡 | 3six9 Core#4065  
