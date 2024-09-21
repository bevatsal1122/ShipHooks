# NFT on Add Liquidity (One-time)

This Membership NFT hook helps you reward your liquidity providers by awarding them an NFT the first time
they add liquidity to their pool.

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
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {console} from "forge-std/console.sol";
import "./Constants.sol";
import "./IUniversalRouter.sol";

struct PoolConfig {
    address tokenAddress;
    address owner;
    uint256 minTokenAmount;
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
                beforeSwap: false,
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
        (address _tokenAddress, uint256 _minTokenAmount) = abi.decode(
            hookData,
            (address, uint256)
        );
        PoolId poolId = key.toId();
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].owner = user;
        pools[poolId].minTokenAmount = _minTokenAmount;
        return BaseHook.afterInitialize.selector;
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        BalanceDelta delta,
        bytes calldata
    ) external returns (bytes4) {
        address user = getMsgSender(sender);
        PoolId poolId = key.toId();
        PoolConfig storage pool = pools[poolId];

        if (!pool.hasMintedNFT[user]) {
            uint256 liquidityValueUSD = calculateLiquidityValueUSD(delta);
            if (liquidityValueUSD >= pool.minTokenAmount) {
                pool.hasMintedNFT[user] = true;
                _mintNFT(user);
            }
        }

        return BaseHook.afterAddLiquidity.selector;
    }

    function setPoolConfig(
        PoolKey calldata key,
        address _tokenAddress,
        uint256 _minTokenAmount
    ) external {
        PoolId poolId = key.toId();
        pools[poolId].tokenAddress = _tokenAddress;
        pools[poolId].minTokenAmount = _minTokenAmount;
    }

    function _mintNFT(address to) internal {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(to, tokenId);
    }

    function calculateLiquidityValueUSD(
        BalanceDelta delta
    ) internal pure returns (uint256) {
        // This is a placeholder implementation. In a real-world scenario, you would need to:
        // 1. Get the current price of both tokens in the pool
        // 2. Calculate the USD value of the liquidity added
        // For simplicity, we'll assume 1 token = 1 USD here
        return
            uint256(
                uint128(int128(delta.amount0())) +
                    uint128(int128(delta.amount1()))
            );
    }
}
```
