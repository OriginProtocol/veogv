# veOGV
Refer to the [veOGV site](https://originprotocol.github.io/veogv) for an overview of the project.

# Development

## Pre-requisite
Install Foundry following the instructions [here](https://book.getfoundry.sh/getting-started/installation).

## Run tests
Run:
```sh
forge install
forge test
```

# Deployment

## Preparation
 - EOA wallet
   - You'll need an EOA wallet with enough ETH to create contracts and make a few transactions.
   - The wallet is referred as the "deployer" in the instructions below.
 - Governance token
   - Edit contracts/GovernanceToken.sol to set the name and symbol of your governance token
 - Staking token
   - Edit contracts/OgvStaking.sol to set the name and symbol of your staking token
   - Pick configuration values to be used during the deployment phase
     - `epoch`: date at which users can start staking, as a Unix timestamp. For example to have the staking start on Tue Jul 12 2022 00:00:00 GMT+0000, use an eopch value of 1657584000
     - `min_stake_duration`: minimum staking duration, in seconds. For example for to have a minimum of 6 months, use a value of 15552000 = 6 * 30 * 24 * 60 * 60.
- Rewards
   - Pick configuration values to be used during the deployment phase
     -`inflation_slopes`: An array of structs (time_start, time_end, rate_per_day) with times in seconds since staking epoch and rate as an OGV amount with 18 decimals. The time ranges should be contiguous meaning the end_time for a range should be used as start_time for the next  range.

## Deploy

Notes:
 - The exact same set of commands can be used on Testnet and Mainnet. Just update the <rpc_url> to point at the desired target network.
 - The commands below are for deployig with proxies that give the optionality to upgrade the implementations in the future.

### Deploy the governance token
Deploy the implementation
```sh
forge create contracts/GovernanceToken.sol:OriginDollarGovernance \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

Deploy the proxy and set the implementation.
Note the second constructor argument is the 4-byte encoded signature of the `initialize()` function.
```sh
forge create contracts/upgrades/ERC1967Proxy.sol:ERC1967Proxy \
    --constructor-args <ogv_implementation_address> 0x8129fc1c \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

### Deploy the rewards source contract
Deploy the implementation, including setting immutable variables via the constructor.
```sh
forge create contracts/RewardsSource.sol:RewardsSource \
    --constructor-args <ogv_proxy_address>
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

Deploy the proxy, set the implementation and owner
```sh
forge create contracts/upgrades/RewardsSourceProxy.sol:RewardsSourceProxy \
    --constructor-args <rewards_implementation_address> <deployer_address> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

### Deploy the vote-escrowed token
Deploy the implementation, including setting immutable variables via the constructor.
```sh
forge create contracts/OgvStaking.sol:OgvStaking \
    --constructor-args <ogv_proxy_address> <epoch> <min_stake_duration> <rewards_proxy_address> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

Deploy the proxy, set the implementation and owner
```sh
forge create contracts/upgrades/OgvStakingProxy.sol:OgvStakingProxy \
    --constructor-args <staking_implementation_address> <deployer_address> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

### Configure the rewards source
Set the target as the veOGC contract
```sh
cast send <rewards_source_proxy_address> \
    "setRewardsTarget(address)" <staking_proxy_address> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key>
```

Set the inflation slopes
```sh
cast send <rewards_source_proxy_address> \
    setInflation((uint64,uint64,uint256)[])" <slopes> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key>
```
Note the cast syntax for passing an array of structs as an argument is `"[(x1,x2,x3),(y1,y2,y3),...)]"`. For example:
```sh
cast send 0x14418a3e84f8e6ED4dAfea481E7579673Cd5ed20 \
    "setInflation((uint64,uint64,uint256)[])" "[(1673504668,1704608668,100000000000000000000000),(1704608668,1735712668,1000000000000000000000)]" \
   --rpc-url $RPC_URL \
   --private-key $DEPLOYER_PK
```

## Test on a mainnet fork
Perform some tests in a fork to verify the contracts were properly deployed and configured.

**TODO** FILL IN INSTRUCTIONS TO START A FORK AND RUN SOME VERIFICATION TESTS

## Transfer ownership to a multisig
As a security measure, it is strongly recommended to have the contracts owned by a multi-sig vs an EOA. After having verified the deployment ran as expected, use the following procedure to transfer ownership of the contracts from the deployer EOA to a multi-sig.

**TODO** FILL IN
