// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NFTGated.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/types/PoolKey.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

// Define any missing structs and types required by Uniswap V4 or your mock
struct Slot0 {
    uint160 sqrtPriceX96;
    int24 tick;
    uint8 protocolFee;
    uint8 swapFee;
    int24 tickSpacing;
    bool hookData;
    uint8 hookExtraData;
}

struct BalanceDeltaNew {
    int256 amount0;
    int256 amount1;
}

// Dummy ModifyPositionParams struct for testing purposes
struct ModifyPositionParams {
    address owner;
    int24 tickLower;
    int24 tickUpper;
    uint128 liquidityDelta;
}

// MockPoolManager contract implementation
contract MockPoolManager is IPoolManager {
    function getSlot0(
        PoolId poolId
    ) external pure override returns (Slot0 memory) {
        // Return a dummy Slot0 struct
        return
            Slot0({
                sqrtPriceX96: 0,
                tick: 0,
                protocolFee: 0,
                swapFee: 0,
                tickSpacing: 0,
                hookData: false,
                hookExtraData: 0
            });
    }

    // Implement other required functions with minimal functionality
    function initialize(
        PoolKey memory,
        uint160,
        bytes calldata
    ) external override returns (int24, int24, uint256) {
        return (0, 0, 0);
    }

    function modifyPosition(
        PoolKey memory,
        ModifyPositionParams memory,
        bytes calldata
    ) external override returns (BalanceDelta memory) {
        return BalanceDelta(0, 0);
    }

    function swap(
        PoolKey memory,
        IPoolManager.SwapParams memory,
        bytes calldata
    ) external override returns (BalanceDelta memory) {
        return BalanceDelta(0, 0);
    }

    function donate(
        PoolKey memory,
        uint256,
        uint256,
        bytes calldata
    ) external override returns (BalanceDelta memory) {
        return BalanceDelta(0, 0);
    }

    function take(
        PoolKey memory,
        int256,
        int256,
        bytes calldata
    ) external override returns (BalanceDelta memory) {
        return BalanceDelta(0, 0);
    }

    function settle(
        address
    ) external payable override returns (BalanceDelta memory) {
        return BalanceDelta(0, 0);
    }

    function mint(address, uint256) external {}

    function burn(uint256) external {}

    function transfer(address, uint256) external pure returns (bool) {
        return true;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) external pure returns (bool) {
        return true;
    }
}

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract NFTGatedTest is Test {
    NFTGated public nftGated;
    MockPoolManager public mockPoolManager;
    MockNFT public mockNFT;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        mockPoolManager = new MockPoolManager();
        mockNFT = new MockNFT();
        nftGated = new NFTGated(IPoolManager(address(mockPoolManager)));
    }

    function testAfterInitialize() public {
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockNFT), 1);

        vm.prank(owner);
        nftGated.afterInitialize(address(this), key, 0, 0, hookData);

        PoolId poolId = PoolIdLibrary.toId(key);
        (
            address nftAddress,
            address poolOwner,
            uint256 requiredNFTBalance
        ) = nftGated.pools(poolId);

        assertEq(nftAddress, address(mockNFT));
        assertEq(poolOwner, owner);
        assertEq(requiredNFTBalance, 1);
    }

    function testSetPoolConfig() public {
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );

        vm.prank(owner);
        nftGated.setPoolConfig(key, address(mockNFT), 2);

        PoolId poolId = PoolIdLibrary.toId(key);
        (address nftAddress, , uint256 requiredNFTBalance) = nftGated.pools(
            poolId
        );

        assertEq(nftAddress, address(mockNFT));
        assertEq(requiredNFTBalance, 2);
    }

    function testBeforeSwapWithSufficientNFTs() public {
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockNFT), 1);

        vm.prank(owner);
        nftGated.afterInitialize(address(this), key, 0, 0, hookData);

        // Mint NFT for the user
        mockNFT.mint(user, 1);

        IPoolManager.SwapParams memory params;

        vm.prank(user);
        (bytes4 selector, BeforeSwapDelta memory delta, uint24 fee) = nftGated
            .beforeSwap(address(this), key, params, "");

        assertEq(selector, NFTGated.beforeSwap.selector);
    }

    function testBeforeSwapWithInsufficientNFTs() public {
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockNFT), 1);

        vm.prank(owner);
        nftGated.afterInitialize(address(this), key, 0, 0, hookData);

        IPoolManager.SwapParams memory params;

        vm.prank(user);
        vm.expectRevert("Swap denied: insufficient NFT balance");
        nftGated.beforeSwap(address(this), key, params, "");
    }

    function testBeforeSwapWithHigherRequiredBalance() public {
        PoolKey memory key = PoolKey(
            address(0),
            address(0),
            0,
            0,
            IHooks(address(0))
        );
        bytes memory hookData = abi.encode(address(mockNFT), 2);

        vm.prank(owner);
        nftGated.afterInitialize(address(this), key, 0, 0, hookData);

        // Mint only one NFT for the user
        mockNFT.mint(user, 1);

        IPoolManager.SwapParams memory params;

        vm.prank(user);
        vm.expectRevert("Swap denied: insufficient NFT balance");
        nftGated.beforeSwap(address(this), key, params, "");
    }

    function testMultiplePoolConfigurations() public {
        PoolKey memory key1 = PoolKey(
            address(1),
            address(2),
            0,
            0,
            IHooks(address(0))
        );
        PoolKey memory key2 = PoolKey(
            address(3),
            address(4),
            0,
            0,
            IHooks(address(0))
        );

        bytes memory hookData1 = abi.encode(address(mockNFT), 1);
        bytes memory hookData2 = abi.encode(address(mockNFT), 2);

        vm.prank(owner);
        nftGated.afterInitialize(address(this), key1, 0, 0, hookData1);

        vm.prank(owner);
        nftGated.afterInitialize(address(this), key2, 0, 0, hookData2);

        PoolId poolId1 = PoolIdLibrary.toId(key1);
        PoolId poolId2 = PoolIdLibrary.toId(key2);

        (, , uint256 requiredNFTBalance1) = nftGated.pools(poolId1);
        (, , uint256 requiredNFTBalance2) = nftGated.pools(poolId2);

        assertEq(requiredNFTBalance1, 1);
        assertEq(requiredNFTBalance2, 2);
    }
}
