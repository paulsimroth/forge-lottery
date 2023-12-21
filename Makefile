-include .env

.PHONY: all test deploy

install:
	forge install smartcontractkit/chainlink-brownie-contracts@0.8.0 --no-commit && forge install Cyfrin/foundry-devops --no-commit && forge install transmissions11/solmate --no-commit

## if there are no network args passed the contracts will deploy on anvil
NETWORK_ARGS := --rpc-url http://127.0.0.1:8545 --private-key $(ANVIL_PRIVATE_KEY) --broadcast -vvvv

## if --network sepolia ist used, then it will run the deployment for sepolia
ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv
endif

## Test with local fork of Sepolia Testnet
forktest-sepolia:
	forge test --fork-url $(SEPOLIA_RPC_URL)

## Deploy contract on Anvil local chain or Sepolia Testnet
deploy:
	@forge script script/DeployRaffle.s.sol:DeployRaffle $(NETWORK_ARGS)

## Deploy and verify contract on Sepolia Testnet
deploy-sepolia-verified:
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv