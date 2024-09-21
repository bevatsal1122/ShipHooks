// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
}

struct PoolConfig {
    address tokenAddress;
    address owner;
    bool isTokenGated;
    uint256 requiredNFTBalance;
}

contract ERC721TokenGateHook is BaseHook {
    using PoolIdLibrary for PoolKey;

    IERC721 public immutable nftContract;
    mapping(PoolId => PoolConfig) public pools;

    constructor(
        IPoolManager _poolManager,
        IERC721 _nftContract
    ) BaseHook(_poolManager) {
        nftContract = _nftContract;
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
                afterInitialize: false,
                beforeAddLiquidity: false,
                afterAddLiquidity: false,
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

    function setPoolConfig(
        PoolKey calldata key,
        address _tokenAddress,
        bool _isTokenGated,
        uint256 _requiredNFTBalance
    ) external {
        // Note: In a production setting, you'd want to add access control here
        PoolId poolId = key.toId();
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].owner = msg.sender;
        pools[poolId].isTokenGated = _isTokenGated;
        pools[poolId].requiredNFTBalance = _requiredNFTBalance;
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        PoolId poolId = key.toId();
        PoolConfig memory pool = pools[poolId];

        require(pool.tokenAddress != address(0), "Pool not configured");

        if (pool.isTokenGated) {
            require(
                nftContract.balanceOf(sender) >= pool.requiredNFTBalance,
                "Insufficient NFT balance for swap"
            );
        }

        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            0
        );
    }

    // Implement other required functions from BaseHook with empty bodies
    function afterSwap(
        address,
        PoolKey calldata,
        IPoolManager.SwapParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override returns (bytes4, int128) {
        return (BaseHook.afterSwap.selector, 0);
    }

    function beforeAddLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        return BaseHook.beforeAddLiquidity.selector;
    }

    function beforeRemoveLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        return BaseHook.beforeRemoveLiquidity.selector;
    }
}
