// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract CoolVault is ERC4626 {
    uint256 public MAX_DEPOSIT;
    uint256 public MAX_MINT;

    constructor(
        IERC20 asset,
        string memory name,
        string memory symbol,
        uint256 initialMaxDeposit,
        uint256 initialMaxMint
    ) ERC4626(asset) ERC20(name, symbol) {
        MAX_DEPOSIT = initialMaxDeposit;
        MAX_MINT = initialMaxMint;
    }

    function maxDeposit(address) public view override returns (uint256) {
        return MAX_DEPOSIT;
    }

    function maxMint(address) public view override returns (uint256) {
        return MAX_MINT;
    }

    function alterMaxDeposit(uint256 newMax) external {
        MAX_DEPOSIT = newMax;
    }

    function alterMaxMint(uint256 newMax) external {
        MAX_MINT = newMax;
    }
}
