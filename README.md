# Foundry Lottery with proofable randomness

## Objective

This is a proofably random smart contract lottery built with foundry. This project is a smart contract lottery using Chainlink VRF to determine a random winner. Chainlink automation is used to call the functions to determine the winner. This project does also include the relevant tests.

1. Users can enter by purchasing a ticket
2. After a specific time period the lottery will draw a winner
3. This will be done with ChainLink Automation (Time based trigger) and VRF (verifiable randomness)
4. The winner will receive all ticket fees gathered.

## Tech Stack

- [Foundry](https://book.getfoundry.sh/) (Smart Contract Development Framework)
- [Chainlink-Brownie-Contracts](https://github.com/smartcontractkit/chainlink-brownie-contracts/tree/main) (Chainlink Smart Contracts)
- [Chainlink-VRF](https://docs.chain.link/vrf) (Chainlink´s Verifiable Random Function)
- [Chainlink-Automation](https://docs.chain.link/chainlink-automation) 

## Usage

### Project Setup

If you want to clone this project run the following command
```shell
$ forge init
$ make install
```

### Build and Compile Contracts

```shell
$ forge build
```

### Test

```shell
$ forge test 
```

Run test with matching function
```shell
$ forge test --match-test <testYourTestName>
```

Test how much of your contracts your test cover by running this command:
```shell
$ forge coverage
```

get more inforamtion on what functions still need to be tested and output it to coverage.txt
```shell
$ forge coverage --report debug > coverage.txt
```
Debug tool; With this you can navigate throught your contract opcode
```shell
$ forge test --debug <testYourTestName>
```

### Gas Estimation

You can estimate how much gas things cost by running:
```shell
$ forge snapshot
```

### Anvil (Fooundry Local Dev Chain)

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployRaffle.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

or use the commands in the makefile
#### deploy to local Anvil chain
here make sure to start up Anvil before running this command
```shell
$ make deploy
```
#### deploy to Sepolia Testnet
```shell
$ make deploy ARGS="--network sepolia"
```

#### NOTE FOR DEPLOYMENT
After deploying the contract you must manually register a new Upkeep on Chainlink Automation using the contract address!

### Cast
You can interact with your contracts from the command line useing cast
```shell
$ cast <subcommand>
```
