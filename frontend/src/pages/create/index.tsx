"use client";

import { useCallback, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import RetroGrid from "@/components/magicui/retro-grid";
import { atom, useAtom } from "jotai";
import { AVAILABLE_HOOKS } from "@/constants";



const tokenAddressAtom = atom("");

const amount1Atom = atom("");
const amount2Atom = atom("");
const amount3Atom = atom("");

export default function CreatePage() {
  const [selectedHook, setSelectedHook] = useState<
    (typeof AVAILABLE_HOOKS)[number] | null
  >(null);

  const [tokenAddress, setTokenAddress] = useAtom(tokenAddressAtom);
  const [amount1, setAmount1] = useAtom(amount1Atom);
  const [amount2, setAmount2] = useAtom(amount2Atom);
  const [amount3, setAmount3] = useAtom(amount3Atom);

  const handleSubmit = useCallback((e: any) => {
    e.preventDefault();
  }, []);

  return (
    <div className="relative min-h-screen flex items-center justify-center text-black overflow-hidden">
      <RetroGrid className="absolute inset-0 z-0" />
      <div className="relative z-10 w-full max-w-2xl p-8 space-y-8">
        <h1 className="text-6xl font-extrabold text-center text-black mb-12 tracking-tight">
          Choose your{" "}
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-600">
            hook
          </span>
        </h1>
        <form
          onSubmit={handleSubmit}
          className="bg-black backdrop-blur-xl rounded-2xl p-8 space-y-6 border border-gray-800 shadow-2xl"
        >
          <div className="space-y-4">
            <label
              htmlFor="hook-select"
              className="text-xl font-bold text-gray-100"
            >
              Select Hook
            </label>
            <Select
              onValueChange={(value) => {
                const hook = AVAILABLE_HOOKS.find((hook) => hook.id === value);
                setSelectedHook(hook || null);
                setTokenAddress("");
                setAmount1("");
                setAmount2("");
              }}
            >
              <SelectTrigger
                id="hook-select"
                className="w-full bg-gray-800 border-gray-700 text-white h-12 rounded-xl"
              >
                <SelectValue placeholder="Choose a hook" />
              </SelectTrigger>
              <SelectContent className="bg-gray-800 border-gray-700">
                {AVAILABLE_HOOKS.map((hook) => (
                  <SelectItem
                    key={hook.id}
                    value={hook.id}
                    className="text-white"
                  >
                    {hook.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {selectedHook && (
            <div className="space-y-4 transition-all duration-300">
              <label
                htmlFor="token-address"
                className="text-lg font-medium text-gray-300"
              >
                Token Address
              </label>
              <Input
                id="token-address"
                type="text"
                placeholder="Enter token address"
                value={tokenAddress}
                onChange={(e) => setTokenAddress(e.target.value)}
                className="bg-gray-800 border-gray-700 text-white text-xl h-12 rounded-xl"
              />
            </div>
          )}

          {selectedHook?.requiresAmount1 && (
            <div className="space-y-4 transition-all duration-300">
              <label
                htmlFor="amount"
                className="text-lg font-medium text-gray-300"
              >
                {selectedHook.amountLabel || "Amount"}
              </label>
              <Input
                id="amount"
                type="number"
                placeholder={"Enter " + selectedHook.amountLabel}
                value={amount1}
                onChange={(e) => setAmount1(e.target.value)}
                className="bg-gray-800 border-gray-700 text-white text-xl h-12 rounded-xl"
              />
            </div>
          )}

          {selectedHook?.requiresAmount2 && (
            <div className="space-y-4 transition-all duration-300">
              <label
                htmlFor="amount"
                className="text-lg font-medium text-gray-300"
              >
                {selectedHook.amountLabel2 || "Amount"}
              </label>
              <Input
                id="amount"
                type="number"
                placeholder={"Enter " + selectedHook.amountLabel2}
                value={amount2}
                onChange={(e) => setAmount2(e.target.value)}
                className="bg-gray-800 border-gray-700 text-white text-xl h-12 rounded-xl"
              />
            </div>
          )}

          {selectedHook?.requiresAmount3 && (
            <div className="space-y-4 transition-all duration-300">
              <label
                htmlFor="amount"
                className="text-lg font-medium text-gray-300"
              >
                {selectedHook.amountLabel3 || "Amount"}
              </label>
              <Input
                id="amount"
                type="number"
                placeholder={"Enter " + selectedHook.amountLabel3}
                value={amount3}
                onChange={(e) => setAmount3(e.target.value)}
                className="bg-gray-800 border-gray-700 text-white text-xl h-12 rounded-xl"
              />
            </div>
          )}

          {selectedHook && (
            <Button
              type="submit"
              className="w-full bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white text-xl font-bold py-6 rounded-xl transition-all duration-300 transform hover:scale-105"
              size="lg"
            >
              Submit
            </Button>
          )}
        </form>
        <p className="text-center text-base text-gray-400 mt-6">
          Select a hook, provide the required information, and submit to
          interact with the blockchain.
        </p>
      </div>
    </div>
  );
}
