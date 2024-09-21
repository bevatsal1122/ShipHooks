// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NFTGated.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTGatedTest is Test {
    NFTGated public hook;
    IPoolManager public poolManager;
    MockERC721 public mockNFT;

    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // Deploy a mock pool manager
        poolManager = IPoolManager(address(new MockPoolManager()));

        // Deploy the NFTGated hook
        hook = new NFTGated(poolManager);

        // Deploy a mock NFT
        mockNFT = new MockERC721();
    }

    function testInitializePool() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(0x1)),
            currency1: Currency.wrap(address(0x2)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredNFTBalance = 1;
        bytes memory hookData = abi.encode(
            address(mockNFT),
            requiredNFTBalance
        );

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        PoolId poolId = poolKey.toId();
        (address nftAddress, address owner, uint256 nftBalance) = hook.pools(
            poolId
        );

        assertEq(nftAddress, address(mockNFT), "Incorrect NFT address");
        assertEq(owner, alice, "Incorrect pool owner");
        assertEq(
            nftBalance,
            requiredNFTBalance,
            "Incorrect required NFT balance"
        );
    }

    function testBeforeSwapWithSufficientNFTs() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(0x1)),
            currency1: Currency.wrap(address(0x2)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredNFTBalance = 1;
        bytes memory hookData = abi.encode(
            address(mockNFT),
            requiredNFTBalance
        );

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        // Mint NFT to Bob
        mockNFT.mint(bob, 1);

        IPoolManager.SwapParams memory params;
        vm.prank(bob);
        (bytes4 selector, BeforeSwapDelta delta, uint24 fee) = hook.beforeSwap(
            address(this),
            poolKey,
            params,
            ""
        );

        assertEq(
            selector,
            NFTGated.beforeSwap.selector,
            "Incorrect selector returned"
        );
        // Add more assertions as needed
    }

    function testBeforeSwapWithInsufficientNFTs() public {
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(address(0x1)),
            currency1: Currency.wrap(address(0x2)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });

        uint256 requiredNFTBalance = 1;
        bytes memory hookData = abi.encode(
            address(mockNFT),
            requiredNFTBalance
        );

        vm.prank(alice);
        hook.afterInitialize(address(this), poolKey, 0, 0, hookData);

        // Don't mint any NFTs to Bob

        IPoolManager.SwapParams memory params;
        vm.prank(bob);
        vm.expectRevert("Swap denied: insufficient NFT balance");
        hook.beforeSwap(address(this), poolKey, params, "");
    }
}

// Mock contracts and interfaces

contract MockPoolManager {
    // Add necessary functions to mock IPoolManager
}
