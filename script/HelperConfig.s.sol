// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

/**
 * @title HelperConfig
 * @author paulsimroth
 * @notice This script helps with configuring the DeployRaffle script
 */

contract HelperConfig is Script {
    /// @param NetworkConfig takes the constructor arguments from the contract Raffle.sol
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address linkToken;
        uint256 deployerKey;
    }

    // defalut anvil private key used for local testing
    uint256 public constant DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    /**
     * Constructor to set deploy and setup contract depending on chainid
     * @dev other networks may be added, make sure to add the correct setup function for each network. Consult Chainlink docs on correct addresses
     */
    constructor() {
        if (block.chainid == 11155111) {
            /// Sepolia chainid == 11155111; setup with Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            /// ETH Mainnet chainid == 1; setup with Mainnet
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            /// If none are true, use local anvil chain
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    /// @dev Configure contract for Sepolia Testnet
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                /// @param vrfCoordinator taken from Chainlink VRF Docs
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                /// @param gasLane taken from Chainlink VRF docs
                /// @dev docs use the term keyHash; here the 150 gwei Key Hash is used
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                /// script will add @param subscriptionId
                subscriptionId: 0,
                /// Gas limit set to 500.000
                callbackGasLimit: 500000,
                // LINK contract address from Chainlink Docs
                linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                // Private Key for deployer wallet
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    /// @dev Configure contract for ETH Mainnet
    function getMainnetEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                /// @param vrfCoordinator taken from Chainlink VRF Docs
                vrfCoordinator: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
                /// @param gasLane taken from Chainlink VRF docs
                /// @dev docs use the term keyHash; here the 500 gwei Key Hash is used; 200 and 1000 gwei are also possible
                gasLane: 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92,
                /// script will add @param subscriptionId
                subscriptionId: 0,
                /// Gas limit set to 500.000
                callbackGasLimit: 500000,
                // LINK contract address from Chainlink Docs
                linkToken: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
                // Private Key for deployer wallet
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    /// @dev Configure contract for local development with Anvil
    /// @notice VRFCoordinatorV2Mock is a mock version of the real VRFCoordinatorV2 contract
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        /// @dev constructor values for VRFCoordinatorv2Mock contract
        uint96 baseFee = 0.25 ether; // 0.25 LINK
        uint96 gasPriceLink = 1e9; // 1gwei

        vm.startBroadcast();
        /**
         * @dev VRFCoordinatorV2Mock constructor takes @param _baseFee and @param _gasPriceLink
         * Gas is payed with LINK token
         */
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                /// @param vrfCoordinator taken from Chainlink VRF Docs
                vrfCoordinator: address(vrfCoordinatorMock),
                /// @param gasLane does not matter on anvil
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                /// script will add @param subscriptionId
                subscriptionId: 0,
                /// Gas limit set to 500.000
                callbackGasLimit: 500000,
                // LINK contract address from mock link token contract deployed localy
                linkToken: address(link),
                deployerKey: DEFAULT_ANVIL_KEY
            });
    }
}
