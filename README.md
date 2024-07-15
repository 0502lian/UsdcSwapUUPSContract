# Simple USDC swap UUPS Upgradeable Contract

## Objective:
Create an upgradable Solidity smart contract to manage and exchange USDC tokens. The system will allow owner to deposit USDC for liquidity and allow users swap ETH for USDC with real-time ETH prices sourced from Chainlink Functions.

## Feature:
### Owner:
 - (1) upgrade swap contract
 - (2) Provide liquidity using USDC
 - (3) get swap fee
 - (4) withdraw ETH and USDC

 ### Users
 - (1) swap ETH for USDC with real-time ETH prices sourced from Chainlink
 - (2) Use minOutAmount to avoid trades during a sudden drop in ETH price.

### Note: 
USDC is not equivalent to USD.

## Unit Testing:
- 1 USDCSwapTest.t.sol 
For testing USDC swap-related functions.
- 2 DeployAndUpgradeTest.t.sol 
For testing UUPS upgrade functions.


## Contract Deployment
### scripts
- 1 DeployUsdcSwap.s.sol 
For deploy mockUSDC, proxy and USDCSwapV1 contract
- 2 SettingUsdcSWap.s.sol 
For simple opt on testnet


### contract deployment on sepolia
**All conduct source code have been verified on Etherscan**
- mockUSDC: 0xf3F1bA94A626d6F92E60a89152F1D4Ee5ceC42e2
- USDCSwapV1: 0xA74D4f6e92e70690E7D67d258a74CfF116659E9A
- proxy: 0x6E05420d6E7E6b2ebCeE9B97B1E9E1d4179ce505
- ethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // chainlink ETH/USD price feed
- usdcPriceFeed:0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E // chainlink USDC/usd price feed


## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.



## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployUsdcSwap.s.sol:DeployUsdcSwap --rpc-url <your_rpc_url> --private-key <your_private_key>
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
