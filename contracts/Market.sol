// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./wallet.sol";

contract Market is Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;
    

    enum Position {
        NONE,
        LONG,
        SHORT
    }


    enum MarketStatus {
        OPEN,
        PAUSE,
        CLOSED
    }


    struct MarketMetrics {
        uint256 timestamp;
        address creator;
    }
  
    struct margin {
        uint256 timestamp;
        uint256 amount;
        address staker;
        address escrow;
        Position side;

    }
    mapping(address => margin) public marginDetails;
    mapping(address => mapping(Position => margin)) public fluidPosition;
    IERC20 public _DAI;
    address private _feeCollector;
    address public _oracle;
    MarketStatus status;
    Counters.Counter private _LongCounter;
    Counters.Counter private _ShortCounter;

    modifier onlyOracle {
        require(msg.sender == _oracle);
        _;
    }

    constructor (address oracle, address feeCollector, IERC20 DAI) {
        status = MarketStatus.OPEN;
        Position side = Position.NONE;
        _DAI = DAI;
        _feeCollector = feeCollector;
        // also put this in .env file
        _oracle = oracle;
    }
// Events defined here
    event PositionOpened(address indexed sender,Position side, uint256 positionSize);
    event MarketOpened();
    event MarketPaused();
    event MarketClosed();
    // event WinnerPicked(bool winner);
    // event DistributeWinnings(address indexed sender, side, uint256 amount);


    

    function OpenPosition(uint256 positionSize, Position side) external {
        //@dev makes sure user has enough margin to cover their position and fees
        require(positionSize <= ((_DAI.balanceOf(marginDetails[msg.sender].escrow) * 5) / 100), "Need more margin");
        require(status == MarketStatus.OPEN, "Market is not open");
        // Must specify valid plan
        require(side != Position.NONE, "Please enter a valid plan");
        //require 10 DAI tokens minimum
        require(positionSize >= 5 * (10**18), "Minimum amount = 10 DAI");
        

        uint256 feepct = 1;

        if (marginDetails[msg.sender][side] == Position.LONG) {
            //Transfer to create a Long position
                uint256 position = (positionSize * feepct) / 100;
                uint256 owed = (positionSize - position);
                _DAI.transferFrom(msg.sender, _feeCollector, position);
                _DAI.transferFrom(msg.sender, address(marginDetails[msg.sender].escrow) , owed);
                _LongCounter.increment();
            }
         else if (marginDetails[msg.sender][side] == Position.SHORT) {

            //Transfer to create a Short position
                uint256 position = (positionSize * feepct) / 100;
                uint256 owed = (positionSize - position);
                _DAI.transferFrom(msg.sender, _feeCollector, position);
                _DAI.transferFrom(msg.sender, address(marginDetails[msg.sender].escrow) , owed);
                _ShortCounter.increment();
            }
          
        emit PositionOpened(msg.sender, side, positionSize);

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

    // function PickWinner(bool response) public onlyOracle {
    //      require(status == MarketStatus.CLOSED, "Market still open");

    //     if (response) { 
    //         bet = Answer.TRUE;
    //         otherBet = Answer.FALSE;
    //     }
    //     else {
    //         bet = Answer.FALSE;
    //         otherBet = Answer.TRUE;
    //     }

    //     emit WinnerPicked(response);
    // }

    // function claim() public {
    //     require(stakes[msg.sender][bet].amount > 0, "not a winner");
    //     Stake memory stake = stakes[msg.sender][bet];
    //     delete stakes[msg.sender][bet];
    //     uint256 feepct = 5;
    //     uint256 position = (stake.amount * feepct) / 100;
    //     uint256 owed = (stake.amount - position);
    //     //Return Initial
    //     _DAI.transferFrom(address(escrow[bet]), msg.sender, owed);
    //     uint256 count = (bet == Answer.TRUE) ? _FalseCounter.current() : _TrueCounter.current();
    //     uint256 winnings = (_DAI.balanceOf(address(escrow[otherBet])) / count);
    //     //Send Profits
    //     _DAI.transferFrom(address(escrow[otherBet]), msg.sender, winnings);
    //     // delete the storage plan mapped to the wallet upon exit
       
    
    // emit DistributeWinnings(msg.sender, bet, (winnings + stake.amount));
    
    // }
}
