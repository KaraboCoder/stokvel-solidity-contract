const { expect } = require("chai");
import { ethers } from "hardhat";

describe("Wallet contract", function () {
  it("Should deploy Wallet contract", async function () {
    const [owner, user1] = await ethers.getSigners();

    const Wallet = await ethers.getContractFactory("Wallet");

    const deployedWalletContract = await Wallet.deploy();

    expect(await deployedWalletContract.owner()).to.equal(owner.address);
  });
});
