# Foundry Lottery with proofable randomness

## Objective

This is a proofably random smart contract lottery built with foundry.

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

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil (Fooundry Local Dev Chain)

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
