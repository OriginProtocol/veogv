# veOGV
Refer to the [veOGV site](https://originprotocol.github.io/veogv) for an overview of the project.

# Development

## Run tests
Install Forge following the instructions [here](https://book.getfoundry.sh/forge/).

Then run:
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
   - Pick a value for `epoch` which is the start of staking as a Unix timestamp. It will be needed during the deployment phase.
- Rewards
   - Pick your inflation slopes. Slopes are made of a series of time ranges (unit: timestamp in seconds since staking epoch) and an amount of OGV (unit: 18 decimals). The time ranges should be contiguous.

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

Deploy the proxy and set the implementation
```sh
forge create contracts/upgrades/ERC1967Proxy.sol:ERC1967Proxy \
    --constructor-args <ogv_implementation_address>\
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
    --constructor-args <rewards_implementation_address> <governor_address> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

### Deploy the vote-escrowed token
Deploy the implementation, including setting immutable variables via the constructor.
```sh
forge create contracts/OgvStaking.sol:OgvStaking \
    --constructor-args <epoch> <min_stake_duration> <rewards_proxy_address>
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

Deploy the proxy, set the implementation and owner
```sh
forge create contracts/upgrades/OgvStakingProxy.sol:OgvStaking \
    --constructor-args <staking_implementation_address> <governor_address> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify
```

### Configure the rewards source
Set the target as the veOGC contract
```sh
cast call \
    <rewards_source_proxy_address> "setRewardsTarget(address)" \
    <staking_implementation_address>
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key>
```

Set the inflation slopes
**TODO**: slopes is an array of structs - figure how to pass that data via cast
```sh
cast call \
    <rewards_source_proxy_address> "setInflation(Slope[] memory slopes)" \
    <staking_implementation_address> \
    <slopes> \
    --rpc-url <rpc_url> \
    --private-key <deployer_private_key>
```

## Transfer ownership to a multisig
As a security measure, it is strongly recommended to have the contracts owned by a multi-sig vs an EOA. After having verified the deployment ran as expected, use the following procedure to transfer ownership of the contracts from the deployer EOA to a multi-sig.

**TODO** FILL IN
