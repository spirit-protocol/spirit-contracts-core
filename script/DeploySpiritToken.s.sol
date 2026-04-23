// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* Local imports */
import { SpiritDeployer } from "script/SpiritDeployer.sol";
import { NetworkConfig } from "script/config/NetworkConfig.sol";

/* Foundry imports */
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract DeploySpiritToken is Script {

    function _startBroadcast() internal returns (address deployer) {
        vm.startBroadcast();
        (, deployer,) = vm.readCallers();
    }

    function _stopBroadcast() internal {
        vm.stopBroadcast();
    }

    function run() external {
        uint256 chainId = block.chainid;

        // Get Base mainnet configuration
        NetworkConfig.SpiritDeploymentConfig memory config = NetworkConfig.getNetworkConfig(chainId);

        console.log("");
        console.log("===> DEPLOYMENT CONFIGURATION");
        console.log(" --- Treasury address              :", config.treasury);
        console.log(" --- Super Token Factory           :", config.superTokenFactory);
        console.log(" --- Spirit Token Name             :", config.spiritTokenName);
        console.log(" --- Spirit Token Symbol           :", config.spiritTokenSymbol);
        console.log(" --- Spirit Token Supply           :", config.spiritTokenSupply / 1e18);

        // Start broadcasting transactions
        address deployer = _startBroadcast();
        console.log("");
        console.log("===> DEPLOYING SPIRIT PROTOCOL");
        console.log(" --- Chain ID          :   ", chainId);
        console.log(" --- Deployer address  :   ", deployer);
        console.log(" --- Deployer balance  :   ", deployer.balance / 1e18, "ETH");

        // Deploy Spirit Protocol
        SpiritDeployer.SpiritDeploymentResult memory result = SpiritDeployer._deploySpiritToken(config, config.treasury);

        _stopBroadcast();

        console.log("");
        console.log("===> DEPLOYMENT RESULTS");
        console.log(" --- Spirit Token              :", result.spirit);
        console.log("");
    }

}
