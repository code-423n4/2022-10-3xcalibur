import fs from "fs";
import path from "path";
import { BigNumber } from "ethers";
import { types, task } from "hardhat/config";

const _config = (networkName: string) => {
  const configFilePath = path.join(__dirname, "config", networkName + ".json");
  return JSON.parse(fs.readFileSync(configFilePath).toString());
};

task("mint-token", "Mint Token")
  .addParam("account", "Address to mint toknes to")
  .addParam("amount", "Tokens amount to mint", undefined, types.int)
  .setAction(async ({ amount, account }, { network, ethers }) => {
    const config = _config(network.name);

    if (!config.token) throw "No Token address in network's config file";

    const [signer] = await ethers.getSigners();
    console.log("Signer: ", signer.address);

    const token = await ethers.getContractAt("Token", config.token, signer);
    console.log(`Minting ${amount} tokens to ${account}`);
    await (await token.mint(account, ethers.utils.parseEther(amount.toString()))).wait();

    const balance = await token.balanceOf(account);
    console.log("New token balance:", ethers.utils.formatEther(balance));

    console.log("All done.");
  });

task("approve-token", "Approve Token")
  .addParam("token", "Token")
  .addParam("spender", "Spender")
  .setAction(async ({ token, spender }, { network, ethers }) => {
    const MaxUint256: BigNumber = BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");

    const [signer] = await ethers.getSigners();
    console.log("Signer: ", signer.address);

    const erc20 = await ethers.getContractAt("ERC20", token, signer);
    const tx = await erc20.approve(spender, MaxUint256, { gasLimit: 250000 });
    console.log("tx:", tx.hash);
    await tx.wait();

    const allowance = await erc20.allowance(signer.address, spender);
    console.log("New token allowance:", ethers.utils.formatEther(allowance));

    console.log("All done.");
  });
