//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

//Errors
error Raffle__UpKeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);
error Raffle__NotEnoughEthENtered();
error Raffle__TransactionNotSuccessfull();
error Raffle__NotOpen();

/**@title A sample Ralle Contract
 * @author Aakash Verma
 * @notice This contract is for creating an untemperable decentralized smart contract
 * @dev This implements Chainlink VRF v2and chainlink keepers
 */

contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    //Type Declaration
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /*State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
    bytes32 public immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    /* Lottery Variables*/
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    /*Events*/

    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed recentWinner);

    /*Constructor*/
    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        uint256 interval,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthENtered();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    /**
     * @dev This is the fucntion that the Chainlink Keeper nodes call
     * They look for upKeepNeeded to return true.
     * The following conditions should be true for this to return true.
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     **/
    function checkUpkeep(
        bytes memory /*checkData*/
    )
        public
        view
        override
        returns (
            bool upKeepNeeded,
            bytes memory /*performData*/
        )
    {
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasEth = (address(this).balance > 0);
        bool hasPlayers = s_players.length > 0;

        upKeepNeeded = (timePassed && isOpen && hasEth && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256, /*requestId*/
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransactionNotSuccessfull();
        }
        emit WinnerPicked(recentWinner);
    }

    //View / Pure Functions
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getLastTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }
}
