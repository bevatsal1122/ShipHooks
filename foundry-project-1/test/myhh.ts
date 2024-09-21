const { expect } = require("chai");
const { ethers } = require("ethers");
const hre = require("hardhat");

describe("Counter", function () {
  it("Should set the right unlockTime", async function () {
    // deploy a lock contract where funds can be withdrawn
    // one year in the future

    const lock = await hre.ethers.deployContract("Counter", [], {
      value: 0,
    });

    // assert that the value is correct
    expect(await lock.beforeSwapCount()).to.equal(ethers.toBigInt(0));
  });
});
