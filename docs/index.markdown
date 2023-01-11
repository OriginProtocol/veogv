# veOGV

OGV and veOGV are the governance and staked governance tokens for [Origin Dollar](https://ousd.com) which is a DeFi protocol on the Etherum blockchain.

# OGV and veOGV high level characteristics

[Curve](https://curve.fi) introduced the concept of vote-escrowed token when they released their [veCRV implementation](https://github.com/curvefi/curve-dao-contracts/blob/1086fe318b705d7d7b47f141c2aee33663c32d14/contracts/VotingEscrow.vy).

veOGV main innovation resides in using an exponential decay as opposed to the linear decay used for veCRV.
It allows to significantly reduce the complexity of the smart contract and its gas cunsumption.

Key characteristics:
 - Open Zeppelin ERC20 vote compatible

Refer to the [OUSD docs](https://docs.ousd.com/governance/ogv-staking)

TBD: should we duplicate the content from OUSD docs here?

# Deep dive into decay voting power</h1>

The amount of veOGV allocated in return for staking OGV uses the formula: ${veOGV = OGV * k^y } with:
 - veOGV is amount of veOGV returned
 - OGV is the amount of OGV staked
 - k is a constant (for veOGV launch we chose a value of 1.8 but this is configurable)
 - y is the end date of the escrow, as a timestamp in second

TODO: add more details and diagrams, primary based on [DVF's notes](https://gist.github.com/DanielVF/728326db026c3f95a4e994b286a0a147)


# Solidity implementation</h1>

The smart contract implementation is structured into 3 contracts:
## GovernanceToken.sol
The OGV ERC20 token.

## OGVStaking.sol
The veOGV implementation, including staking and unstaking.

## RewardsSource.sol
Implementation for the logic related to the calculation and collection of rewards (in the form of extra OGV) for the stakers.

# Using OGV and veOGV for your project
The implementation OGV and veOGV tokens is meant to be generic - there is no code specific to Origin Dollar. Origin Protocol encourages the community to  Refer to the [README](https://github.com/OriginProtocol/veogv/blob/main/README.md) for step by step instructions to deploy your own vote-escrowed governance token.
