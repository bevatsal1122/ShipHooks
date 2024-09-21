"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ArrowDownIcon } from "lucide-react";
import RetroGrid from "@/components/magicui/retro-grid";

const AVAILABLE_TOKENS = [
  { symbol: "ETH", name: "Ethereum", balance: 0.002 },
  { symbol: "BTC", name: "Bitcoin", balance: 0.0001 },
  { symbol: "USDT", name: "Tether", balance: 100 },
  { symbol: "USDC", name: "USD Coin", balance: 100 },
  { symbol: "DAI", name: "Dai", balance: 100 },
];

export default function Component() {
  const [sellToken, setSellToken] = useState(AVAILABLE_TOKENS[0]);
  const [buyToken, setBuyToken] = useState(AVAILABLE_TOKENS[1]);
  const [sellAmount, setSellAmount] = useState("");
  const [buyAmount, setBuyAmount] = useState("");

  return (
    <div className="relative min-h-screen flex items-center justify-center text-black overflow-hidden">
      <RetroGrid className="absolute inset-0 z-0" />
      <div className="relative z-10 w-full max-w-2xl p-8 space-y-8">
        <h1 className="text-6xl font-extrabold text-center text-black mb-12 tracking-tight">
          Swap anytime,{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-600">anywhere.</span>
        </h1>
        <div className="bg-black  backdrop-blur-xl rounded-2xl p-8 space-y-6 border border-gray-800 shadow-2xl">
          <div className="space-y-4">
            <label className="text-lg font-medium text-gray-300">Sell</label>
            <Input
              type="number"
              placeholder="0"
              value={sellAmount}
              onChange={(e) => setSellAmount(e.target.value)}
              className="bg-gray-800 border-gray-700 text-white text-3xl h-16 rounded-xl"
            />
            <div className="flex justify-between items-center">
              <Select
                onValueChange={(value) =>
                  setSellToken(AVAILABLE_TOKENS.find((token) => token.symbol === value) || AVAILABLE_TOKENS[0])
                }
              >
                <SelectTrigger className="w-[180px] bg-gray-800 border-gray-700 text-white h-12 rounded-xl">
                  <SelectValue placeholder="Select token" />
                </SelectTrigger>
                <SelectContent className="bg-gray-900 border-gray-700">
                  {AVAILABLE_TOKENS.map((token) => (
                    <SelectItem key={token.symbol} value={token.symbol} className="text-white">
                      {token.symbol}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <span className="text-base text-gray-400">
                Balance: {sellToken ? sellToken.balance : "0"} {sellToken ? sellToken.symbol : ""}
              </span>
            </div>
          </div>
          <div className="flex justify-center">
            <Button variant="ghost" size="icon" className="rounded-full bg-gray-800 hover:bg-gray-700 w-12 h-12">
              <ArrowDownIcon className="h-6 w-6 text-gray-400" />
            </Button>
          </div>
          <div className="space-y-4">
            <label className="text-lg font-medium text-gray-300">Buy</label>
            <Input
              type="number"
              placeholder="0"
              value={buyAmount}
              onChange={(e) => setBuyAmount(e.target.value)}
              className="bg-gray-900 border-gray-700 text-white text-3xl h-16 rounded-xl"
            />
            <Select
              onValueChange={(value) =>
                setBuyToken(AVAILABLE_TOKENS.find((token) => token.symbol === value) || AVAILABLE_TOKENS[0])
              }
            >
              <SelectTrigger className="w-full bg-gray-800 border-gray-700 text-white h-12 rounded-xl">
                <SelectValue placeholder="Select token" />
              </SelectTrigger>
              <SelectContent className="bg-gray-800 border-gray-700">
                {AVAILABLE_TOKENS.map((token) => (
                  <SelectItem key={token.symbol} value={token.symbol} className="text-white">
                    {token.symbol}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
        <Button
          className="w-full bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white text-xl font-bold py-6 rounded-xl transition-all duration-300 transform hover:scale-105"
          size="lg"
        >
          Get started
        </Button>
        <p className="text-center text-base text-gray-400 mt-6">
          The largest onchain marketplace. Buy and sell crypto on Ethereum and 11+ other chains.
        </p>
      </div>
    </div>
  );
}
