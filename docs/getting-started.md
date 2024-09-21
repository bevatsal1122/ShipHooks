# docs/getting-started.md

# Getting Started

Welcome to the Uniswap Hooks Integration documentation. This guide will help you get started with integrating Uniswap hooks into your platform.

## Prerequisites

Before you begin, make sure you have the following installed:

- Node.js (version 14 or higher)
- npm or yarn

## Installation

To install the Uniswap Hooks package, run the following command:

```bash
npm install @your-org/uniswap-hooks
```

or if you're using yarn:

```bash
yarn add @your-org/uniswap-hooks
```

## Basic Usage

Here's a simple example of how to use a Uniswap hook in your project:

```javascript
import { useSwap } from "@your-org/uniswap-hooks";

function SwapComponent() {
  const { swap, loading, error } = useSwap();

  // Your component logic here
}
```
