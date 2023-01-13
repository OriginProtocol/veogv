<img alt="veOGV" src="assets/img/veogv.png">


<img alt="OGV and OUSD" src="assets/img/ogv_and_ousd.png">



OGV and veOGV are the governance and staked governance tokens for [Origin Dollar (OUSD)](https://ousd.com) which is a leading DeFi protocol on the Etherum blockchain. Refer to the [OUSD docs](https://docs.ousd.com/governance/ogv-staking) for more details on  how the OUSD protocol uses OGV and veOGV.

# Characteristics

[Curve Finance](https://curve.fi) pioneered the concept of vote-escrowed token when they released their [veCRV implementation](https://github.com/curvefi/curve-dao-contracts/blob/1086fe318b705d7d7b47f141c2aee33663c32d14/contracts/VotingEscrow.vy).

veOGV innovation resides in using an exponential decay as opposed to the linear decay used by veCRV. This allows to significantly reduce the complexity of the smart contract logic (veOGV is 175 loc), unlocks functionality such as vote delegation and minimizes gas consumption.

Here are some of veOGV key characteristics:
 - ERC20
 - Open Zeppelin [ERC20Votes](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Votes.sol) compatible
 - Vote delegation
 - Configurable rewards token distribution

In comparison to veCRV, veOGV offers several advantages. A trade-off is that is that with veOGV the voting power does not decay down to zero. It is a side effect of using exponential decay vs linear decay.

| Attribute | veOGV | veCRV |
| ----------- | ----------- | ----------- |
| ERC20      | Yes | Yes |
| Snapshot | Yes | Yes |
| Vote delegation | Yes | No |
| Built-in rewards distribution | Yes | No |
| Solidity smart contracts | Yes | No (vyper) |
| Residual voting power at the end of the staking | No  | Yes |

TBD: should we have more content inspired from the OUSD docs here?

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

<img alt="chart-Linear-voting-decay-2 users" src="assets/img/chart-Linear-voting-decay-2 users.png">



# Rewards
veOGV includes a baked-in functionality to distribute rewards to the stakers. The rewards are in the form of extra OGV that are awarded relatively to the percentage of veOGV a staker holds.

The rewards schedule is configurable as tranches. A tranche is defined by a time window and amount of OGV rewards to distribute per day in that tranche. The stakers can collect their rewards at anytime.

The distribution of awards is optional and can be turned off if desired.

TODO: add a diagram representing the "step function" based reward schedule.

# Implementation

The smart contract implementation is structured into 3 compact contracts for a total of less than 400 lines of code! 
 - GovernanceToken.sol: The OGV ERC20 token.
 - OGVStaking.sol: The veOGV implementation. Including staking, unstaking and rewards collection.
 - RewardsSource.sol: The logic related to the calculation and minting of rewards (in the form of extra OGV) for the stakers.

# Gas usage
The veOGV implementation is optimized for low gas consumption.
| Operation | Gas usage in gwei |
| ----------- | ----------- |
| Stake      | 257k |
| Unstake and collect rewards | 104k |
| Extend stake | 174k |
| Delegate | 102k |

# Security
veOGV smart contracts were audited by Open Zeppelin. The audit report can be found [here](https://github.com/OriginProtocol/security/blob/master/audits/Solidified%20-%20OGV%2C%20wOUSD%2C%20and%20ERC721a%20-%20May%202022.pdf).

# Using OGV and veOGV for your project
The implementation of the OGV and veOGV tokens is meant to be generic - there is no code specific to Origin Dollar. Refer to the [README](https://github.com/OriginProtocol/veogv/blob/main/README.md) for step by step instructions to deploy your own vote-escrowed governance token.
