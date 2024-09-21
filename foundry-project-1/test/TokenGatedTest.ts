const { expect } = require("chai");
const { ethers } = require("hardhat");
const { TickMath, LiquidityAmounts, PoolIdLibrary, Hooks } = require("@uniswap/v4-sdk");
// const { deployFreshManagerAndRouters, deployMintAndApprove2Currencies, deployAndApprovePosm } = require("./helpers");



describe("TokenGatedTest", function () {
  let TokenGated, tokenGated, testToken, user1, user2, manager, posm;
  let poolId, tickLower, tickUpper, tokenId, liquidityAmount;
  let currency0, currency1, key, SQRT_PRICE_1_1;
  const ZERO_BYTES = "0x";

  beforeEach(async function () {
    console.log("Entering setup");

    const [owner, user1, user2] = await ethers.getSigners();

    // Setup initial balances for user1 and user2
    await ethers.provider.send("hardhat_setBalance", [
      user1.address,
      "0x56BC75E2D63100000", // 100 ether in hex
    ]);
    await ethers.provider.send("hardhat_setBalance", [
      user2.address,
      "0x56BC75E2D63100000", // 100 ether in hex
    ]);

    // Deploy Pool Manager, Utility Routers, Test Tokens
    manager = await deployFreshManagerAndRouters();
    [currency0, currency1] = await deployMintAndApprove2Currencies();

    posm = await deployAndApprovePosm(manager);

    
    testToken = "0xFCcEAa75A086d8a1AF0626b3B3ac1f6A89347b2D";

    // Deploy TokenGated hook
    const TokenGatedFactory = await ethers.getContractFactory("TokenGated");
    const flags = ethers.BigNumber.from(
      ethers.utils.hexlify(
        Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_INITIALIZE_FLAG
      )
    ).xor(ethers.BigNumber.from("0x4444").shl(144));
    
    tokenGated = await TokenGatedFactory.deploy(manager.address, flags);

    // Create pool key and initialize the pool
    key = { currency0, currency1, fee: 3000, tickSpacing: 60, hook: tokenGated.address };
    poolId = PoolIdLibrary.toId(key);
    SQRT_PRICE_1_1 = ... // Define the sqrt price here

    await manager.initialize(key, SQRT_PRICE_1_1, ethers.utils.defaultAbiCoder.encode(["address"], [testToken]));

    // Provide liquidity to the pool
    tickLower = TickMath.minUsableTick(key.tickSpacing);
    tickUpper = TickMath.maxUsableTick(key.tickSpacing);
    liquidityAmount = ethers.utils.parseUnits("100", 18);

    const [amount0Expected, amount1Expected] = await LiquidityAmounts.getAmountsForLiquidity(
      SQRT_PRICE_1_1,
      TickMath.getSqrtPriceAtTick(tickLower),
      TickMath.getSqrtPriceAtTick(tickUpper),
      liquidityAmount
    );

    tokenId = await posm.mint(key, tickLower, tickUpper, liquidityAmount, amount0Expected.add(1), amount1Expected.add(1), owner.address, Date.now(), ZERO_BYTES);
  });

  it("Should initialize the pool", async function () {
    const poolData = await tokenGated.pools(poolId);
    expect(poolData.tokenAddress).to.equal(testToken);
  });

  it("Should update pool config", async function () {
    const newTokenAddress = "0x0000000000000000000000000000000000000123";

    await tokenGated.setPoolConfig(key, newTokenAddress);

    const poolData = await tokenGated.pools(poolId);
    expect(poolData.tokenAddress).to.equal(newTokenAddress);
  });

  it("Should revert before swap if balance is zero", async function () {
    const zeroForOne = true;
    const amountSpecified = ethers.utils.parseUnits("-1", 18);

    const initialBalance = await ethers.provider.getBalance(user1.address);
    console.log("initialBalance", initialBalance.toString());

    await expect(
      manager.connect(user1).swap(key, zeroForOne, amountSpecified, ZERO_BYTES)
    ).to.be.revertedWith("Swap denied: sender has zero token balance");
  });
});
