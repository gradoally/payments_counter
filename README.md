# TON Payments Counter

This library represents the sollution of the task, that follows. You can find the resulting contract deloyed [here](https://testnet.tonscan.org/address/EQAIvGNr0v1aht8AbHr0yAi6DeTvtsRihTGpmltGSwQ1XTO7)

## Task

Implement a proxy that count transactions

Description: Implement a system of smart contracts that count how many times an user send a payment to a certain user, and route the payment to the owner of the smart contract(s). A payment, to be accepted, should have an arbitrary body (empty is OK) and msg_value greater than 0.1 TON. For user perspective, the contract should work fine with normal transfers from common TON Wallets. For any user, the recipient should be always the same.

Requirements:
- the admin of the proxy should be able to change the admin address (using opcode = 1)
- contracts should have a way to check the number of transaction per each user via get-calls (offchain)
- the fees must be linear
- the system is workchain specific and should work only in basechain
- if a payment is rejected (eg msg_value < 0.1ton), the ton should be sent back to the user
- the contract should work on his own, without any kind of backend or frontend

eta: 2 days

## Installation

### Step 0: Check bash version

Please use bash version 3.2.57(1)-release to execute this lib.

### Step 1: Check ton-binaries

Download nessesary TON pre-build [here](https://github.com/ton-blockchain/ton/actions?query=branch%3Amaster+is%3Acompleted) and change directories to lite-client, fift and func compilers on lines 6-8 of [shell_config.sh](config/shell_config.sh) as follows:

```bash
path_to_func_binaries=YOUR_PATH # func
path_to_fift_binaries=YOUR_PATH # fift
path_to_lite_client_binaries=YOUR_PATH # lite-client
```

### Step 2: Compile deploy-wallet

First you need to compile your deploy wallet, that will send internal messages to other smart-contracts and load coins on them. After compiling the wallet you will find files with private key, wallet address and resulting BOC-file that we will send to blockchain on deploy in the directory [src/build/wallet/](src/build/wallet/)

Example:

```bash
./use.sh compile-wallet
```

### Step 3: Load TON's

Load coins to the address of your future deploy-wallet using [Testnet TON Wallet](https://wallet.ton.org/?testnet=true) in testnet and [TON Wallet](https://wallet.ton.org), [Tonkeeper](https://tonkeeper.com) or [Tonhub](https://tonhub.com) in mainnet.

You will find the address of your future wallet (where you need to send coins) in the output of the terminal after making the previous step. Search a line in output like this:

> new wallet address = COPY_ADDRESS_THAT_WILL_BE_HERE

### Step 4: Mint deploy-wallet

Use command below to deploy wallet:

> ./use.sh deploy-wallet [net]

| Argument | Description |
| --- | --- |
| [net] | Stipulate "testnet" or "mainnet" |

Example:

```bash
./use.sh deploy-wallet testnet
```

## Usage

1. **Deploy-wallet** will deploy contracts and send messages
2. **Counter-contracts** is a smart-contract of particular counter that has admin_addr and counter_num in it's storage
3. **Counter-contract-minter** is a smart-contract that is able to mint counter-contracts on-chain and has counter-contract code in it's storage

### Deploy counter-minter

This pattern will compile both counter-contract and counter-contract-minter, create a BOC-query for minting counter-contract-minter, and send BOC to blockchain. You can get the address of the newly deployed contract in the output.

> ./use.sh deploy-counter-minter [net]

| Argument | Description |
| --- | --- |
| [net] | Stipulate "testnet" or "mainnet" |

Example:

```bash
./use.sh deploy-counter-minter testnet
```