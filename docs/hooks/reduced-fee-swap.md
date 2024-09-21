# docs/hooks/reduced-fee-swap.md

# Reduced Fee Swap Hook

The Reduced Fee Swap hook allows users holding a specific token to benefit from reduced fees when performing swap operations. This incentivizes token holding and can be used as a reward mechanism for your platform's users.

## Usage

To use the Reduced Fee Swap hook in your project, import it from our package:

```javascript
import { useReducedFeeSwap } from "@your-org/uniswap-hooks";
```

Then, you can use it in your component:

```javascript
function ReducedFeeSwapComponent() {
  const { swap, loading, error, feeReduction } = useReducedFeeSwap({
    discountToken: '0x5678...', // Address of the token that grants a fee discount
    discountThreshold: '100000000000000000000' // Minimum balance for discount (e.g., 100 tokens with 18 decimals)
  });

  if (loading) return Loading...;
  if (error) return Error: {error.message};

  return (

      Fee Reduction: {feeReduction}%
      <button onClick={() => swap(/* swap parameters */)}>Perform Reduced Fee Swap

  );
}
```

## Configuration

The `useReducedFeeSwap` hook accepts the following configuration options:

- `discountToken` (string): The address of the token that grants a fee discount.
- `discountThreshold` (string): The minimum balance of the discount token required to receive the fee reduction, expressed in wei.

## Return Values

The hook returns an object with the following properties:

- `swap` (function): A function to perform the swap operation with reduced fees.
- `loading` (boolean): Indicates whether the hook is currently calculating the fee reduction.
- `error` (Error | null): Any error that occurred during the fee reduction calculation.
- `feeReduction` (number): The percentage of fee reduction the user is eligible for.
