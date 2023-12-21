// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/**
 * @title A sample Raffle contract
 * @author Paul Simroth
 * @notice This contract id for creating a raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle is VRFConsumerBaseV2 {
    /** ERRORS */
    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );

    /** TYPE DECLARATIONS */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /** STATE VARIABLES */
    /// @notice number of blocks for confirming VRF
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    /// @notice number of returned values of VRF
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    /// @notice Duration of lottery in seconds
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    /// @notice The gas lane to use, which specifies the maximum gas price to bump to.
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /** EVENTS */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    /** CONSTRUCTOR */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    /** FUNCTIONS */
    function enterRaffle() external payable {
        //Check msg.value
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        // Push msg.sender to player array
        s_players.push(payable(msg.sender));
        // Emit event upon entering raffle
        emit RaffleEntered(msg.sender);
    }

    /**
     * @notice This is the function called by Chainlink Automation to see if it is time to end the raffle.
     * The following should be true for the function to return true:
     *  1. Time interval between raffle runs has passed
     *  2. Raffle State is OPEN
     *  3. The contract has ETH
     *  4. Subscription is funded with LINK
     * @dev The Chainlink Automation Network frequently simulates your checkUpkeep off-chain to determine
     *  if the updateInterval time has passed since the last increment (timestamp).
     *  When checkUpkeep returns true, the Chainlink Automation Network calls performUpkeep on-chain and increments the counter.
     *  This cycle repeats until the upkeep is cancelled or runs out of funding.
     * @return upkeepNeeded
     * @return performData
     */
    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    /**
     * 1. Get random number, 2. Use random number to pick a player
     * @dev this function picks the winner and follows the Chainlink Automation Docs.
     * performUpkeep function will be executed on-chain when checkUpkeep returns true.
     */
    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        // Set Raffle to CALCULATING
        s_raffleState = RaffleState.CALCULATING;
        // 1. Request RNG from Chainlink VRF
        uint256 request = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(request);
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        //Reset Raffle to OPEN
        s_raffleState = RaffleState.OPEN;
        // clear s_players Array for new Raffle
        s_players = new address payable[](0);
        // Reset Clock for new Raffle
        s_lastTimeStamp = block.timestamp;
        // Emit Event
        emit WinnerPicked(winner);
        // Transfer funds to winner
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    /**
     * GETTER FUNCTIONS
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

    function getLengthOfPlayerArray() external view returns (uint256) {
        return s_players.length;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }
}
