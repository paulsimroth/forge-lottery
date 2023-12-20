-include .env

## Deploy contract on Anvil
deploy-anvil:
	forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PRIVATE_KEY) --broadcast -vvvv

## Deploy contract on Sepolia Testnet
deploy-sepolia:
	forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --private-key $(TN_PRIVATE_KEY) --broadcast -vvvv

## Deploy and verify contract on Sepolia Testnet
deploy-sepolia-verified:
	forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(SEPOLIA_RPC_URL) --private-key $(TN_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv