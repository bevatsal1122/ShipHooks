import { atom, useAtom } from "jotai";
import { AVAILABLE_TOKENS } from "../src/constants/constants";

const token0Atom = atom(AVAILABLE_TOKENS[0]);
const token1Atom = atom(AVAILABLE_TOKENS[1]);
const token0AmountAtom = atom("");
const token1AmountAtom = atom("");

export const useSwapState = () => {
  const [token0, setToken0] = useAtom(token0Atom);
  const [token1, setToken1] = useAtom(token1Atom);

  const [token0Amount, setToken0Amount] = useAtom(token0AmountAtom);
  const [token1Amount, setToken1Amount] = useAtom(token1AmountAtom);

  return {
    token0,
    token1,
    setToken0,
    setToken1,
    token0Amount,
    token1Amount,
    setToken0Amount,
    setToken1Amount,
  };
};
