// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import './IUniversalRouter.sol';
import {console} from 'forge-std/console.sol';

contract Constants {
    // On "Ethereum Sepolia"
    address public constant UNIVERSAL_ROUTER = 0x95273d871c8156636e114b63797d78D7E1720d81;

    function getMsgSender(address sender) public view returns (address) {
        console.log("UNIERSAL ROUTER");
        console.log(sender);
        // return IUniversalRouter(sender).msgSender();
        return IUniversalRouter(UNIVERSAL_ROUTER).msgSender();
    }
}
