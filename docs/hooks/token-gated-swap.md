# Token-Gated Swap Hook

The Token-Gated Swap hook provides a mechanism to restrict swap operations based on token ownership. This hook ensures that only users holding a specific token or a minimum amount of tokens can perform swap operations.

## Usage

```solidity
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
import "./Constants.sol";
import "./IUniversalRouter.sol";

struct PoolConfig {
    address tokenAddress;
    address owner;
}

contract TokenGated is BaseHook, Constants {
    using PoolIdLibrary for PoolKey;

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
        address _tokenAddress = abi.decode(hookData, (address));
        PoolConfig memory pool = PoolConfig({
            tokenAddress: _tokenAddress,
            owner: user
        });
        PoolId poolId = key.toId();
        pools[poolId] = pool;
        return BaseHook.afterInitialize.selector;
    }

    function setPoolConfig(
        PoolKey calldata key,
        address _tokenAddress
    ) external {
        PoolId poolId = key.toId();
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

```

## Configuration

The `useTokenGatedSwap` hook accepts the following configuration options:

- `requiredToken` (string): The address of the token required to perform the swap.
- `minimumBalance` (string): The minimum balance of the required token, expressed in wei.

## Return Values

The hook returns an object with the following properties:

- `swap` (function): A function to perform the swap operation.
- `loading` (boolean): Indicates whether the hook is currently checking eligibility.
- `error` (Error | null): Any error that occurred during the eligibility check.
- `isEligible` (boolean): Indicates whether the user is eligible to perform the swap.
