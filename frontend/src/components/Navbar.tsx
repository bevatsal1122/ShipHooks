import React from "react";
import { useRouter } from "next/router";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import ConnectButton from "@/lib/ConnectWallet";

const Navbar = () => {
  const router = useRouter();

  const navItems = [
    { name: "Home", path: "/" },
    { name: "Create", path: "/create" },
    { name: "Swap", path: "/swap" },
  ];

  return (
    <nav className="bg-black text-white py-4 px-6 flex z-50 items-center justify-between">
      <div className="flex items-center">
        <span className="text-xl font-bold mr-8">ShipHooks 🚀</span>
        <div className="space-x-4">
          {navItems.map((item) => (
            <Link className="cursor-pointer" key={item.name} href={item.path}>
              <Button className="text-white hover:text-gray-300 cursor-pointer transition-colors">{item.name}</Button>
            </Link>
          ))}
        </div>
      </div>
      <ConnectButton />
    </nav>
  );
};

export default Navbar;
