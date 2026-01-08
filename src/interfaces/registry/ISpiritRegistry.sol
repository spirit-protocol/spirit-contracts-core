// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC8004IdentityRegistry} from "./IERC8004IdentityRegistry.sol";

/**
 * @title ISpiritRegistry
 * @notice Spirit Protocol's agent registry, extending ERC-8004 Identity Registry
 * @dev Adds treasury, revenue routing, and token creation to standard agent identity
 *
 * Spirit extends ERC-8004 to provide the economic layer for AI agents:
 * - Treasury: Safe multisig per agent for fund management
 * - Revenue Routing: 25/25/25/25 split (Artist/Agent/Platform/Protocol)
 * - Child Tokens: Native token with staking pool
 * - LP Positions: Uniswap V4 liquidity owned by agent
 *
 * Integration modes:
 * 1. Native: Agent registers directly with Spirit (gets ERC-8004 ID + Spirit economics)
 * 2. Attached: Existing ERC-8004 agent attaches Spirit economics
 */
interface ISpiritRegistry is IERC8004IdentityRegistry {

    //      ________ __                        __
    //     / ___// //_/____  _____  __________/ /______
    //     \__ \/ __/ / ___/ / / / / ___/ __  / __/ ___/
    //    ___/ / / / / /  / /_/ / /__/ /_/ / / (__  )
    //   /____/_/ /_/_/   \__,_/\___/\__,_/_/  /____/

    /// @notice Spirit-specific configuration for an agent
    struct SpiritConfig {
        address treasury;           // Safe multisig for agent funds
        address childToken;         // Agent's token (if created)
        address stakingPool;        // GDA staking pool
        address lpPosition;         // Uniswap V4 LP NFT
        address artist;             // Creator/trainer address
        address platform;           // Platform address (Eden, etc.)
        uint256 createdAt;          // Block timestamp
        bool hasToken;              // Whether child token exists
    }

    /// @notice Revenue routing configuration
    struct RevenueConfig {
        uint16 artistBps;           // Basis points to artist (2500 = 25%)
        uint16 agentBps;            // Basis points to agent treasury
        uint16 platformBps;         // Basis points to platform
        uint16 protocolBps;         // Basis points to Spirit treasury
    }

    /// @notice External agent reference for attached mode
    struct ExternalAgent {
        address registry;           // External ERC-8004 registry
        uint256 agentId;            // Agent ID in that registry
    }

    //      ______                 __
    //     / ____/   _____  ____  / /______
    //    / __/ | | / / _ \/ __ \/ __/ ___/
    //   / /___ | |/ /  __/ / / / /_(__  )
    //  /_____/ |___/\___/_/ /_/\__/____/

    /// @notice Emitted when a Spirit agent is registered
    event SpiritRegistered(
        uint256 indexed agentId,
        address indexed treasury,
        address indexed artist,
        address platform
    );

    /// @notice Emitted when Spirit economics are attached to external agent
    event SpiritAttached(
        uint256 indexed spiritId,
        address indexed externalRegistry,
        uint256 indexed externalAgentId
    );

    /// @notice Emitted when treasury is updated
    event TreasuryUpdated(
        uint256 indexed agentId,
        address oldTreasury,
        address newTreasury
    );

    /// @notice Emitted when child token is created
    event ChildTokenCreated(
        uint256 indexed agentId,
        address indexed childToken,
        address indexed stakingPool,
        address lpPosition
    );

    /// @notice Emitted when revenue is routed
    event RevenueRouted(
        uint256 indexed agentId,
        address indexed token,
        uint256 amount,
        uint256 artistAmount,
        uint256 agentAmount,
        uint256 platformAmount,
        uint256 protocolAmount
    );

    //     ______           __                     ______
    //    / ____/_  _______/ /_____  ____ ___     / ____/_____________  __________
    //   / /   / / / / ___/ __/ __ \/ __ `__ \   / __/ / ___/ ___/ __ \/ ___/ ___/
    //  / /___/ /_/ (__  ) /_/ /_/ / / / / / /  / /___/ /  / /  / /_/ / /  (__  )
    //  \____/\__,_/____/\__/\____/_/ /_/ /_/  /_____/_/  /_/   \____/_/  /____/

    /// @notice Spirit not attached to this agent
    error SPIRIT_NOT_ATTACHED();

    /// @notice Agent already has Spirit attached
    error SPIRIT_ALREADY_ATTACHED();

    /// @notice Agent already has a token
    error TOKEN_ALREADY_EXISTS();

    /// @notice Invalid revenue configuration (must sum to 10000 bps)
    error INVALID_REVENUE_CONFIG();

    /// @notice External registry verification failed
    error EXTERNAL_VERIFICATION_FAILED();

    /// @notice Invalid treasury configuration
    error INVALID_TREASURY_CONFIG();

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /**
     * @notice Register a Spirit agent (extends ERC-8004 register)
     * @dev Creates ERC-8004 identity + Spirit economics in one transaction.
     *
     *      Wallet/Treasury mapping:
     *      - ERC-8004's agentWallet is set to the treasury address
     *      - This means agentWalletOf(agentId) == getTreasury(agentId)
     *      - The treasury (Safe multisig) acts as the agent's operational wallet
     *      - Owner (artist) controls identity; treasury controls funds
     *
     *      Implementation MUST:
     *      - Deploy Safe multisig with treasuryOwners and treasuryThreshold
     *      - Call inherited setAgentWallet() to set agentWallet = treasury
     *      - Store Spirit-specific config (artist, platform, etc.)
     *
     * @param agentURI URI pointing to agent registration JSON
     * @param artist Address of the creator/trainer (becomes ERC-8004 owner)
     * @param platform Address of the platform
     * @param treasuryOwners Initial Safe multisig owners (must include artist and agent)
     * @param treasuryThreshold Safe threshold for transactions
     * @return agentId The ERC-8004 compatible agent ID
     */
    function registerSpirit(
        string calldata agentURI,
        address artist,
        address platform,
        address[] calldata treasuryOwners,
        uint256 treasuryThreshold
    ) external returns (uint256 agentId);

    /**
     * @notice Attach Spirit economics to existing ERC-8004 agent
     * @dev For agents already registered in another ERC-8004 registry.
     *      SECURITY: Caller must be the owner of the external agent.
     *      Implementation MUST verify ownership via:
     *      - IERC8004IdentityRegistry(externalRegistry).ownerOf(externalAgentId) == msg.sender
     *      This prevents unauthorized attachment to someone else's agent.
     * @param externalRegistry The ERC-8004 registry address (must implement IERC8004IdentityRegistry)
     * @param externalAgentId The agent's ID in that registry
     * @param artist Address of the creator/trainer
     * @param platform Address of the platform
     * @return spiritId Spirit's internal reference ID
     */
    function attachSpirit(
        address externalRegistry,
        uint256 externalAgentId,
        address artist,
        address platform
    ) external returns (uint256 spiritId);

    /**
     * @notice Create child token for an agent
     * @dev Only callable by agent owner, deploys token + staking pool + LP
     * @param agentId The agent to create token for
     * @param name Token name
     * @param symbol Token symbol
     * @param merkleRoot Merkle root for airstream
     * @param initialSqrtPriceX96 Initial price for Uniswap V4 pool
     */
    function createChildToken(
        uint256 agentId,
        string calldata name,
        string calldata symbol,
        bytes32 merkleRoot,
        uint160 initialSqrtPriceX96
    ) external;

    /**
     * @notice Route revenue to an agent's stakeholders
     * @dev Distributes according to RevenueConfig (default: 25/25/25/25)
     *
     *      ETH vs ERC-20 handling:
     *      - For ETH: token = address(0), amount is ignored, msg.value is distributed
     *      - For ERC-20: token = token address, msg.value MUST be 0, amount is transferred via transferFrom
     *
     *      Implementation MUST:
     *      - Revert if token == address(0) && msg.value == 0 (no ETH sent)
     *      - Revert if token != address(0) && msg.value > 0 (ETH sent with ERC-20)
     *      - For ERC-20: call transferFrom(msg.sender, ...) for each recipient
     *
     * @param agentId The agent receiving revenue
     * @param token The token being distributed (address(0) for ETH)
     * @param amount The amount to distribute (ignored for ETH, uses msg.value)
     */
    function routeRevenue(
        uint256 agentId,
        address token,
        uint256 amount
    ) external payable;

    /**
     * @notice Update treasury for an agent
     * @dev Only callable by current treasury via multisig
     * @param agentId The agent to update
     * @param newTreasury The new treasury address
     */
    function updateTreasury(
        uint256 agentId,
        address newTreasury
    ) external;

    /**
     * @notice Update revenue configuration for an agent
     * @dev Only callable by agent owner, must sum to 10000 bps
     * @param agentId The agent to update
     * @param config New revenue configuration
     */
    function setRevenueConfig(
        uint256 agentId,
        RevenueConfig calldata config
    ) external;

    //     _    ___                 ______                 __  _
    //    | |  / (_)__ _      __   / ____/_  ______  _____/ /_(_)___  ____  _____
    //    | | / / / _ \ | /| / /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //    | |/ / /  __/ |/ |/ /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //    |___/_/\___/|__/|__/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /**
     * @notice Get Spirit-specific configuration for an agent
     * @param agentId The agent to query
     * @return Spirit configuration
     */
    function getSpiritConfig(uint256 agentId)
        external view returns (SpiritConfig memory);

    /**
     * @notice Get revenue routing configuration
     * @param agentId The agent to query
     * @return Revenue configuration
     */
    function getRevenueConfig(uint256 agentId)
        external view returns (RevenueConfig memory);

    /**
     * @notice Get agent's treasury address
     * @param agentId The agent to query
     * @return Treasury address
     */
    function getTreasury(uint256 agentId)
        external view returns (address);

    /**
     * @notice Get agent's child token (if exists)
     * @param agentId The agent to query
     * @return Child token address (address(0) if none)
     */
    function getChildToken(uint256 agentId)
        external view returns (address);

    /**
     * @notice Get agent's staking pool (if exists)
     * @param agentId The agent to query
     * @return Staking pool address (address(0) if none)
     */
    function getStakingPool(uint256 agentId)
        external view returns (address);

    /**
     * @notice Check if agent has Spirit economics attached
     * @param agentId The agent to check
     * @return True if Spirit is attached
     */
    function hasSpiritAttached(uint256 agentId)
        external view returns (bool);

    /**
     * @notice Get external agent reference (for attached mode)
     * @param spiritId Spirit's internal ID
     * @return External agent reference
     */
    function getExternalAgent(uint256 spiritId)
        external view returns (ExternalAgent memory);

    /**
     * @notice Get Spirit Protocol treasury address
     * @return Protocol treasury address
     */
    function protocolTreasury() external view returns (address);

    /**
     * @notice Get default revenue configuration
     * @return Default revenue config (25/25/25/25)
     */
    function defaultRevenueConfig() external view returns (RevenueConfig memory);
}
