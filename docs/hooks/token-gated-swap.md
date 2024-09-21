# docs/hooks/token-gated-swap.md

# Token-Gated Swap Hook

The Token-Gated Swap hook provides a mechanism to restrict swap operations based on token ownership. This hook ensures that only users holding a specific token or a minimum amount of tokens can perform swap operations.

## Usage

To use the Token-Gated Swap hook in your project, import it from our package:

```javascript
import { useTokenGatedSwap } from "@your-org/uniswap-hooks";
```

Then, you can use it in your component:

```javascript
function TokenGatedSwapComponent() {
  const { swap, loading, error, isEligible } = useTokenGatedSwap({
    requiredToken: '0x1234...', // Address of the required token
    minimumBalance: '1000000000000000000' // Minimum balance in wei (e.g., 1 token with 18 decimals)
  });

  if (loading) return Loading...;
  if (error) return Error: {error.message};

  return (

      {isEligible ? (
        <button onClick={() => swap(/* swap parameters */)}>Perform Swap
      ) : (
        You do not hold the required token to perform this swap.
      )}

  );
}
```

## Configuration

The `useTokenGatedSwap` hook accepts the following configuration options:

- `requiredToken` (string): The address of the token required to perform the swap.
- `minimumBalance` (string): The minimum balance of the required token, expressed in wei.

## Return Values

The hook returns an object with the following properties:

- `swap` (function): A function to perform the swap operation.
- `loading` (boolean): Indicates whether the hook is currently checking eligibility.
- `error` (Error | null): Any error that occurred during the eligibility check.
- `isEligible` (boolean): Indicates whether the user is eligible to perform the swap.
