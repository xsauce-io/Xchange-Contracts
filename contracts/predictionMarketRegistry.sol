
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.17 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./predictionMarket.sol";
import "../interfaces/IERC20Burnable.sol";

contract predictionMarketRegistry is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Burnable;

    event PredictionMarketCreated(
        uint256 predictionMarketId,
        address creator,
        address predictionMarketAddress
    );

    address internal vrfCoordinatorAddress;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 private predictionMarketCount;
    mapping(uint256 => address) public predictionMarketRegistry;

    constructor(
        address _vrfCoordinatorAddress,
        bytes32 _keyHash,
        uint256 _fee
    ) {
        nativeTokenAddress = _nativeTokenAddress;
        vrfCoordinatorAddress = _vrfCoordinatorAddress;
        keyHash = _keyHash;
        fee = _fee;
        predictionMarketCount = 0;
    }

    /**
     * Making sure that the `_predictionMarketId` is valid
     */
    modifier onlyExistingMarket(uint256 _predictionMarketId) {
        require(_predictionMarketId < predictionMarketCount);
        _;
    }

    /**
     * Get Betting Game Address by `_predictionMarketId`
     */
    function getPredictionMarketById(uint256 _predictionMarketId)
        public
        view
        returns (address)
    {
        return predictionMarketRegistry[_predictionMarketId];
    }

  
    /**
     * Create new `BettingGame` instance
     */
    function createMarket(uint256 ) public {

        // 2. Create new `BettingGame` smart contract
        predictionMarket newPredictionMarket = new PredictionMarket(
            vrfCoordinatorAddress,
            keyHash,
            fee,
            msg.sender,
        );
        predictionMarketRegistry[predictionMarketCount] = address(newPredictionMarket);

        emit PredictionMarketCreated(
            predictionMarketCount,
            msg.sender,
            address(newPredictionMarket)
        );

        // 3. Increase Betting Game Counter
        predictionMarketCount = SafeMath.add(predictionMarketCount, 1);
    }
}