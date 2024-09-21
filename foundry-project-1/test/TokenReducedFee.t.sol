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
import {TokenReducedFees} from "../src/TokenReducedFees.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";

import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {EasyPosm} from "./utils/EasyPosm.sol";
import {Fixtures} from "./utils/Fixtures.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

struct PoolConfig {
    address tokenAddress;
    address owner;
    uint24 regularFees;
    uint24 reducedFees;
}

contract TokenReducedFeesTest is Test, Fixtures {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    TokenReducedFees hook;
    PoolId poolId;

    uint256 tokenId;
    int24 tickLower;
    int24 tickUpper;

    // IERC20 public testToken;
    address testToken = 0x725E70b79c985b4E98A6C91c1F6dD7C4fe4FB667;

    address public user1;
    address public user2;

    uint24 constant REGULAR_FEE = 3000; // 0.3%
    uint24 constant REDUCED_FEE = 500; // 0.05%

    function setUp() public {
        console.log("Entering setup");

        // Setup test users
        user1 = address(0x1);
        user2 = address(0x2);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        // creates the pool manager, utility routers, and test tokens
        deployFreshManagerAndRouters();
        deployMintAndApprove2Currencies();

        deployAndApprovePosm(manager);

        // Deploy a test ERC20 token

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_INITIALIZE_FLAG) ^
                (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        bytes memory constructorArgs = abi.encode(manager);
        deployCodeTo(
            "TokenReducedFees.sol:TokenReducedFees",
            constructorArgs,
            flags
        );
        hook = TokenReducedFees(flags);

        // Create the pool
        key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));

        poolId = key.toId();

        bytes memory initData = abi.encode(REGULAR_FEE, REDUCED_FEE, testToken);
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

    function testPoolInitialization() public {
        (
            address tokenAddress,
            address owner,
            uint24 regularFees,
            uint24 reducedFees
        ) = hook.pools(poolId);
        assertEq(tokenAddress, address(testToken));
        assertEq(regularFees, REGULAR_FEE);
        assertEq(reducedFees, REDUCED_FEE);
    }

    function testReducedFees() public {
        // Swap as user1 (should get reduced fees)
        vm.prank(user1);

        bool zeroForOne = true;
        int256 amountSpecified = -1e18;

        BalanceDelta swapDelta = swap(
            key,
            zeroForOne,
            amountSpecified,
            ZERO_BYTES
        );

        // Check that the correct fee was applied
        uint256 actualFee = uint256(
            int256(swapDelta.amount0()) - amountSpecified
        );
        uint256 expectedFee = (uint256(-amountSpecified) * REDUCED_FEE) / 1e6;
        assertEq(actualFee, expectedFee, "Reduced fee not applied correctly");
    }

    function testRegularFees() public {
        // Swap as user2 (should get regular fees)
        vm.prank(user2);
        bool zeroForOne = true;
        int256 amountSpecified = -1e18;

        BalanceDelta swapDelta = swap(
            key,
            zeroForOne,
            amountSpecified,
            ZERO_BYTES
        );

        // Check that the correct fee was applied
        uint256 actualFee = uint256(
            int256(swapDelta.amount0()) - amountSpecified
        );
        uint256 expectedFee = (uint256(-amountSpecified) * REGULAR_FEE) / 1e6;
        assertEq(actualFee, expectedFee, "Regular fee not applied correctly");
    }

    function testUpdatePoolConfig() public {
        uint24 newRegularFee = 4000; // 0.4%
        uint24 newReducedFee = 1000; // 0.1%
        address newTokenAddress = address(0x123);

        hook.setPoolConfig(key, newRegularFee, newReducedFee, newTokenAddress);

        (
            address tokenAddress,
            address owner,
            uint24 regularFees,
            uint24 reducedFees
        ) = hook.pools(poolId);
        assertEq(tokenAddress, newTokenAddress);
        assertEq(regularFees, newRegularFee);
        assertEq(reducedFees, newReducedFee);
    }
}
