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

struct PoolConfig {
    address tokenAddress;
    address owner;
    address vault;
    uint256 minSwapAmount;
    uint256 rewardTokenAmount;
}

contract TokenRewardsOnSwap is BaseHook, Constants {
    using PoolIdLibrary for PoolKey;

    // Ethereum Sepolia
    address USDCToken = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

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
                beforeSwap: false,
                afterSwap: true,
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
            address _rewardsTokenStockAddress,
            int24 _minimumQualificationAmount,
            int24 _rewardTokenAmount
        ) = abi.decode(hookData, (address, address, int24, int24));

        PoolConfig memory pool = PoolConfig({
            owner: user,
            vault: _rewardsTokenStockAddress,
            minSwapAmount: uint256(int256(int128(_minimumQualificationAmount))),
            rewardTokenAmount: uint256(int256(int128(_rewardTokenAmount))),
            tokenAddress: _tokenAddress
        });
        PoolId poolId = key.toId();
        pools[poolId] = pool;
        return BaseHook.afterInitialize.selector;
    }

    function setPoolConfig(
        PoolKey calldata key,
        address _tokenAddress,
        address __rewardsTokenStockAddress,
        int24 _minimumQualificationAmount,
        int24 _rewardTokenAmount
    ) external {
        PoolId poolId = key.toId();
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].vault = __rewardsTokenStockAddress;
        pools[poolId].minSwapAmount = uint256(
            int256(int128(_minimumQualificationAmount))
        );
        pools[poolId].rewardTokenAmount = uint256(
            int256(int128(_rewardTokenAmount))
        );
    }

    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        BalanceDelta delta,
        bytes calldata
    ) external override returns (bytes4, int128) {
        address user = getMsgSender(sender);

        PoolId poolId = key.toId();
        PoolConfig memory pool = pools[poolId];
        IERC20 token = IERC20(pool.tokenAddress);
        uint256 senderBalance = token.balanceOf(user);

        require(
            senderBalance > 0,
            "Swap denied: sender has zero token balance"
        );

        uint256 swapAmount = calculateLiquidityValueUSD(delta);

        if (swapAmount >= pool.minSwapAmount) {
            IERC20 usdcToken = IERC20(USDCToken);

            require(
                usdcToken.transferFrom(
                    pool.vault,
                    user,
                    pool.rewardTokenAmount
                ),
                "USDC reward transfer failed"
            );
        }

        return (
            BaseHook.afterSwap.selector,
            int128(uint128(uint256(pool.rewardTokenAmount)))
        );
    }

    function calculateLiquidityValueUSD(
        BalanceDelta delta
    ) internal pure returns (uint256) {
        return
            uint256(
                uint128(int128(delta.amount0())) +
                    uint128(int128(delta.amount1()))
            );
    }
}
