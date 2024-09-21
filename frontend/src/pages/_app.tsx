import "@/styles/globals.css";
import type { AppProps } from "next/app";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import { WagmiProvider } from "wagmi";
import { mainnet, arbitrum, sepolia } from "@reown/appkit/networks";
import { Config, cookieStorage, createStorage, http } from "@wagmi/core";
import { createAppKit } from "@reown/appkit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import Navbar from "@/components/Navbar";

export const projectId = "a7a48a6002426e8eaafe354ae0bb212b";
// Set up queryClient
const queryClient = new QueryClient();

export const metadata = {
  name: "shiphooks",
  description: "openzeppelin for uniswap hooks",
  url: "https://example.com", // origin must match your domain and subdomain
  icons: ["https://example.com/favicon.png"],
};

export const networks = [mainnet, arbitrum, sepolia];

// Create wagmiAdapter
export const wagmiAdapter = new WagmiAdapter({
  storage: createStorage({
    storage: cookieStorage,
  }),
  chains: [sepolia],
  ssr: true,
  projectId,
  networks,
});

const modal = createAppKit({
  adapters: [wagmiAdapter],
  projectId,
  networks: [mainnet, arbitrum, sepolia],
  defaultNetwork: mainnet,
  metadata: metadata,
  features: {
    analytics: true, // Optional - defaults to your Cloud configuration
  },
});

export default function App({ Component, pageProps }: AppProps) {
  return (
    <WagmiProvider config={wagmiAdapter.wagmiConfig as Config}>
      <QueryClientProvider client={queryClient}>
        <Navbar />
        <Component {...pageProps} />
      </QueryClientProvider>
    </WagmiProvider>
  );
}
