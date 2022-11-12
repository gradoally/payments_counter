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

Note that you will run the spript ./use.sh to run all methods

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

### Create a personal counter

In order to create your personal counter just send any amount more that 0.1 TON on counter-contract-minter. I will mint a new counter with the sender's address as an admin.

### Get counter_num

Use the following pattern to get the number inside the storage of the spicific counter.

> ./use.sh get-counter-num [net] [counter_addr]

| Argument | Description |
| --- | --- |
| [net] | Stipulate "testnet" or "mainnet" |
| [counter_addr] | The address of the specific counter that you want to invoke a get-method of |

Example:

```bash
./use.sh get-counter-num testnet EQCJ7ePEjkAS08EGrxP_qyKjZiBLo2qhiv0g3oyppDFy6tnk
```

### Get admin address

Use the following pattern to get the slice with admin_addr inside the storage of the spicific counter. Note that it will be passed as 256-bit integer.

> ./use.sh get-counter-admin [net] [counter_addr]

| Argument | Description |
| --- | --- |
| [net] | Stipulate "testnet" or "mainnet" |
| [counter_addr] | The address of the specific counter that you want to invoke a get-method of |

Example:

```bash
./use.sh get-counter-admin testnet EQCJ7ePEjkAS08EGrxP_qyKjZiBLo2qhiv0g3oyppDFy6tnk
```

## Additional methods

Although this is a fully decentralized system, you can manually deploy a counter off-chain. For instance, you can do this to test change-counter-admin function with message generated automatically.

### Deploy counter

Use the pattern below to deploy a counter-contract off-chain.

> ./use.sh deploy-counter [net] [admin_addr] [counter_num]

| Argument | Description |
| --- | --- |
| [net] | Stipulate "testnet" or "mainnet" |
| [admin_addr] | The admin of the counter |
| [counter_num] | The initial number of the counter in it's storage, e.g. you can put 0 |

Example:

```bash
./use.sh get-counter-admin testnet EQD57OL7n9KjwN5vxrW5KOJ-WIQTEw85mSMXmkdcSS_eLzi7 0
```

### Change counter admin

Use the pattern below to change the admin of the specific counter. Note that deploy-wallet shoul be the admin of this counter, as just him has the access to this function.

> ./use.sh change-counter-admin [net] [counter_addr] [new_admin_addr]

| Argument | Description |
| --- | --- |
| [net] | Stipulate "testnet" or "mainnet" |
| [counter_addr] | The address of the specific counter that you want to invoke a get-method of |
| [new_admin_addr] | The new admin of the counter. Note that the rest amount of the message will be forwarded to him |

Example:

```bash
./use.sh get-counter-admin testnet EQCJ7ePEjkAS08EGrxP_qyKjZiBLo2qhiv0g3oyppDFy6tnk EQD57OL7n9KjwN5vxrW5KOJ-WIQTEw85mSMXmkdcSS_eLzi7
```