// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SpiritRegistry } from "src/registry/SpiritRegistry.sol";
import { DailyPractice } from "src/practice/DailyPractice.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

/**
 * @title RegisterGenesisCohort2
 * @notice Batch-registers Genesis 10 agents (cohort 2) on SpiritRegistry
 *         and authorizes operator wallets on DailyPractice.
 *
 * Cohort 1 (already registered):
 *   - Abraham (#2), Solienne (#3)
 *
 * Cohort 2 (this script):
 *   - Ganchitecture, Divinity, Johnny Rico, + up to 7 more
 *
 * Post-registration:
 *   - Transfers ownership from deployer to each artist's wallet
 *   - Authorizes operator wallets for daily practice submission
 *
 * Usage:
 *   # Dry run (no broadcast):
 *   forge script script/RegisterGenesisCohort2.s.sol:RegisterGenesisCohort2 \
 *     --rpc-url https://mainnet.base.org
 *
 *   # Live broadcast:
 *   forge script script/RegisterGenesisCohort2.s.sol:RegisterGenesisCohort2 \
 *     --rpc-url https://mainnet.base.org \
 *     --account MAINNET_DEPLOYER \
 *     --broadcast
 */
contract RegisterGenesisCohort2 is Script {
    /// @dev Deployed contracts on Base Mainnet
    address constant REGISTRY = 0xF2709ceF1Cf4893ed78D3220864428b32b12dFb9;
    address constant DAILY_PRACTICE = 0x8d8cd4a00695E3775268d446e8ea632305869b5F;

    /// @dev Deployer wallet — registers agents, then transfers ownership
    address constant DEPLOYER = 0x2fC0f360160fAA281420B3f2F0e13767B4789CEe;

    /// @dev Protocol Treasury
    address constant TREASURY = 0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C;

    // ── Agent Configuration ──────────────────────────────────────────────
    // Fill in artist wallets and operator addresses as artists confirm.
    // Wallet address(0) means "use deployer as placeholder, transfer later".

    struct GenesisAgent {
        string name;
        string metadataURI;
        address artistWallet;   // Artist's Base wallet (receives ownership)
        address operatorWallet; // Operator authorized for daily practice submission
    }

    function _getAgents() internal pure returns (GenesisAgent[] memory) {
        GenesisAgent[] memory agents = new GenesisAgent[](7);

        // ── Slot 0: Ganchitecture ────────────────────────────────────────
        agents[0] = GenesisAgent({
            name: "Ganchitecture",
            metadataURI: "https://spiritprotocol.io/agents/ganchitecture/metadata.json",
            artistWallet: address(0), // TODO: Samer Dabra wallet
            operatorWallet: address(0) // TODO: operator for daily submission
        });

        // ── Slot 1: Divinity ─────────────────────────────────────────────
        agents[1] = GenesisAgent({
            name: "Divinity",
            metadataURI: "https://spiritprotocol.io/agents/divinity/metadata.json",
            artistWallet: address(0), // TODO: Mikey Woodbridge wallet
            operatorWallet: address(0)
        });

        // ── Slot 2: Johnny Rico ──────────────────────────────────────────
        agents[2] = GenesisAgent({
            name: "Johnny Rico",
            metadataURI: "https://spiritprotocol.io/agents/johnny-rico/metadata.json",
            artistWallet: address(0), // TODO: eko33 wallet
            operatorWallet: address(0)
        });

        // ── Slot 3: TBD ─────────────────────────────────────────────────
        agents[3] = GenesisAgent({
            name: "TBD_4",
            metadataURI: "",
            artistWallet: address(0),
            operatorWallet: address(0)
        });

        // ── Slot 4: TBD ─────────────────────────────────────────────────
        agents[4] = GenesisAgent({
            name: "TBD_5",
            metadataURI: "",
            artistWallet: address(0),
            operatorWallet: address(0)
        });

        // ── Slot 5: TBD ─────────────────────────────────────────────────
        agents[5] = GenesisAgent({
            name: "TBD_6",
            metadataURI: "",
            artistWallet: address(0),
            operatorWallet: address(0)
        });

        // ── Slot 6: TBD ─────────────────────────────────────────────────
        agents[6] = GenesisAgent({
            name: "TBD_7",
            metadataURI: "",
            artistWallet: address(0),
            operatorWallet: address(0)
        });

        return agents;
    }

    function run() external {
        vm.startBroadcast();

        SpiritRegistry registry = SpiritRegistry(REGISTRY);
        DailyPractice practice = DailyPractice(DAILY_PRACTICE);

        GenesisAgent[] memory agents = _getAgents();

        // Shared treasury config (ignored in MVP)
        address[] memory owners = new address[](1);
        owners[0] = DEPLOYER;

        uint256 registered = 0;

        for (uint256 i = 0; i < agents.length; i++) {
            // Skip agents not yet configured
            if (bytes(agents[i].metadataURI).length == 0) {
                console.log("Skipping unconfigured slot:", agents[i].name);
                continue;
            }

            // Use deployer as placeholder if artist wallet not yet provided
            address artist = agents[i].artistWallet == address(0)
                ? DEPLOYER
                : agents[i].artistWallet;

            // Register on SpiritRegistry
            uint256 agentId = registry.registerSpirit(
                agents[i].metadataURI,
                artist,     // artist
                DEPLOYER,   // platform (placeholder)
                owners,
                1
            );

            console.log("");
            console.log("===>", agents[i].name, "REGISTERED");
            console.log(" --- Agent ID          :   ", agentId);
            console.log(" --- Owner             :   ", registry.ownerOf(agentId));

            // Transfer ownership to artist wallet if provided
            if (agents[i].artistWallet != address(0) && agents[i].artistWallet != DEPLOYER) {
                registry.transferFrom(DEPLOYER, agents[i].artistWallet, agentId);
                console.log(" --- Transferred to    :   ", agents[i].artistWallet);
            }

            // Authorize operator for daily practice if provided
            if (agents[i].operatorWallet != address(0)) {
                practice.authorizeOperator(agentId, agents[i].operatorWallet);
                console.log(" --- Operator authorized:  ", agents[i].operatorWallet);
            }

            registered++;
        }

        vm.stopBroadcast();

        console.log("");
        console.log("===> GENESIS COHORT 2 COMPLETE");
        console.log(" --- Registered:", registered, "agents");
        console.log("");
    }
}
