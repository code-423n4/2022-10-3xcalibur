import { task } from "hardhat/config";
import BN from "bignumber.js";
import fs from "fs";
import path from "path";

task("deploy", "Deploy contracts").setAction(async (_, { network, ethers, run }) => {
  const configFilePath = path.join(__dirname, "config", network.name + ".json");
  const config = JSON.parse(fs.readFileSync(configFilePath).toString());

  if (!config.weth) throw "No weth address in network's config file";
  if (!config.multisig) throw "No multisig address in network's config file";

  const [deployer] = await ethers.getSigners();
  console.log("Deployer address:", deployer.address);

  // CORE
  const feeCollector = config.multisig;
  const SwapFactory = await ethers.getContractFactory("SwapFactory");
  const swapFactory = await SwapFactory.deploy(feeCollector);
  await swapFactory.deployed();
  console.log("Swap Factory address:", swapFactory.address);

  // PERIPHERY
  const Router = await ethers.getContractFactory("Router");
  const router = await Router.deploy(swapFactory.address, config.weth);
  await router.deployed();
  console.log("Router address:", router.address);

  const RouterUtil = await ethers.getContractFactory("RouterUtil");
  const routerUtil = await RouterUtil.deploy(router.address);
  await routerUtil.deployed();
  console.log("RouterUtil address:", routerUtil.address);

  const Zap = await ethers.getContractFactory("Zap");
  const zap = await Zap.deploy(router.address, swapFactory.address);
  await zap.deployed();
  console.log("Zap address:", zap.address);

  const Multiswap = await ethers.getContractFactory("Multiswap");
  const multiswap = await Multiswap.deploy(router.address);
  await multiswap.deployed();
  console.log("Multiswap address:", multiswap.address);

  const GaugeFactory = await ethers.getContractFactory("GaugeFactory");
  const gaugeFactory = await GaugeFactory.deploy();
  await gaugeFactory.deployed();
  console.log("Gauge Factory address:", gaugeFactory.address);

  const BribeFactory = await ethers.getContractFactory("BribeFactory");
  const bribeFactory = await BribeFactory.deploy();
  await bribeFactory.deployed();
  console.log("Bribe Factory address:", bribeFactory.address);

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Token address:", token.address);

  const VotingEscrow = await ethers.getContractFactory("VotingEscrow");
  const votingEscrow = await VotingEscrow.deploy(token.address);
  await votingEscrow.deployed();
  console.log("Voting Escrow address:", votingEscrow.address);

  const VotingDist = await ethers.getContractFactory("VotingDist");
  const votingDist = await VotingDist.deploy(votingEscrow.address);
  await votingDist.deployed();
  console.log("Voting Distribution address:", votingDist.address);

  const Voter = await ethers.getContractFactory("Voter");
  const voter = await Voter.deploy(
    votingEscrow.address,
    swapFactory.address,
    gaugeFactory.address,
    bribeFactory.address
  );
  await voter.deployed();
  await votingEscrow.setVoter(voter.address);
  console.log("Voter address:", voter.address);

  const Minter = await ethers.getContractFactory("Minter");
  const minter = await Minter.deploy(
    voter.address,
    votingEscrow.address,
    votingDist.address,
    config.multisig,
    new BN(config.xcalSupply).times("0.369").times("0.017").times(1e18).toFixed(0) // 1.7% of the 36.9% allocated for LM
  );
  await minter.deployed();
  console.log("Minter address:", minter.address);

  // 36.9% to LM, the rest to treasury
  const nonLMSupply = new BN(config.xcalSupply).times(new BN("100").minus("36.9").div(100)).times(1e18).toFixed(0);
  let tx = await token.mint(config.multisig, nonLMSupply);
  await tx.wait();
  tx = await token.setMinter(minter.address);
  await tx.wait();

  await votingDist.setDepositor(minter.address);
  await voter.initialize(minter.address);
  await minter.initialize();

  config.swapFactory = swapFactory.address;
  config.router = router.address;
  config.routerUtil = routerUtil.address;
  config.zap = zap.address;
  config.multiswap = multiswap.address;
  config.gaugeFactory = gaugeFactory.address;
  config.bribeFactory = bribeFactory.address;
  config.token = token.address;
  config.votingEscrow = votingEscrow.address;
  config.votingDist = votingDist.address;
  config.voter = voter.address;
  config.minter = minter.address;
  fs.writeFileSync(configFilePath, JSON.stringify(config));

  if (network.name != "hardhat" && network.name != "mainnet_fork") {
    console.log("Verifying contracts...");

    console.log("Verifying SwapFactory");
    await run("verify:verify", {
      address: config.swapFactory,
      constructorArguments: [feeCollector]
    }).catch(console.error);

    console.log("Verifying Router");
    await run("verify:verify", {
      address: config.router,
      constructorArguments: [config.swapFactory, config.weth]
    }).catch(console.error);

    console.log("Verifying RouterUtil");
    await run("verify:verify", {
      address: config.routerUtil,
      constructorArguments: [config.router]
    }).catch(console.error);

    console.log("Verifying Zap");
    await run("verify:verify", {
      address: config.zap,
      constructorArguments: [config.router, config.swapFactory]
    }).catch(console.error);

    console.log("Verifying Multiswap");
    await run("verify:verify", {
      address: config.multiswap,
      constructorArguments: [config.router]
    }).catch(console.error);

    console.log("Verifying GaugeFactory");
    await run("verify:verify", {
      address: config.gaugeFactory,
      constructorArguments: []
    }).catch(console.error);

    console.log("Verifying BribeFactory");
    await run("verify:verify", {
      address: config.bribeFactory,
      constructorArguments: []
    }).catch(console.error);

    console.log("Verifying Token");
    await run("verify:verify", {
      address: config.token,
      constructorArguments: []
    }).catch(console.error);

    console.log("Verifying VotingEscrow");
    await run("verify:verify", {
      address: config.votingEscrow,
      constructorArguments: [config.token]
    }).catch(console.error);

    console.log("Verifying VotingDist");
    await run("verify:verify", {
      address: config.votingDist,
      constructorArguments: [config.votingEscrow]
    }).catch(console.error);

    console.log("Verifying Voter");
    await run("verify:verify", {
      address: config.voter,
      constructorArguments: [config.votingEscrow, config.swapFactory, config.gaugeFactory, config.bribeFactory]
    }).catch(console.error);

    console.log("Verifying Minter");
    await run("verify:verify", {
      address: config.minter,
      constructorArguments: [
        config.voter,
        config.votingEscrow,
        config.votingDist,
        config.multisig,
        new BN(config.xcalSupply).times("0.369").times("0.017").times(1e18).toFixed(0) // 1.7% of the 36.9% allocated for LM
      ]
    }).catch(console.error);
  }
});
