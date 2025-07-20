// SPDX-License-Identifier

pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";


contract OurToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Our Code", "OT") {
        _mint(msg.sender, initialSupply);
    }
}