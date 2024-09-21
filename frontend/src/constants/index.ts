import { sepolia } from "viem/chains";

export const primaryChain = sepolia

export const POOL_MANAGER_ADDRESS = "0xE8E23e97Fa135823143d6b9Cba9c699040D51F70"
export const UNIVERSAL_ROUTER_ADDRESS = "0x95273d871c8156636e114b63797d78D7E1720d81"

export const AVAILABLE_TOKENS = [
  { symbol: "ETH", name: "Ethereum", balance: 0.002 },
  { symbol: "BTC", name: "Bitcoin", balance: 0.0001 },
  { symbol: "USDT", name: "Tether", balance: 100 },
  { symbol: "USDC", name: "USD Coin", balance: 100 },
  { symbol: "DAI", name: "Dai", balance: 100 },
];

export const AVAILABLE_HOOKS = [
  {
    id: "token-gate",
    name: "Token Required",
  },
  {
    id: "discounted-fee",
    name: "Discounted Fee for Holders",
    requiresAmount1: true,
    requiresAmount2: true,
    amountLabel: "Regular Fee",
    amountLabel2: "Reduced Fee",
  },
  { id: "nft-gate", name: "NFT Required", requiresAmount1: false },
  {
    id: "nft-discounted-fee",
    name: "NFT holders get discount on Fee",
    requiresAmount1: true,
    requiresAmount2: true,
    amountLabel: "Regular Fee",
    amountLabel2: "Reduced Fee",
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
  },
  {
    id: "nft-on-add-liquidity",
    name: "One-time NFT on Adding Liquidity",
    requiresAmount1: true,
    amountLabel: "Minimum LP tokens in Transaction",
  },
];
