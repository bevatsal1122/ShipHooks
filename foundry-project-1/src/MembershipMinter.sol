// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {console} from "forge-std/console.sol";
import "./Constants.sol";
import "./IUniversalRouter.sol";

struct PoolConfig {
    address tokenAddress;
    address owner;
    uint256 requiredTokenAmount;
    uint256 minimumLiquidityUSD;
    mapping(address => bool) hasMintedNFT;
}

contract TokenGatedNFT is BaseHook, Constants, ERC721 {
    using PoolIdLibrary for PoolKey;

    mapping(PoolId => PoolConfig) public pools;
    uint256 private _tokenIdCounter;

    constructor(
        IPoolManager _poolManager
    ) BaseHook(_poolManager) ERC721("LiquidityProviderNFT", "LPNFT") {
        _tokenIdCounter = 0;
    }

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: true,
                beforeAddLiquidity: false,
                afterAddLiquidity: true,
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: true,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    function afterInitialize(
        address sender,
        PoolKey calldata key,
        uint160,
        int24,
        bytes calldata hookData
    ) external override returns (bytes4) {
        address user = getMsgSender(sender);
        (
            address _tokenAddress,
            uint256 _requiredTokenAmount,
            uint256 _minimumLiquidityUSD
        ) = abi.decode(hookData, (address, uint256, uint256));
        PoolId poolId = key.toId();
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].owner = user;
        pools[poolId].requiredTokenAmount = _requiredTokenAmount;
        pools[poolId].minimumLiquidityUSD = _minimumLiquidityUSD;
        return BaseHook.afterInitialize.selector;
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata
    ) external returns (bytes4) {
        address user = getMsgSender(sender);
        PoolId poolId = key.toId();
        PoolConfig storage pool = pools[poolId];

        if (!pool.hasMintedNFT[user]) {
            uint256 liquidityValueUSD = calculateLiquidityValueUSD(key, delta);
            if (liquidityValueUSD >= pool.minimumLiquidityUSD) {
                _mintNFT(user);
                pool.hasMintedNFT[user] = true;
            }
        }

        return BaseHook.afterAddLiquidity.selector;
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external view override returns (bytes4, BeforeSwapDelta, uint24) {
        address user = getMsgSender(sender);
        PoolId poolId = key.toId();
        PoolConfig storage pool = pools[poolId];
        IERC20 token = IERC20(pool.tokenAddress);

        uint256 senderBalance = token.balanceOf(user);
        require(
            senderBalance >= pool.requiredTokenAmount,
            "Swap denied: insufficient token balance"
        );

        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            0
        );
    }

    function setPoolConfig(
        PoolKey calldata key,
        address _tokenAddress,
        uint256 _requiredTokenAmount,
        uint256 _minimumLiquidityUSD
    ) external {
        PoolId poolId = key.toId();
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].requiredTokenAmount = _requiredTokenAmount;
        pools[poolId].minimumLiquidityUSD = _minimumLiquidityUSD;
    }

    function getMinimumLiquidityUSD(
        PoolKey calldata key
    ) external view returns (uint256) {
        PoolId poolId = key.toId();
        return pools[poolId].minimumLiquidityUSD;
    }

    function _mintNFT(address to) internal {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(to, tokenId);
    }

    function calculateLiquidityValueUSD(
        PoolKey calldata key,
        BalanceDelta delta
    ) internal view returns (uint256) {
        // This is a placeholder implementation. In a real-world scenario, you would need to:
        // 1. Get the current price of both tokens in the pool
        // 2. Calculate the USD value of the liquidity added
        // For simplicity, we'll assume 1 token = 1 USD here
        return
            uint256(
                uint128(int128(delta.amount0)) + uint128(int128(delta.amount1))
            );
    }
}
