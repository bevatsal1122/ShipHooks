// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/MembershipMinter.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract MockPoolManager {
    function getSlot0(PoolId) external pure returns (uint160, int24) {
        return (0, 0);
    }
}

contract TokenGatedNFTTest is Test {
    TokenGatedNFT public hook;
    IPoolManager public poolManager;
    MockERC20 public token0;
    MockERC20 public token1;

    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // Deploy mock contracts
        poolManager = IPoolManager(address(new MockPoolManager()));
        token0 = new MockERC20("Token0", "TKN0");
        token1 = new MockERC20("Token1", "TKN1");

        // Deploy the TokenGatedNFT hook
        hook = new TokenGatedNFT(poolManager);
    }

    function testInitializePool() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(token0)),
            currency1: Currency.wrap(address(token1)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredLimit = 1000 * 10 ** 18; // 1000 USD worth of liquidity
        bytes memory hookData = abi.encode(address(token0), requiredLimit);

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        PoolId poolId = poolKey.toId();
        (address tokenAddress, address owner, uint256 limit) = hook.pools(
            poolId
        );

        assertEq(tokenAddress, address(token0), "Incorrect token address");
        assertEq(owner, alice, "Incorrect pool owner");
        assertEq(limit, requiredLimit, "Incorrect required limit");
    }

    function testAddLiquidityBelowThreshold() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(token0)),
            currency1: Currency.wrap(address(token1)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredLimit = 1000 * 10 ** 18; // 1000 USD worth of liquidity
        bytes memory hookData = abi.encode(address(token0), requiredLimit);

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        // Add liquidity below the threshold
        BalanceDelta delta = BalanceDelta.wrap(int256(500 * 10 ** 18));

        vm.prank(bob);
        hook.afterAddLiquidity(address(this), poolKey, delta, "");

        assertEq(hook.balanceOf(bob), 0, "NFT should not be minted");
    }

    function testAddLiquidityAboveThreshold() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(token0)),
            currency1: Currency.wrap(address(token1)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredLimit = 1000 * 10 ** 18; // 1000 USD worth of liquidity
        bytes memory hookData = abi.encode(address(token0), requiredLimit);

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        // Add liquidity above the threshold
        BalanceDelta delta = BalanceDelta.wrap(int256(600 * 10 ** 18));

        vm.prank(bob);
        hook.afterAddLiquidity(address(this), poolKey, delta, "");

        assertEq(hook.balanceOf(bob), 1, "NFT should be minted");
    }

    function testMultipleAddLiquidity() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(token0)),
            currency1: Currency.wrap(address(token1)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredLimit = 1000 * 10 ** 18; // 1000 USD worth of liquidity
        bytes memory hookData = abi.encode(address(token0), requiredLimit);

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        // Add liquidity in multiple transactions
        BalanceDelta delta1 = BalanceDelta.wrap(int256(400 * 10 ** 18));
        BalanceDelta delta2 = BalanceDelta.wrap(int256(300 * 10 ** 18));
        BalanceDelta delta3 = BalanceDelta.wrap(int256(400 * 10 ** 18));

        vm.startPrank(bob);
        hook.afterAddLiquidity(address(this), poolKey, delta1, "");
        assertEq(hook.balanceOf(bob), 0, "NFT should not be minted yet");

        hook.afterAddLiquidity(address(this), poolKey, delta2, "");
        assertEq(hook.balanceOf(bob), 0, "NFT should not be minted yet");

        hook.afterAddLiquidity(address(this), poolKey, delta3, "");
        assertEq(hook.balanceOf(bob), 1, "NFT should be minted now");

        // Try to add more liquidity, should not mint another NFT
        hook.afterAddLiquidity(address(this), poolKey, delta1, "");
        assertEq(hook.balanceOf(bob), 1, "Only one NFT should be minted");
        vm.stopPrank();
    }
}
