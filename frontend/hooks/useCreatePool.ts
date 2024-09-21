import { useCallback } from "react";
import { Hook } from "../types";
import { useWriteContract } from "wagmi";
import PoolManagerABI from "@/constants/abis/PoolManager.json" assert { type: "json" };
import { POOL_MANAGER_ADDRESS } from "@/constants";
import { encodeSqrtRatioX96 } from "@uniswap/v3-sdk";
import { encodeAbiParameters, encodePacked } from "viem";

const DEFAULT_CREATE_POOL_CONFIG = {
  currency0: "0x60b8f5fF057990a0F5B5c92a9eE82676A400de1B", // USDT (Mock)
  currency1: "0x6e2DBB0B9de8508e5DC6dc8F234be7E222f22422", // USDC (Mock)
  fee: 3000,
  tickSpacing: 200,
};

export const useCreatePool = () => {
  const { writeContractAsync } = useWriteContract();

  const createPool = useCallback(
    (
      hook: Hook,
      data: {
        tokenAddress?: string;
        amount1?: string;
        amount2?: string;
        amount3?: string;
      } = {}
    ) => {
      try {
        const { tokenAddress, amount1, amount2, amount3 } = data;

        const key = {
          ...DEFAULT_CREATE_POOL_CONFIG,
          hooks: hook.address,
        };

        const sqrtPriceX96 = encodeSqrtRatioX96("1000", "500");

        const initialHookData: any = {};

        switch (hook.id) {
          case "nft-discounted-fee":
          case "discounted-fee": {
            initialHookData.regularFees = amount1;
            initialHookData.reducedFees = amount2;
            initialHookData.tokenAddress = tokenAddress;
            break;
          }
          case "token-rewards-swap": {
            initialHookData.tokenAddress = tokenAddress;
            initialHookData.vault = amount1;
            initialHookData.minSwapAmount = amount2;
            initialHookData.rewardTokenAmount = amount3;
          }
          case "nft-on-add-liquidity": {
            initialHookData.tokenAddress = tokenAddress;
            initialHookData.minLPTokens = amount1;
          }

          case "token-gated":
          case "nft-gated": {
            initialHookData.tokenAddress = tokenAddress;
          }

          default: {
          }
        }

        const hookData = encodePacked(["bytes"], [initialHookData]);
        // const hookData = encodeAbiParameters([''])

        writeContractAsync({
          abi: PoolManagerABI,
          address: POOL_MANAGER_ADDRESS,
          functionName: "initialize",
          args: [key, sqrtPriceX96, hookData],
        });
      } catch (e) {
        console.error(e);
      }
    },
    []
  );

  return {
    createPool,
  };
};
