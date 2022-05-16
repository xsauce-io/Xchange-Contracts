// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "../../interfaces/ITokenFactory.sol";
import "../../interfaces/ISyntheticToken.sol";
import "../../abstract/AccessControlledAndUpgradeable.sol";

contract LongShort is OwnableUpgradeable,PausableUpgradeable, ERC20Upgradeable {


//Sets the upper limit for the value of the asset that the Long/Short pair will be created for.
uint256 projectedValue = 0;

enum contractDuration {
  3 days,// = 0
  30 days, // = 1
  90 days // = 2
}

enum longShort {
  Long,
  Short
}

address dai = ;
IERC20Upgradeable LongToken
IERC20Upgradeable ShortToken 



//Call when deploying the contract the first time (for the dev)
function newAsset(uint256 projectedValue) external {
proper = projectedValue.toEth

//Mint Long Tokens
LongToken._mint(address(this), (proper / 2 ) )
//Mint Short Tokens
ShortToken._mint(address(this),(proper / 2) )
}


//User Sale


function openPosition (uint256 amount, LongShort, contractDuration ) external {

  require(amount !> dai.balanceOf(msg.sender))

  dai.transferFrom(msg.sender, address(this), amount)

  if (longShort == Long) {
    LongToken.transferFrom(address(this), msg.sender, amount)
  }
  else {
    ShortToken.transferFrom(address(this), msg.sender, amount)
  }

}

function expire () {

}



function redeem () {

}








}