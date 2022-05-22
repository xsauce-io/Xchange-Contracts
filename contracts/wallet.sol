// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract wallet {
    address private owner;

    constructor(address owner_) {
        owner = owner_;
    }

    function approve(
        address asset,
        address contract_,
        bool enable
    ) external {
        _onlyOwner();
        if (enable) {
            IERC20(asset).approve(contract_, type(uint256).max - 1);
        } else {
            IERC20(asset).approve(contract_, 0);
        }
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Not the owner");
    }
}