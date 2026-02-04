// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SpiritRegistry } from "src/registry/SpiritRegistry.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

/**
 * @title RegisterGenesisAgents
 * @notice Registers Abraham (#2) and Solienne (#3) on the deployed SpiritRegistry.
 *
 * Abraham #1 was a deployment-time test registration with placeholder data.
 * This script re-registers Abraham properly as #2 and adds Solienne as #3,
 * both pointing to hosted metadata on spiritprotocol.io.
 *
 * Usage:
 *   forge script script/RegisterGenesisAgents.s.sol:RegisterGenesisAgents \
 *     --rpc-url https://mainnet.base.org \
 *     --account MAINNET_DEPLOYER \
 *     --broadcast
 */
contract RegisterGenesisAgents is Script {
    /// @dev Deployed SpiritRegistry on Base Mainnet
    address constant REGISTRY = 0xF2709ceF1Cf4893ed78D3220864428b32b12dFb9;

    /// @dev Deployer wallet — used as artist/platform placeholder.
    ///      Transfer ownership to real wallets (Gene, Kristi, Eden) later.
    address constant DEPLOYER = 0x2fC0f360160fAA281420B3f2F0e13767B4789CEe;

    function run() external {
        vm.startBroadcast();

        SpiritRegistry registry = SpiritRegistry(REGISTRY);

        // Shared treasury config (ignored in MVP)
        address[] memory owners = new address[](1);
        owners[0] = DEPLOYER;

        // ── Abraham (#2) ────────────────────────────────────────────
        uint256 abrahamId = registry.registerSpirit(
            "https://spiritprotocol.io/agents/abraham/metadata.json",
            DEPLOYER, // artist  (testnet placeholder — Gene Kogan)
            DEPLOYER, // platform (testnet placeholder — Eden)
            owners,
            1
        );

        console.log("");
        console.log("===> ABRAHAM REGISTERED");
        console.log(" --- Agent ID          :   ", abrahamId);
        console.log(" --- Owner             :   ", registry.ownerOf(abrahamId));
        console.log(" --- Has Spirit        :   ", registry.hasSpiritAttached(abrahamId));

        // ── Solienne (#3) ───────────────────────────────────────────
        uint256 solenneId = registry.registerSpirit(
            "https://spiritprotocol.io/agents/solienne/metadata.json",
            DEPLOYER, // artist  (testnet placeholder — Kristi Coronado)
            DEPLOYER, // platform (testnet placeholder — Eden)
            owners,
            1
        );

        console.log("");
        console.log("===> SOLIENNE REGISTERED");
        console.log(" --- Agent ID          :   ", solenneId);
        console.log(" --- Owner             :   ", registry.ownerOf(solenneId));
        console.log(" --- Has Spirit        :   ", registry.hasSpiritAttached(solenneId));

        vm.stopBroadcast();

        console.log("");
        console.log("===> GENESIS AGENTS REGISTERED");
        console.log(" --- Abraham  (ID #", abrahamId, ")");
        console.log(" --- Solienne (ID #", solenneId, ")");
        console.log("");
    }
}
