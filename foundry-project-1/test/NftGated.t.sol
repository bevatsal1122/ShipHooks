// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NFTGated.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/types/PoolKey.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockPoolManager is IPoolManager {
    function getSlot0(PoolId) external pure override returns (Slot0) {}
    // Implement other required functions...
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
        (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = nftGated
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
