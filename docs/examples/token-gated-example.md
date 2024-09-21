# docs/examples/token-gated-example.md

# Token-Gated Swap Example

This example demonstrates how to implement a token-gated swap in your application using our Uniswap hooks.

```jsx
import React from 'react';
import { useTokenGatedSwap } from '@your-org/uniswap-hooks';

const TokenGatedSwapExample = () => {
  const { swap, loading, error, isEligible } = useTokenGatedSwap({
    requiredToken: '0x1234567890123456789012345678901234567890',
    minimumBalance: '1000000000000000000' // 1 token with 18 decimals
  });

  const handleSwap = async () => {
    try {
      await swap({
        tokenIn: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
        tokenOut: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
        amount: '1000000' // 1 USDC
      });
      console.log('Swap successful!');
    } catch (error) {
      console.error('Swap failed:', error);
    }
  };

  if (loading) return Checking eligibility...;
  if (error) return Error: {error.message};

  return (

      Token-Gated Swap
      {isEligible ? (

          You are eligible to perform this swap!
          Swap 1 USDC for WETH

      ) : (
        You do not hold the required token to perform this swap.
      )}

  );
};

export default TokenGatedSwapExample;
```
