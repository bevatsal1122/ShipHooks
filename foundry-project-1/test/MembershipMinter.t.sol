// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/MembershipMinter.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/types/PoolKey.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v4-core/src/types/PoolId.sol";

contract TokenGatedNFTTest is Test {
    TokenGatedNFT public tokenGatedNFT;
    IPoolManager public mockPoolManager;
    IERC20 public mockToken;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        mockPoolManager = IPoolManager(address(new MockPoolManager()));
        mockToken = IERC20(address(new MockERC20()));
        tokenGatedNFT = new TokenGatedNFT(mockPoolManager);
    }

    function testInitialize() public {
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        uint160 sqrtPriceX96 = 0;
        int24 tick = 0;
        bytes memory hookData = abi.encode(address(mockToken), 1000);

        vm.prank(owner);
        tokenGatedNFT.afterInitialize(
            address(this),
            key,
            sqrtPriceX96,
            tick,
            hookData
        );

        PoolId poolId = PoolIdLibrary.toId(key);
        (
            address tokenAddress,
            address poolOwner,
            uint256 requiredLimit
        ) = tokenGatedNFT.pools(poolId);

        assertEq(tokenAddress, address(mockToken));
        assertEq(poolOwner, owner);
        assertEq(requiredLimit, 1000);
    }

    function testAddLiquidity() public {
        // Setup pool
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockToken), 1000);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        // Mock liquidity addition
        IPoolManager.ModifyLiquidityParams memory params;
        BalanceDelta delta = BalanceDelta(int256(1000), int256(1000));

        vm.prank(user);
        tokenGatedNFT.afterAddLiquidity(address(this), key, params, delta, "");

        assertTrue(tokenGatedNFT.balanceOf(user) == 1);
    }

    function testSwapWithInsufficientBalance() public {
        // Setup pool
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockToken), 1000);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        // Mock swap attempt
        IPoolManager.SwapParams memory params;

        vm.prank(user);
        vm.expectRevert("Swap denied: insufficient token balance");
        tokenGatedNFT.beforeSwap(address(this), key, params, "");
    }

    function testSwapWithSufficientBalance() public {
        // Setup pool
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockToken), 1000);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        // Set user balance
        MockERC20(address(mockToken)).mint(user, 1000);

        // Mock swap attempt
        IPoolManager.SwapParams memory params;

        vm.prank(user);
        (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = tokenGatedNFT
            .beforeSwap(address(this), key, params, "");

        assertEq(selector, TokenGatedNFT.beforeSwap.selector);
    }
}

// Mock contracts for testing
contract MockPoolManager is IPoolManager {
    function getSlot0(PoolId poolId) external pure override returns (Slot0) {
        // Return a dummy Slot0 struct
        return Slot0(0, 0, 0, 0, 0, false, 0);
    }
    // Implement other required functions...
}

contract MockERC20 is IERC20 {
    mapping(address => uint256) private _balances;

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    // Implement other required functions...
}
