// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* Local imports */
import { SpiritRegistry } from "src/registry/SpiritRegistry.sol";

/* Foundry imports */
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

/**
 * @title DeploySpiritRegistry
 * @notice Deploys the SpiritRegistry contract and registers Abraham as agent #1.
 *
 * Usage:
 *   forge script script/DeploySpiritRegistry.s.sol:DeploySpiritRegistry \
 *     --rpc-url $BASE_SEPOLIA_RPC_URL \
 *     --account TESTNET_DEPLOYER \
 *     --broadcast \
 *     --verify \
 *     --etherscan-api-key $BASESCAN_API_KEY
 */
contract DeploySpiritRegistry is Script {

    /// @dev Protocol treasury (same multisig used for all Spirit deployments)
    address constant PROTOCOL_TREASURY = 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C;

    function run() external {
        vm.startBroadcast();
        (, address deployer,) = vm.readCallers();

        console.log("");
        console.log("===> DEPLOYING SPIRIT REGISTRY");
        console.log(" --- Chain ID          :   ", block.chainid);
        console.log(" --- Deployer address  :   ", deployer);
        console.log(" --- Deployer balance  :   ", deployer.balance / 1e18, "ETH");
        console.log(" --- Protocol Treasury :   ", PROTOCOL_TREASURY);

        // 1. Deploy SpiritRegistry
        SpiritRegistry registry = new SpiritRegistry(PROTOCOL_TREASURY);
        console.log("");
        console.log("===> SPIRIT REGISTRY DEPLOYED");
        console.log(" --- SpiritRegistry    :   ", address(registry));

        // 2. Register Abraham as agent #1 (reference transaction)
        address[] memory owners = new address[](1);
        owners[0] = deployer;

        uint256 abrahamId = registry.registerSpirit(
            "ipfs://QmAbraham", // placeholder URI — update after IPFS pin
            deployer,           // artist = deployer (transfer to Gene later)
            deployer,           // platform = deployer (transfer to Eden later)
            owners,             // treasury owners (ignored in MVP)
            1                   // treasury threshold (ignored in MVP)
        );

        console.log("");
        console.log("===> ABRAHAM REGISTERED");
        console.log(" --- Agent ID          :   ", abrahamId);
        console.log(" --- Owner             :   ", registry.ownerOf(abrahamId));
        console.log(" --- Has Spirit        :   ", registry.hasSpiritAttached(abrahamId));

        vm.stopBroadcast();

        console.log("");
        console.log("===> DEPLOYMENT COMPLETE");
        console.log(" --- SpiritRegistry    :   ", address(registry));
        console.log(" --- Abraham (ID #1)   :    registered");
        console.log("");
    }
}
