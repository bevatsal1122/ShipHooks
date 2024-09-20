// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;

    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    mapping(PoolId => uint24) public regularFees;
    mapping(PoolId => uint24) public reducedFees;

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
                beforeAddLiquidity: true,
                afterAddLiquidity: false,
                beforeRemoveLiquidity: true,
                afterRemoveLiquidity: false,
                beforeSwap: true,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    function setPoolFees(
        PoolKey calldata key,
        uint24 _regularFees,
        uint24 _reducedFees
    ) external {
        // Note: In a production setting, you'd want to add access control here
        PoolId poolId = key.toId();
        regularFees[poolId] = _regularFees;
        reducedFees[poolId] = _reducedFees;
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata,
        address tokenAddress
    )
        external
        returns (
            // override
            bytes4,
            BeforeSwapDelta,
            uint24
        )
    {
        PoolId poolId = key.toId();

        IERC20 token = IERC20(tokenAddress);
        uint256 senderBalance = token.balanceOf(sender);

        if (senderBalance > 0) {
            return (
                BaseHook.beforeSwap.selector,
                BeforeSwapDeltaLibrary.ZERO_DELTA,
                reducedFees[poolId]
            );
        } else {
            return (
                BaseHook.beforeSwap.selector,
                BeforeSwapDeltaLibrary.ZERO_DELTA,
                regularFees[poolId]
            );
        }
    }
}
