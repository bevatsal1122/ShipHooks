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

struct poolConfig {
    address tokenAddress;
    address owner;
    uint24 regularFees;
    uint24 reducedFees;
}

contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;

    mapping(PoolId => poolConfig) public pools;

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
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        PoolId poolId = key.toId();

        poolConfig memory pool = pools[poolId];

        IERC20 token = IERC20(pool.tokenAddress);
        uint256 senderBalance = token.balanceOf(sender);

        require(
            senderBalance > 0,
            "Swap denied: sender has zero token balance"
        );

        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            0
        );
    }
}
