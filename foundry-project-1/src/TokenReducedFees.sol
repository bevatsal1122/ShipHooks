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
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import "./Constants.sol";

struct PoolConfig {
    address tokenAddress;
    address owner;
    uint24 regularFees;
    uint24 reducedFees;
}

contract TokenReducedFees is BaseHook, Constants {
    using PoolIdLibrary for PoolKey;

    mapping(PoolId => PoolConfig) public pools;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getPool(PoolId key) public view returns (address) {
        return pools[key].owner;
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
        address user = getMsgSender(sender);

        (uint24 _regularFees, uint24 _reducedFees, address _tokenAddress) = abi
            .decode(hookData, (uint24, uint24, address));

        PoolConfig memory pool = PoolConfig({
            tokenAddress: _tokenAddress,
            owner: user,
            regularFees: _regularFees,
            reducedFees: _reducedFees
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

        IERC20 token = IERC20(pool.tokenAddress);
        uint256 senderBalance = token.balanceOf(user);

        if (senderBalance > 0) {
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
