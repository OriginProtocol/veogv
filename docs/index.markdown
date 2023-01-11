# veOGV

OGV and veOGV are the governance and staked governance tokens for [Origin Dollar](https://ousd.com) which is a DeFi protocol on the Etherum blockchain.

# Characteristics

[Curve](https://curve.fi) pioneered the concept of vote-escrowed token when they released their [veCRV implementation](https://github.com/curvefi/curve-dao-contracts/blob/1086fe318b705d7d7b47f141c2aee33663c32d14/contracts/VotingEscrow.vy).

veOGV innovation resides in using an exponential decay as opposed to the linear decay used by veCRV. This allows to significantly reduce the complexity of the smart contract logic, and its gas consumption.



veOGV key characteristics:
 - ERC20
 - Open Zeppelin [ERC20Votes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Votes.sol) compatible
 - Vote delegation
 - Configurable rewards token distribution


Refer to the [OUSD docs](https://docs.ousd.com/governance/ogv-staking)

TBD: should we duplicate the content from OUSD docs here?

# Exponential voting power decay</h1>

The amount of veOGV allocated in return for staking OGV is calculated using this formula:

**veOGV = OGV * k^y**
 - veOGV is the amount of veOGV minted
 - OGV is the amount of OGV staked
 - k is a constant (for veOGV we chose a value of 1.8 but it is configurable)
 - y is the end date of the staking, as a timestamp in second

This has the following properties:

 - After staking OGV, the staker's veOGV balance remains constant.
 - The voting power decay happens via dilution as additional veOGV tokens are minted when new stakes occur.
 - The voting power of a staker relative to the othe stakers remains constant until a new stake or unstake event occurs.

TODO: add more details and diagrams, primary based on [DVF's notes](https://gist.github.com/DanielVF/728326db026c3f95a4e994b286a0a147)


# Implementation</h1>

The smart contract implementation is structured into 3 contracts:
## GovernanceToken.sol
The OGV ERC20 token.

## OGVStaking.sol
The veOGV implementation, including staking and unstaking.

## RewardsSource.sol
Implementation for the logic related to the calculation and collection of rewards (in the form of extra OGV) for the stakers.

# Gas usage
The veOGV implementation is optimized for low gas consumption.
| Operation      | Gas usage in gwei |
| ----------- | ----------- |
| Stake      | 257k |
| Unstake and collect rewards | 104k |
| Extend stake | 174k |
| Delegate | 102k |

# Using OGV and veOGV for your project
The implementation OGV and veOGV tokens is meant to be generic - there is no code specific to Origin Dollar. Refer to the [README](https://github.com/OriginProtocol/veogv/blob/main/README.md) for step by step instructions to deploy your own vote-escrowed governance token.
