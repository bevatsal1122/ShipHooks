// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/MembershipMinter.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/types/PoolKey.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

abstract contract MockPoolManager is IPoolManager {
    function initialize(
        PoolKey calldata,
        uint160,
        bytes calldata
    ) external pure returns (int24) {
        return 0;
    }

    function swap(
        PoolKey calldata,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external pure returns (BalanceDelta) {
        return BalanceDelta.wrap(0);
    }

    function modifyPosition(
        PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata
    ) external pure returns (BalanceDelta) {
        return BalanceDelta.wrap(0);
    }

    // Stub implementations for other required functions
    function take(Currency, address, uint256) external pure {}
    function settle(Currency) external pure returns (uint256) {
        return 0;
    }
    function mint(Currency, address, uint256) external pure {}
    function burn(Currency, address, uint256) external pure {}
}

contract MockPoolManagerHarness is MockPoolManager {
    // Implement any additional functions required by the tests
}

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract TokenGatedNFTTest is Test {
    TokenGatedNFT public tokenGatedNFT;
    MockPoolManager public mockPoolManager;
    MockERC20 public mockToken;
    address public user1;
    address public user2;

    function setUp() public {
        mockPoolManager = MockPoolManager(
            address(new MockPoolManagerHarness())
        );
        tokenGatedNFT = new TokenGatedNFT(
            IPoolManager(address(mockPoolManager))
        );
        mockToken = new MockERC20("Mock Token", "MTK");
        user1 = address(0x1);
        user2 = address(0x2);
    }

    function testInitialize() public {
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0)),
            fee: 0,
            tickSpacing: 0,
            hooks: address(tokenGatedNFT)
        });

        bytes memory hookData = abi.encode(address(mockToken), 1000);

        vm.prank(user1);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        (
            address tokenAddress,
            address owner,
            uint256 requiredLimit
        ) = tokenGatedNFT.pools(key.toId());
        assertEq(tokenAddress, address(mockToken));
        assertEq(owner, user1);
        assertEq(requiredLimit, 1000);
    }

    function testAfterAddLiquidity() public {
        // Setup pool
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0)),
            fee: 0,
            tickSpacing: 0,
            hooks: address(tokenGatedNFT)
        });
        bytes memory hookData = abi.encode(address(mockToken), 1000);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        // Add liquidity
        BalanceDelta delta = BalanceDelta.wrap(1000);
        vm.prank(user1);
        tokenGatedNFT.afterAddLiquidity(address(this), key, delta, "");

        // Check if NFT was minted
        assertEq(tokenGatedNFT.balanceOf(user1), 1);
    }

    function testBeforeSwap() public {
        // Setup pool
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0)),
            fee: 0,
            tickSpacing: 0,
            hooks: address(tokenGatedNFT)
        });
        bytes memory hookData = abi.encode(address(mockToken), 1000);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        // Mint tokens to user
        mockToken.mint(user1, 1000);

        // Attempt swap
        IPoolManager.SwapParams memory params;
        vm.prank(user1);
        (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = tokenGatedNFT
            .beforeSwap(address(this), key, params, "");

        // Check if swap was allowed
        assertEq(selector, tokenGatedNFT.beforeSwap.selector);
    }

    function testSwapDenied() public {
        // Setup pool
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0)),
            fee: 0,
            tickSpacing: 0,
            hooks: address(tokenGatedNFT)
        });
        bytes memory hookData = abi.encode(address(mockToken), 1000);
        tokenGatedNFT.afterInitialize(address(this), key, 0, 0, hookData);

        // Attempt swap without sufficient balance
        IPoolManager.SwapParams memory params;
        vm.prank(user2);
        vm.expectRevert("Swap denied: insufficient token balance");
        tokenGatedNFT.beforeSwap(address(this), key, params, "");
    }

    function testSetPoolConfig() public {
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(address(0)),
            fee: 0,
            tickSpacing: 0,
            hooks: address(tokenGatedNFT)
        });

        address newTokenAddress = address(0x123);
        uint256 newRequiredLimit = 2000;

        tokenGatedNFT.setPoolConfig(key, newTokenAddress, newRequiredLimit);

        (address tokenAddress, , uint256 requiredLimit) = tokenGatedNFT.pools(
            key.toId()
        );
        assertEq(tokenAddress, newTokenAddress);
        assertEq(requiredLimit, newRequiredLimit);
    }
}
