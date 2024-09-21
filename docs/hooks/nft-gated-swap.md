# NFT-Gated Swap

The NFT-Gated Swap hook provides a mechanism to restrict swap operations based on NFT ownership. This hook ensures that only users holding a specific NFT can perform swap operations.

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
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "./Constants.sol";

struct PoolConfig {
    address nftAddress;
    address owner;
}

contract NFTGated is BaseHook, Constants {
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
        address user = sender;
        address _nftAddress = abi.decode(hookData, (address));
        PoolConfig memory pool = PoolConfig({
            nftAddress: _nftAddress,
            owner: user
        });
        PoolId poolId = key.toId();
        pools[poolId] = pool;
        return BaseHook.afterInitialize.selector;
    }

    function setPoolConfig(PoolKey calldata key, address _nftAddress) external {
        PoolId poolId = key.toId();
        pools[poolId].nftAddress = _nftAddress;
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

        IERC721 nft = IERC721(pool.nftAddress);

        uint256 senderNFTBalance = nft.balanceOf(user);

        require(senderNFTBalance > 0, "Swap denied: insufficient NFT balance");

        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            0
        );
    }
}

```
