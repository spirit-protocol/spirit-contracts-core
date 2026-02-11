// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* Local imports */
import { DailyPractice } from "src/practice/DailyPractice.sol";
import { PracticeCuration } from "src/practice/PracticeCuration.sol";

/* Foundry imports */
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

/**
 * @title DeployDailyPractice
 * @notice Deploys DailyPractice and PracticeCuration contracts.
 *         Requires an existing SpiritRegistry deployment.
 *
 * Usage:
 *   REGISTRY=0x... forge script script/DeployDailyPractice.s.sol:DeployDailyPractice \
 *     --rpc-url $BASE_SEPOLIA_RPC_URL \
 *     --account TESTNET_DEPLOYER \
 *     --broadcast \
 *     --verify \
 *     --etherscan-api-key $BASESCAN_API_KEY
 */
contract DeployDailyPractice is Script {

    function run() external {
        address registryAddr = vm.envAddress("REGISTRY");

        vm.startBroadcast();
        (, address deployer,) = vm.readCallers();

        console.log("");
        console.log("===> DEPLOYING DAILY PRACTICE");
        console.log(" --- Chain ID          :   ", block.chainid);
        console.log(" --- Deployer          :   ", deployer);
        console.log(" --- Deployer balance  :   ", deployer.balance / 1e18, "ETH");
        console.log(" --- SpiritRegistry    :   ", registryAddr);

        // 1. Deploy DailyPractice (shared across all agents)
        DailyPractice practice = new DailyPractice(registryAddr);
        console.log("");
        console.log("===> DAILY PRACTICE DEPLOYED");
        console.log(" --- DailyPractice     :   ", address(practice));

        // 2. Deploy PracticeCuration (voting on submissions)
        PracticeCuration curation = new PracticeCuration(address(practice));
        console.log("");
        console.log("===> PRACTICE CURATION DEPLOYED");
        console.log(" --- PracticeCuration  :   ", address(curation));

        vm.stopBroadcast();

        console.log("");
        console.log("===> DEPLOYMENT COMPLETE");
        console.log(" --- DailyPractice     :   ", address(practice));
        console.log(" --- PracticeCuration  :   ", address(curation));
        console.log(" --- SpiritRegistry    :   ", registryAddr);
        console.log("");
        console.log("Next steps:");
        console.log("  1. Update Spirit Index chain.ts with contract addresses");
        console.log("  2. Register agents via SpiritRegistry.registerSpirit()");
        console.log("  3. Start daily practice submissions via DailyPractice.submitPractice()");
        console.log("");
    }
}
