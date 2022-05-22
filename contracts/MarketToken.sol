// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./wallet.sol";

contract MarketToken is Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;
    

    enum Answer {
        NONE,
        TRUE,
        FALSE
    }


    enum MarketStatus {
        OPEN,
        PAUSE,
        CLOSED
    }
  
    struct Stake {
        uint256 timestamp;
        uint256 amount;
        address staker;
        Answer bet;
        
    }

    mapping(address => mapping(Answer => Stake)) public stakes;
    mapping(Answer => wallet) public escrow;
    IERC20 public _DAI;
    address private _feeCollector;
    address public _oracle;
    MarketStatus status;
    Answer bet;
    Answer otherBet;
    Counters.Counter private _TrueCounter;
    Counters.Counter private _FalseCounter;

    modifier onlyOracle {
        require(msg.sender == _oracle);
        _;
    }

    constructor (address oracle, address feeCollector, IERC20 DAI) {
        status = MarketStatus.OPEN;
        bet = Answer.NONE;
        _DAI = DAI;
        _feeCollector = feeCollector;
        // also put this in .env file
        _oracle = oracle;
    }
// Events defined here
    event BetPlaced(address indexed sender, Answer _bet, uint256 amount);
    event MarketOpened();
    event MarketPaused();
    event MarketClosed();
    event WinnerPicked(bool winner);
    event DistributeWinnings(address indexed sender, Answer bet, uint256 amount);

    function Approvals() external onlyOwner {
        escrow[Answer.TRUE] = new wallet(address(this));
        escrow[Answer.TRUE].approve(address(_DAI), address(this),true);
        escrow[Answer.FALSE] = new wallet(address(this));
        escrow[Answer.FALSE].approve( address(_DAI),address(this),true);
    }

    function enter(uint256 amount, Answer _bet) external {
        
        require(status == MarketStatus.OPEN);
        // Must specify valid plan
        require(_bet != Answer.NONE, "Please enter a valid plan");
        //require 10 DAI tokens minimum
        require(amount >= 10, "Minimum amount = 10 DAI");
        // check that there is no plan assigned
        // Update balance if already enrolled
        if (stakes[msg.sender][_bet].bet == Answer.NONE) {
            // write the stake to storage on-chain
            stakes[msg.sender][_bet] = Stake({
                staker: msg.sender,
                bet: _bet,
                timestamp: block.timestamp,
                amount: amount
            });
        } else {
            Stake storage stake = stakes[msg.sender][_bet];
            stake.amount += amount;
        }

        uint256 feepct = 5;

        if (stakes[msg.sender][_bet].bet == Answer.TRUE) {
            //Transfer to create a True position
                uint256 position = (amount * feepct) / 100;
                uint256 owed = (amount - position);
                _DAI.transferFrom(msg.sender, _feeCollector, position);
                _DAI.transferFrom(msg.sender, address(escrow[_bet]), owed);
                // _mint(msg.sender, owed);
                _TrueCounter.increment();
            }
         else if (stakes[msg.sender][_bet].bet == Answer.FALSE) {

            //Transfer to create a False position
                uint256 position = (amount * feepct) / 100;
                uint256 owed = (amount - position);
                _DAI.transferFrom(msg.sender, _feeCollector, position);
                _DAI.transferFrom(msg.sender, address(escrow[_bet]), owed);
                // _mint(msg.sender, owed);
                _FalseCounter.increment();
            }
          
        emit BetPlaced(msg.sender, bet, amount);

    }

    function pause() public onlyOwner {
       status = MarketStatus.PAUSE;
        emit MarketPaused();
    }
    
    function resume() public onlyOwner  {
       status = MarketStatus.OPEN;
        emit MarketOpened();
    }

    function close() public onlyOwner {
        status = MarketStatus.CLOSED;
        emit MarketClosed();
    }

    function PickWinner(bool response) public onlyOracle {
         require(status == MarketStatus.CLOSED, "Market still open");

        if (response) { 
            bet = Answer.TRUE;
            otherBet = Answer.FALSE;
        }
        else {
            bet = Answer.FALSE;
            otherBet = Answer.TRUE;
        }

        emit WinnerPicked(response);
    }

    function claim() public {
        require(stakes[msg.sender][bet].amount > 0, "not a winner");
        Stake memory stake = stakes[msg.sender][bet];
        delete stakes[msg.sender][bet];
        uint256 feepct = 5;
        uint256 position = (stake.amount * feepct) / 100;
        uint256 owed = (stake.amount - position);
        //Return Initial
        _DAI.transferFrom(address(escrow[bet]), msg.sender, owed);
        uint256 count = (bet == Answer.TRUE) ? _FalseCounter.current() : _TrueCounter.current();
        uint256 winnings = (_DAI.balanceOf(address(escrow[otherBet])) / count);
        //Send Profits
        _DAI.transferFrom(address(escrow[otherBet]), msg.sender, winnings);
        // delete the storage plan mapped to the wallet upon exit
       
    
    emit DistributeWinnings(msg.sender, bet, (winnings + stake.amount));
    
    }
}
