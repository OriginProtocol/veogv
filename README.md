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

## Configuration
 - Configure contracts/GovernanceToken.sol
   - Update the name and symbol of your governance token
   - ...
 - Configure contracts/OgvStaking.sol
   - Update the `symbol()` method in  to return the symbol of your staked governance token (vs "veOGV")
   - Pick a value for `epoch` which is the start of staking as a Unix timestamp
   - ...
- Configure contracts/RewardsSource.sol
   - Pick your inflation slopes
   - ...

## Deploy to testnet
FILL ME

## Deploy to Mainnet
FILL ME
