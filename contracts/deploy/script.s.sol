pragma solidity 0.8.10;

import "forge-std/Script.sol";

import "../upgrades/ERC1967Proxy.sol";
import "../upgrades/RewardsSourceProxy.sol";
import "../upgrades/OgvStakingProxy.sol";
import "../GovernanceToken.sol";
import "../OgvStaking.sol";
import "../RewardsSource.sol";

contract Deploy is Script {

    uint256 constant EPOCH = 1657584000;
    uint256 constant MIN_STAKE_DURATION = 180 days;

    function run() external {
        address deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        console.log("Deployer: ", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the governance token.
        OriginDollarGovernance ogv = new OriginDollarGovernance();
        bytes memory initializeSignature = abi.encode(bytes4(keccak256("initialize()")));
        ERC1967Proxy ogvProxy = new ERC1967Proxy(address(ogv), initializeSignature);

        // Deploy the rewards source token.
        RewardsSource source = new RewardsSource(address(ogvProxy));
        RewardsSourceProxy rewardsProxy = new RewardsSourceProxy();
        rewardsProxy.initialize(address(source), deployerAddress, '');
        source = RewardsSource(address(rewardsProxy));

        // Deploy the vote-escrowed token.
        OgvStaking staking = new OgvStaking(address(ogvProxy), EPOCH, MIN_STAKE_DURATION, address(source));
        OgvStakingProxy stakingProxy = new OgvStakingProxy();
        stakingProxy.initialize(address(staking), deployerAddress, '');

        // Configure the vote-escrowed token.
        staking = OgvStaking(address(stakingProxy));
        source.setRewardsTarget(address(staking));

        // Set the rewards inflation schedule.
        RewardsSource.Slope[] memory slopes = new RewardsSource.Slope[](3);
        slopes[0].start = uint64(EPOCH);
        slopes[0].ratePerDay = 1000000 ether;
        slopes[1].start = uint64(EPOCH + 30 days);
        slopes[1].ratePerDay = 100000 ether;
        slopes[2].start = uint64(EPOCH + 60 days);
        slopes[2].ratePerDay = 1 ether;
        source.setInflation(slopes);

        vm.stopBroadcast();
    }
}
