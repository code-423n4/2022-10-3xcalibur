# ✨ So you want to sponsor a contest

This `README.md` contains a set of checklists for our contest collaboration.

Your contest will use two repos: 
- **a _contest_ repo** (this one), which is used for scoping your contest and for providing information to contestants (wardens)
- **a _findings_ repo**, where issues are submitted (shared with you after the contest) 

Ultimately, when we launch the contest, this contest repo will be made public and will contain the smart contracts to be reviewed and all the information needed for contest participants. The findings repo will be made public after the contest report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the contest sponsor (⭐️)**.

---

# Contest setup

## ⭐️ Sponsor: Provide contest details

Under "SPONSORS ADD INFO HERE" heading below, include the following:

- [] Create a PR to this repo with the below changes:
- [✓] Name of each contract and:
  - [✓] source lines of code (excluding blank lines and comments) in each
  - [✓] external contracts called in each
  - [✓] libraries used in each
- [✓] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [✓] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [✓] Describe anything else that adds any special logic that makes your approach unique
- [ ] Identify any areas of specific concern in reviewing the code
- [ ] Add all of the code to this repo that you want reviewed


---

# Contest prep

## ⭐️ Sponsor: Contest prep
- [ ] Provide a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2021-06-gro/blob/main/README.md))
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 24 hours prior to contest start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the contest — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the contest. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)
- [ ] Promote the contest on Twitter (optional: tag in relevant protocols, etc.)
- [ ] Share it with your own communities (blog, Discord, Telegram, email newsletters, etc.)
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# 3xcalibur contest details
- $46,100 USDC main award pot
- $3,900 USDC gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-10-3xcalibur-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 14, 2022 20:00 UTC
- Ends October 19, 2022 20:00 UTC

[ ⭐️ SPONSORS ADD INFO HERE ]

## Scope

The following changes makes up the scope of the **3xcalibur 10-2022** contest:
- Changed the whitelisting mechanism in [Voter.sol](contracts/periphery/Voter.sol)
- Changed the fee rate for stable and variable swaps in [SwapFactory.sol](contracts/core/SwapFactory.sol) and [SwapPair.sol](contracts/core/SwapPair.sol)
- Allow to change emission strategy every epoch (26 weeks) in [Minter.sol](contracts/periphery/Minter.sol)
- Added an optional boost to the global weekly emission amount in [Minter.sol](contracts/periphery/Minter.sol)
- Added the [Multiswap.sol](contracts/core/Multiswap.sol) contract to allow for swaps targeting multiple tokens at once
- Corrected rewards calculation [Bribe.sol](contracts/periphery/Bribe.sol) and [Gauge.sol](contracts/periphery/Gauge.sol)

## Contracts

|File|LoC|Libraries|Interfaces|
|:-|:-:|:-:|:-:|
|_Contracts (7)_|
|[contracts/periphery/Bribe.sol](contracts/periphery/Bribe.sol)|351|1|3|-|
|[contracts/periphery/Voter.sol](contracts/periphery/Voter.sol)|298|1|9
|[contracts/periphery/Gauge.sol](contracts/periphery/Gauge.sol)|442|1|6|
|[contracts/core/SwapPair.sol](contracts/core/SwapPair.sol)|427|1|3|
|[contracts/core/SwapFactory.sol](contracts/core/SwapFactory.sol)|59|0|0|
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

## Contact Us:

*Xen Discord*: 🗡禅🗡#0369  
*Fly Discord*: flyjgh#0741  
*Scam Discord*: scamilcar#0983  
*Leez Discord*: 0xLeez#7456  
*Rev Discord*: RevolverOcelot#1548  
*7e1e Discord*: 🗡 0x7e1e 🗡 | 3six9 Core#4065  
