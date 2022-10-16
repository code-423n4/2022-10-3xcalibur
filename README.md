# 3xcalibur contest details

- $46,100 USDC main award pot
- $3,900 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-10-3xcalibur-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 14, 2022 20:00 UTC
- Ends October 19, 2022 20:00 UTC

## Bounty Scope

The following changes makes up the scope of the **3xcalibur 10-2022** contest:

- Changed the whitelisting mechanism in [Voter.sol](contracts/periphery/Voter.sol)
- Changed the fee rate for stable and variable swaps in [SwapFactory.sol](contracts/Core/SwapFactory.sol) and [SwapPair.sol](contracts/Core/SwapPair.sol)
- Allow to change emission strategy every epoch (26 weeks) in [Minter.sol](contracts/periphery/Minter.sol)
- Added an optional boost to the global weekly emission amount in [Minter.sol](contracts/periphery/Minter.sol)
- Added the [Multiswap.sol](contracts/periphery/Multiswap.sol) contract to allow for swaps targeting multiple tokens at once
- Corrected rewards calculation [Bribe.sol](contracts/periphery/Bribe.sol) and [Gauge.sol](contracts/periphery/Gauge.sol)

## Contracts

|File|LoC|Libraries|Interfaces|
|:-|:-:|:-:|:-:|
|_Contracts (7)_|
|[contracts/periphery/Bribe.sol](contracts/periphery/Bribe.sol)|351|1|3|-|
|[contracts/periphery/Voter.sol](contracts/periphery/Voter.sol)|298|1|9
|[contracts/periphery/Gauge.sol](contracts/periphery/Gauge.sol)|442|1|6|
|[contracts/Core/SwapPair.sol](contracts/Core/SwapPair.sol)|427|1|3|
|[contracts/Core/SwapFactory.sol](contracts/Core/SwapFactory.sol)|59|0|0|
|[contracts/periphery/Minter.sol](contracts/periphery/Minter.sol)|95|2|4|
|[contracts/periphery/Multiswap.sol](contracts/periphery/Multiswap.sol)|76|0|0|
|Total in scope|1748|3|29|

## Description

**3xcalibur** is a decentralized exchange and liquidity protocol on Arbitrum nitro.  
It is a fork of the Solidly protocol, which notably introduced $ x3y + y3x = k $ pools for concentrated stable-swaps, and improved on the Curve's emission mechanism.  
  
We further improved on Solidly by allowing to use more complex emisson schedule strategies, added modifications to the governance mechanism, added convenience contracts to improve user experience, correcting bugs and redesigned tokenomics.  

## Tokens

The **XCAL** token is an ERC20 token with 18 decimals.  
It is the main token of the protocol.  
It can be locked in exchange for a VeNFT token that grants user voting power to direct the protocol's emissions, proportional to the locked amount and lock duration.

**VeNFTs** are ERC721 tokens.  
They encode the amount and duration of the lock, and can be transferred to other users.  
Can be used to direct emissions by voting for gauges (through the [Voter](contracts/periphery/Voter.sol) contract).  

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
```

to run the test files, first install the dependencies:

```bash
npm install @openzeppelin/contracts
forge install foundry-rs/forge-std --no-commit
forge install transmissions11/solmate --no-commit
```

Launch a forked blockchain instance at port `http://127.0.0.1:8545/`:

```bash
# example
anvil -f https://arb1.arbitrum.io/rpc
```

then call

```bash
forge test --force
```

To get code coverage:

```bash
forge coverage
```

## Contact Us

*Xen Discord*: 🗡禅🗡#0369  
*Fly Discord*: flyjgh#0741  
*Scam Discord*: scamilcar#0983  
*Leez Discord*: 0xLeez#7456  
*Rev Discord*: RevolverOcelot#1548  
*7e1e Discord*: 🗡 0x7e1e 🗡 | 3six9 Core#4065  
