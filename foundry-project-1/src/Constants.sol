// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import './IUniversalRouter';

contract Constants {
    constant address UNIVERSAL_ROUTER = "0x927038542746c06F1b2F7F550a3c90AEBdDa4E85" // On "Base Sepolia"

    function getMsgSender(address _router) external view returns (address) {
        return IUniversalRouter(_router).msgSender();
    }
}
