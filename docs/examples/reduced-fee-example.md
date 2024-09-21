# docs/examples/reduced-fee-example.md

# Reduced Fee Swap Example

This example shows how to implement a reduced fee swap in your application using our Uniswap hooks.

```jsx
import React, { useState } from 'react';
import { useReducedFeeSwap } from '@your-org/uniswap-hooks';

const ReducedFeeSwapExample = () => {
  const [amount, setAmount] = useState('');
  const { swap, loading, error, feeReduction } = useReducedFeeSwap({
    discountToken: '0x9876543210987654321098765432109876543210',
    discountThreshold: '100000000000000000000' // 100 tokens with 18 decimals
  });

  const handleSwap = async () => {
    try {
      await swap({
        tokenIn: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC
        tokenOut: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH
        amount: amount
      });
      console.log('Reduced fee swap successful!');
    } catch (error) {
      console.error('Swap failed:', error);
    }
  };

  if (loading) return Calculating fee reduction...;
  if (error) return Error: {error.message};

  return (

      Reduced Fee Swap
      Current fee reduction: {feeReduction}%
      <input
        type="text"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount of USDC to swap"
      />
      Swap USDC for WETH with Reduced Fee

  );
};

export default ReducedFeeSwapExample;
```
