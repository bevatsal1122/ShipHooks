import { sepolia } from "viem/chains";

export const primaryChain = sepolia;

export const POOL_MANAGER_ADDRESS =
  "0xE8E23e97Fa135823143d6b9Cba9c699040D51F70";
export const UNIVERSAL_ROUTER_ADDRESS =
  "0x95273d871c8156636e114b63797d78D7E1720d81";

export const AVAILABLE_TOKENS = [
  { symbol: "ETH", name: "Ethereum", balance: 0.002 },
  { symbol: "BTC", name: "Bitcoin", balance: 0.0001 },
  { symbol: "USDT", name: "Tether", balance: 100 },
  { symbol: "USDC", name: "USD Coin", balance: 100 },
  { symbol: "DAI", name: "Dai", balance: 100 },
];

export const AVAILABLE_HOOKS = [
  {
    id: "token-gated",
    name: "Token Required",
    address: "0x31fCBBF2c6A9d2637a339c5aD5beB5C1C66E6122",
  },
  {
    id: "discounted-fee",
    name: "Discounted Fee for Holders",
    requiresAmount1: true,
    requiresAmount2: true,
    amountLabel: "Regular Fee",
    amountLabel2: "Reduced Fee",
    address: "0xB927776b3706858763F6297c5D40af642B3f680E",
  },
  {
    id: "nft-gated",
    name: "NFT Required",
    requiresAmount1: false,

    address: "0xd8406a414e1CFe79d58306ed83Fb4d8fE2c8e399",
  },
  {
    id: "nft-discounted-fee",
    name: "NFT holders get discount on Fee",
    requiresAmount1: true,
    requiresAmount2: true,
    amountLabel: "Regular Fee",
    amountLabel2: "Reduced Fee",

    address: "0x01E6979f0979fB38B8D4731827A1689205DE4C9A",
  },
  {
    id: "token-rewards-swap",
    name: "Token Rewards on Swap",
    requiresAmount1: true,
    requiresAmount2: true,
    requiresAmount3: true,
    amountLabel: "Token distributor Address", // should have given enough allowance to the hook smart contract.
    amountLabel2: "Minimum Swap Amount",
    amountLabel3: "Reward Token Amount",

    address: "0x7d45eEB47efb915cc126BA3A3F16B531bE9D28C3",
  },
  {
    id: "nft-on-add-liquidity",
    name: "One-time NFT on Adding Liquidity",
    requiresAmount1: true,
    amountLabel: "Minimum LP tokens in Transaction",

    address: "0x6b029a36E89440e44313b368D5b39FEEA305a48c",
  },
] as const;
