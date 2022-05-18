// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";


import "../../interfaces/ITokenFactory.sol";
import "../../interfaces/ISyntheticToken.sol";
import "../../abstract/AccessControlledAndUpgradeable.sol";

contract LongShort is Ownable,PausableUpgradeable, ERC20Upgradeable {


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
address public priceConverterAddress; //MATIC TO DAI
address public winner;
bool public isClaimed;

mapping(bytes32 => address) requestIdToAddressRegistry;
mapping(address => uint256) public playerBetRecordRegistry;

constructor(
  address _RedstoneManagerAddress,
  address _priceConverteraddress,
  address _creator,
  address _daiAddress,
  uint256 _fee
) OracleBuildOut(_RedstoneManagerAddress) {
fee = _fee;
creator = _creator;
better = address(0);
status = ContractStatus.OPEN;
expirationTime = block.timestamp + 1 days;
depositTokenAddress = address(0);
priceConverteraddress = _priceConverteraddress;
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
  claimed,
  depositTokenAddress,
  playerBetRecordRegistry[creator],
   playerBetRecordRegistry[better]
)
}

function ()


//Call when deploying the contract the first time (for the dev)
function newAsset(uint256 projectedValue) public onlyOwner {
projectedValue = (projectedValue).toEther

//Mint Long Tokens
LongToken._mint(address(this), (projectedValue / 2 ) )
//Mint Short Tokens
ShortToken._mint(address(this),(projectedValue / 2) )

// Long + Short = 100%
}


//User Sale


function openPosition (uint256 amount, bool Long, contractDuration ) external {

uint256 contractDuration1 = 1 days;
uint256 contractDuration2 = 3 days;

//block.timestamp for when position is minted

  require(amount < dai.balanceOf(msg.sender))

  dai.transferFrom(msg.sender, address(this), amount)

  if (Long) {

    LongToken.transferFrom(address(this), msg.sender, amount)
  }
  else {
    ShortToken.transferFrom(address(this), msg.sender, amount)
  }

}

function expire () {
  //use from vault
  if (contractDuration1 - block.timestamp  > 0) {}

  // 

}



function redeem () {

  //redeem Long or Short tokens for value of dai it is worth at contract expiration

  function fee(
        uint256 shares,
        uint256 timestamp,
        StakingPlan plan
    ) private view returns (uint256) {
        uint256 feepct = 0;
        uint256 requiredDuration = 0;

        if (plan == StakingPlan.Short) {
            return 0;
        } else if (plan == StakingPlan.Medium) {
            feepct = 5;
            requiredDuration = 30 days;
        } else if (plan == StakingPlan.Long) {
            feepct = 10;
            requiredDuration = 90 days;
        } else if (plan == StakingPlan.Xl) {
            feepct = 20;
            requiredDuration = 180 days;
        }

        if (block.timestamp - timestamp >= requiredDuration) {
            return 0;
        }
        return (shares * feepct) / 100;
    }

}








}