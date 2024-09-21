// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import './IUniversalRouter.sol';

contract Constants {
    address public constant UNIVERSAL_ROUTER = 0x927038542746c06F1b2F7F550a3c90AEBdDa4E85; // On "Base Sepolia"

    function getMsgSender(address _router) external view returns (address) {
        return IUniversalRouter(_router).msgSender();
    }
}
