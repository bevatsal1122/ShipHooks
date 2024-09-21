// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "mUSDC") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals()))); // Mint 1 million mock USDC to deployer
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
