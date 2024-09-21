"use client";

import { useEffect, useState } from "react";
import { ArrowRight, Anchor, Zap, Shield, Code, Rocket } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { motion } from "framer-motion";
import Particles from "@/components/magicui/particles";
import ConnectButton from "@/lib/ConnectWallet";
import Navbar from "@/components/Navbar";

export default function Component() {
  const features = [
    { title: "Easy Integration", description: "Seamlessly integrate hooks into your Uniswap projects", icon: Anchor },
    {
      title: "Performance Boost",
      description: "Optimize your DeFi applications for lightning-fast execution",
      icon: Zap,
    },
    { title: "Enhanced Security", description: "Built-in security measures to protect your hooks", icon: Shield },
    { title: "Customizable", description: "Tailor hooks to your specific needs with ease", icon: Code },
    { title: "Community-Driven", description: "Benefit from a growing ecosystem of developers", icon: Rocket },
    {
      title: "Constant Updates",
      description: "Stay ahead with regular feature updates and improvements",
      icon: ArrowRight,
    },
  ];

  const [color, setColor] = useState("#ffffff");

  return (
    <div className="bg-black text-white">
      <section className="min-h-screen relative  flex items-center justify-center">
        <div className="absolute inset-0 z-0">
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-gradient-to-r from-gray-700 to-gray-900 rounded-full mix-blend-screen filter blur-3xl opacity-20 animate-pulse"></div>
          <div className="absolute top-3/4 right-1/4 w-64 h-64 bg-gradient-to-r from-gray-800 to-gray-950 rounded-full mix-blend-screen filter blur-3xl opacity-20 animate-pulse"></div>
        </div>
        <div className="container mx-auto px-4 text-center relative z-10">
          <motion.h1
            className="text-6xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-gray-100 to-gray-400"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            ShipHooks
          </motion.h1>
          <motion.p
            className="text-2xl mb-8 text-gray-300"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            OpenZeppelin for Uniswap Hooks
          </motion.p>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            style={{ display: "flex", gap: "1rem", width: "100%", justifyContent: "center", alignItems: "center" }}
          >
            <Button className="bg-gradient-to-r from-gray-700 to-gray-900 hover:from-gray-600 hover:to-gray-800 text-white font-bold py-3 px-6 rounded-full text-lg">
              Get Started <ArrowRight className="ml-2" />
            </Button>
            <ConnectButton />
          </motion.div>
        </div>
        <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2">
          <motion.div animate={{ y: [0, 10, 0] }} transition={{ repeat: Infinity, duration: 2 }}>
            <ArrowRight className="w-8 h-8" />
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section className="min-h-screen py-20 relative overflow-hidden">
        <div className="container mx-auto px-4 relative z-10">
          <motion.h2
            className="text-4xl font-bold mb-16 text-center text-transparent bg-clip-text bg-gradient-to-r from-gray-100 to-gray-400"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            Features
          </motion.h2>
          <div className="grid grid-cols-1 mx-10 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, delay: index * 0.1 }}
              >
                <Card className="bg-white text-black cursor-pointer h-56 border-gray-800 hover:bg-gray-800 hover:text-white transition-all duration-300 transform hover:scale-105">
                  <CardHeader>
                    <feature.icon className="w-12 h-12 mb-4 " />
                    <CardTitle className="text-xl font-semibold">{feature.title}</CardTitle>
                    <CardDescription className="">{feature.description}</CardDescription>
                  </CardHeader>
                </Card>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
      <Particles className="absolute top-20 inset-0" quantity={500} ease={220} color={color} refresh />
    </div>
  );
}
