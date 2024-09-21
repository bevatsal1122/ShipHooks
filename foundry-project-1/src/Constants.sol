// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import './IUniversalRouter.sol';
import {console} from 'forge-std/console.sol';

contract Constants {
    // On "Ethereum Sepolia"
    address public constant UNIVERSAL_ROUTER = 0x95273d871c8156636e114b63797d78D7E1720d81;

    address public constant VAT = 0xB21B95E4343242Ed55be7E9ce34C9F2Bc97B4b09;

    function getMsgSender(address) public pure returns (address) {
        // return IUniversalRouter(sender).msgSender();
        // return IUniversalRouter(UNIVERSAL_ROUTER).msgSender();
        return VAT;
    }
}
