// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("PEPE", "PEPE") {
        _mint(msg.sender, 2500 * (10 ** uint256(decimals())));
    }
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
