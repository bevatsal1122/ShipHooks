"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { ArrowDownIcon } from "lucide-react";
import RetroGrid from "@/components/magicui/retro-grid";
import { useSwapState } from "../../../hooks/useSwapState";
import { AVAILABLE_TOKENS } from "../../../constants";

export default function SwapPage() {
  const {
    token0,
    token1,
    token0Amount,
    token1Amount,
    setToken0,
    setToken1,
    setToken0Amount,
    setToken1Amount,
  } = useSwapState();

  return (
    <div className="relative min-h-screen flex items-center justify-center text-black overflow-hidden">
      <RetroGrid className="absolute inset-0 z-0" />
      <div className="relative z-10 w-full max-w-2xl p-8 space-y-8">
        <h1 className="text-6xl font-extrabold text-center text-black mb-12 tracking-tight">
          Swap anytime,{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-600">
            anywhere.
          </span>
        </h1>
        <div className="bg-black  backdrop-blur-xl rounded-2xl p-8 space-y-6 border border-gray-800 shadow-2xl">
          <div className="space-y-4">
            <label className="text-lg font-medium text-gray-300">Sell</label>
            <Input
              type="number"
              placeholder="0"
              value={token0Amount}
              onChange={(e) => setToken0Amount(e.target.value)}
              className="bg-gray-800 border-gray-700 text-white text-3xl h-16 rounded-xl"
            />
            <div className="flex justify-between items-center">
              <Select
                onValueChange={(value) =>
                  setToken0(
                    AVAILABLE_TOKENS.find((token) => token.symbol === value) ||
                      AVAILABLE_TOKENS[0]
                  )
                }
              >
                <SelectTrigger className="w-[180px] bg-gray-800 border-gray-700 text-white h-12 rounded-xl">
                  <SelectValue placeholder="Select token" />
                </SelectTrigger>
                <SelectContent className="bg-gray-900 border-gray-700">
                  {AVAILABLE_TOKENS.map((token) => (
                    <SelectItem
                      key={token.symbol}
                      value={token.symbol}
                      className="text-white"
                    >
                      {token.symbol}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <span className="text-base text-gray-400">
                Balance: {token0 ? token0.balance : "0"}{" "}
                {token0 ? token0.symbol : ""}
              </span>
            </div>
          </div>
          <div className="flex justify-center">
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full bg-gray-800 hover:bg-gray-700 w-12 h-12"
            >
              <ArrowDownIcon className="h-6 w-6 text-gray-400" />
            </Button>
          </div>
          <div className="space-y-4">
            <label className="text-lg font-medium text-gray-300">Buy</label>
            <Input
              type="number"
              placeholder="0"
              value={token1Amount}
              onChange={(e) => setToken1Amount(e.target.value)}
              className="bg-gray-900 border-gray-700 text-white text-3xl h-16 rounded-xl"
            />
            <Select
              onValueChange={(value) =>
                setToken1(
                  AVAILABLE_TOKENS.find((token) => token.symbol === value) ||
                    AVAILABLE_TOKENS[0]
                )
              }
            >
              <SelectTrigger className="w-full bg-gray-800 border-gray-700 text-white h-12 rounded-xl">
                <SelectValue placeholder="Select token" />
              </SelectTrigger>
              <SelectContent className="bg-gray-800 border-gray-700">
                {AVAILABLE_TOKENS.map((token) => (
                  <SelectItem
                    key={token.symbol}
                    value={token.symbol}
                    className="text-white"
                  >
                    {token.symbol}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
        {/* <Button
          className="w-full bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white text-xl font-bold py-6 rounded-xl transition-all duration-300 transform hover:scale-105"
          size="lg"
        >
          Get started
        </Button>
        <p className="text-center text-base text-gray-400 mt-6"></p> */}
      </div>
    </div>
  );
}
