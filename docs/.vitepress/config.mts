import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "ShipHooks 🚀",
  description: "Openzeppelin hooks for uniswap",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Home", link: "/" },
      { text: "Examples", link: "/markdown-examples" },
      { text: "Hooks", link: "/hooks/token-gated-swap" },
    ],

    sidebar: [
      {
        text: "Guide",
        items: [
          { text: "Getting Started", link: "/getting-started" },
          // { text: 'Runtime API Examples', link: '/api-examples' }
        ],
      },
      {
        text: "Hooks",
        items: [
          { text: "Token-Gated Swap", link: "/hooks/token-gated-swap" },
          { text: "Discounted Fee Swap", link: "/hooks/reduced-fee-swap" },
          { text: "NFT-Gated Swap", link: "/hooks/nft-gated-swap" },
          { text: "NFT-based Reduced Fees", link: "/hooks/nft-reduced-fees" },
        ],
      },
      {
        text: "Examples",
        items: [
          {
            text: "Token-Gated Example",
            link: "/examples/token-gated-example",
          },
          {
            text: "Reduced Fee Example",
            link: "/examples/reduced-fee-example",
          },
        ],
      },
      {
        text: "Utils",
        items: [{ text: "Constants", link: "/utils/constants" }],
      },
    ],
    socialLinks: [
      { icon: "github", link: "https://github.com/bevatsal1122/ShipHooks" },
    ],
  },
});
