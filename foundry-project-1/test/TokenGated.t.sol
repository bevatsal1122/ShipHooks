// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {TokenGated} from "../src/TokenGated.sol";

import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {EasyPosm} from "./utils/EasyPosm.sol";
import {Fixtures} from "./utils/Fixtures.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

struct PoolConfig {
    address tokenAddress;
    address owner;
}

contract TokenGatedTest is Test, Fixtures {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    TokenGated hook;
    PoolId poolId;

    uint256 tokenId;
    int24 tickLower;
    int24 tickUpper;

    // IERC20 public testToken;
    address testToken = 0xe054a54585A403FD5B518339E761D6e1CAB40Bfa;

    address public user1;
    address public user2;

    function setUp() public {
        console.log("Entering setup");

        // Setup test users
        user1 = address(0x1);
        // user1 = 0xB21B95E4343242Ed55be7E9ce34C9F2Bc97B4b09;
        user2 = address(0x2);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        // creates the pool manager, utility routers, and test tokens
        deployFreshManagerAndRouters();
        deployMintAndApprove2Currencies();

        deployAndApprovePosm(manager);

        // // Deploy a test ERC20 token

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_INITIALIZE_FLAG) ^
                (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        bytes memory constructorArgs = abi.encode(manager);
        deployCodeTo("TokenGated.sol:TokenGated", constructorArgs, flags);
        hook = TokenGated(flags);

        // Create the pool
        key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));

        poolId = key.toId();

        bytes memory initData = abi.encode(testToken);
        manager.initialize(key, SQRT_PRICE_1_1, initData);

        // Provide full-range liquidity to the pool
        tickLower = TickMath.minUsableTick(key.tickSpacing);
        tickUpper = TickMath.maxUsableTick(key.tickSpacing);

        uint128 liquidityAmount = 100e18;

        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts
            .getAmountsForLiquidity(
                SQRT_PRICE_1_1,
                TickMath.getSqrtPriceAtTick(tickLower),
                TickMath.getSqrtPriceAtTick(tickUpper),
                liquidityAmount
            );

        (tokenId, ) = posm.mint(
            key,
            tickLower,
            tickUpper,
            liquidityAmount,
            amount0Expected + 1,
            amount1Expected + 1,
            address(this),
            block.timestamp,
            ZERO_BYTES
        );
    }

    function testPoolInitialization() view public {
        (address tokenAddress, address owner) = hook.pools(poolId);
        assertEq(tokenAddress, testToken);
    }

    function testUpdatePoolConfig() public {
        address newTokenAddress = address(0x123);

        hook.setPoolConfig(key, newTokenAddress);

        (address tokenAddress, address owner) = hook.pools(poolId);
        assertEq(tokenAddress, newTokenAddress);
    }

    function testBeforeSwapWhenVoid() public {
        vm.prank(user1);

        bool zeroForOne = true;
        int256 amountSpecified = -1e18;

        uint256 initialBalance = IERC20(testToken).balanceOf(user1);

        console.log("initialBalance");
        console.log(initialBalance);

        BalanceDelta swapDelta = swap(
            key,
            zeroForOne,
            amountSpecified,
            ZERO_BYTES
        );

        // vm.expectRevert(
        //     "TokenGated testBeforeSwapWhenVoid(): Cannot swap if token balance is 0."
        // );

        // int256 finalBalance = int256(IERC20(testToken).balanceOf(user1));

        // int256 expectedBalance = int256(initialBalance) + (amountSpecified);

        // assertEq(
        //     finalBalance,
        //     expectedBalance,
        //     "Final balance is not equal to expected balance"
        // );
    }
}
