# NFT Discounted Fee Swap Hook

The Discounted/Reduced Fee Swap hook allows users holding a specific token to benefit from reduced fees when performing swap operations. This incentivizes token holding and can be used as a reward mechanism for your platform's users.

## Usage

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import "./Constants.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
}

struct PoolConfig {
    address tokenAddress;
    address owner;
    uint24 regularFees;
    uint24 reducedFees;
}

contract NFTReducedFees is BaseHook, Constants {
    using PoolIdLibrary for PoolKey;

    IERC721 public immutable nftContract;
    mapping(PoolId => PoolConfig) public pools;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

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

    function afterInitialize(
        address sender,
        PoolKey calldata key,
        uint160,
        int24,
        bytes calldata hookData
    ) external override returns (bytes4) {
        address user = sender;
        (uint24 _regularFees, uint24 _reducedFees, address _tokenAddress) = abi
            .decode(hookData, (uint24, uint24, address));
        PoolConfig memory pool = PoolConfig({
            owner: user,
            regularFees: _regularFees,
            reducedFees: _reducedFees,
            tokenAddress: _tokenAddress
        });
        PoolId poolId = key.toId();
        pools[poolId] = pool;
        return BaseHook.afterInitialize.selector;
    }

    function setPoolConfig(
        PoolKey calldata key,
        uint24 _regularFees,
        uint24 _reducedFees,
        address _tokenAddress
    ) external {
        PoolId poolId = key.toId();
        pools[poolId].regularFees = _regularFees;
        pools[poolId].reducedFees = _reducedFees;
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].owner = msg.sender;
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external view override returns (bytes4, BeforeSwapDelta, uint24) {
        address user = getMsgSender(sender);
        PoolId poolId = key.toId();
        PoolConfig memory pool = pools[poolId];

        require(pool.tokenAddress != address(0), "Pool not configured");

        if (nftContract.balanceOf(user) > 0) {
            return (
                BaseHook.beforeSwap.selector,
                BeforeSwapDeltaLibrary.ZERO_DELTA,
                pool.reducedFees | LPFeeLibrary.OVERRIDE_FEE_FLAG
            );
        } else {
            return (
                BaseHook.beforeSwap.selector,
                BeforeSwapDeltaLibrary.ZERO_DELTA,
                pool.regularFees | LPFeeLibrary.OVERRIDE_FEE_FLAG
            );
        }
    }
}

```
