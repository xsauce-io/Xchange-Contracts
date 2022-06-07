// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./wallet.sol";   
   
contract Margin is Ownable {
  

 struct margin {
        uint256 timestamp;
        uint256 amount;
        address staker;
        address escrow;

    }
    mapping(address => margin) public marginDetails;
    IERC20 public _DAI;

    constructor (IERC20 DAI) {
      _DAI = DAI;
    }

     event AddMargin(address indexed sender, uint256 margin);



   function addMargin(uint256 amount) public {
        require(amount <= _DAI.balanceOf(msg.sender), "DAI Balance too low");
        //could also use PAX

         if (marginDetails[msg.sender].amount == 0) {
            // write the stake to storage on-chain
           wallet marginAcct = new wallet(address(this));
        
            marginAcct.approve(address(_DAI), address(this),true);

            marginDetails[msg.sender] = margin({
                staker: msg.sender,
                timestamp: block.timestamp,
                amount: amount,
                escrow: address(marginAcct)
            });
        _DAI.transferFrom(msg.sender, address(marginDetails[msg.sender].escrow), amount);
       
        } else {
            margin storage margindata = marginDetails[msg.sender];
            margindata.amount += amount;
            margindata.timestamp = block.timestamp; 
        _DAI.transferFrom(msg.sender, address(margindata.escrow), amount);
        }
        emit AddMargin(msg.sender, amount);
    }


}