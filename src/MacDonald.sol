// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity 0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MacDonald is ERC20 {
    constructor() ERC20("FrenchFries", "FF") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
