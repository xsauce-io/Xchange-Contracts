// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeTransferFrom.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";


import "../../interfaces/ITokenFactory.sol";

contract predictionMarket is Ownable,PausableUpgradeable, ERC20, IERC20 {




//Sets the upper limit for the value of the asset that the Long/Short pair will be created for.
enum ContractStatus {
  OPEN,
  CLOSED
}

event Calculate();
event Deposit(address tokenAddress, uint256 tokenAmount);
event Claim(address winner, address tokenAddress, uint256 tokenAmount);


address public better;
ContractStatus public status;
address public creator;
uint256 public fee;
uint256 public expirationTime;
address public depositTokenAddress; //DAI
address public winner;
bool public isClaimed;

mapping(bytes32 => address) requestIdToAddressRegistry;
mapping(address => uint256) public playerBetRecordRegistry;

constructor(
  address _RedstoneManagerAddress,
  address _priceConverteraddress,
  address _creator,
  address _depositTokenAddress,
  uint256 _fee
) OracleBuildOut(_RedstoneManagerAddress) {
fee = _fee;
creator = _creator;
better = msg.sender;
status = ContractStatus.OPEN;
expirationTime = block.timestamp + 1 days;
depositTokenAddress = address(0);
}

function getAssetInfo() public view returns (
  address,
  address,
  ContractStatus,
  uint256,
  address,
  address,
  bool,
  uint256,
  uint256
)
{
return (
  creator,
  better,
  status,
  expirationTime,
  winner,
  depositTokenAddress,
  claimed,
  playerBetRecordRegistry[creator],
  playerBetRecordRegistry[better]
);
}

function predict() public onlyCreator(false) onlyExpiredMarket(false) {
  better = msg.sender;

  emit predict(msg.sender);

}

function cancel() public onlyCreator(true) {
status = ContractStatus.CLOSED; 
}

function deposit( address _tokenAddress, address _baseAddress, address _quoteAddress) public onlyCreatorAndChallenger onlyExpiredGame(false) {

IERC20 token = IERC20(_tokenAddress);
token.safeTransferFrom(msg.sender, address(this), 0);


  if (depositTokenAddress == address(0)) {
    depositTokenAddress = _tokenAddress;
  }

  emit Deposit(_tokenAddress, 0);

}

function claim() public onlyCreatorAndBetter onlyExpiredAsset(true) onlyWinner onlyNotClaimed {

IERC20 token = IERC20(_tokenAddress);
token.safeTransferFrom(msg.sender, token.balanceOf(address(this)/winner)));


emit Claimed(winner, depositTokenAddress, 0);

isClaimed = true;
}


function expire () {
  //use from vault
  if (contractDuration1 - block.timestamp  > 0) {}

  // 

}








}