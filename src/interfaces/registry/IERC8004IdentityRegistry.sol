// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IERC8004IdentityRegistry
 * @notice Standard interface from ERC-8004 (Trustless AI Agents) specification
 * @dev Reference: https://github.com/ethereum/ERCs/pull/661
 *
 * ERC-8004 defines a standard way for AI agents to have on-chain identity,
 * enabling trustless interactions between agents and protocols.
 *
 * Key concepts:
 * - agentId: NFT-based unique identifier
 * - agentURI: Points to agent registration JSON (IPFS/HTTPS)
 * - agentWallet: Agent-controlled wallet (separate from owner)
 * - metadata: On-chain key-value store
 */
interface IERC8004IdentityRegistry {

    //      ________ __                        __
    //     / ___// //_/____  _____  __________/ /______
    //     \__ \/ __/ / ___/ / / / / ___/ __  / __/ ___/
    //    ___/ / / / / /  / /_/ / /__/ /_/ / / (__  )
    //   /____/_/ /_/_/   \__,_/\___/\__,_/_/  /____/

    /// @notice Metadata entry for agent registration
    struct MetadataEntry {
        string key;
        string value;
    }

    //      ______                 __
    //     / ____/   _____  ____  / /______
    //    / __/ | | / / _ \/ __ \/ __/ ___/
    //   / /___ | |/ /  __/ / / / /_(__  )
    //  /_____/ |___/\___/_/ /_/\__/____/

    /// @notice Emitted when a new agent is registered
    event Registered(
        uint256 indexed agentId,
        string agentURI,
        address indexed owner
    );

    /// @notice Emitted when agent URI is updated
    event URIUpdated(
        uint256 indexed agentId,
        string newURI,
        address indexed updatedBy
    );

    /// @notice Emitted when agent wallet is set or changed
    event AgentWalletSet(
        uint256 indexed agentId,
        address indexed oldWallet,
        address indexed newWallet
    );

    /// @notice Emitted when metadata is set
    /// @dev Note: indexedMetadataKey is indexed for efficient filtering but limited to 32 bytes.
    ///      metadataKey contains the full key string. metadataValue is bytes to support
    ///      arbitrary data encoding (implementations may use abi.encode(string) for string values).
    event MetadataSet(
        uint256 indexed agentId,
        bytes32 indexed indexedMetadataKey,
        string metadataKey,
        string metadataValue
    );

    //     ______           __                     ______
    //    / ____/_  _______/ /_____  ____ ___     / ____/_____________  __________
    //   / /   / / / / ___/ __/ __ \/ __ `__ \   / __/ / ___/ ___/ __ \/ ___/ ___/
    //  / /___/ /_/ (__  ) /_/ /_/ / / / / / /  / /___/ /  / /  / /_/ / /  (__  )
    //  \____/\__,_/____/\__/\____/_/ /_/ /_/  /_____/_/  /_/   \____/_/  /____/

    /// @notice Agent not found
    error AGENT_NOT_FOUND();

    /// @notice Caller is not the owner
    error NOT_OWNER();

    /// @notice Invalid signature
    error INVALID_SIGNATURE();

    /// @notice Deadline expired
    error DEADLINE_EXPIRED();

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /**
     * @notice Register a new agent with URI and metadata
     * @param agentURI URI pointing to agent registration JSON
     * @param metadata Initial metadata entries
     * @return agentId The unique agent identifier (NFT ID)
     */
    function register(
        string calldata agentURI,
        MetadataEntry[] calldata metadata
    ) external returns (uint256 agentId);

    /**
     * @notice Register a new agent with only URI
     * @param agentURI URI pointing to agent registration JSON
     * @return agentId The unique agent identifier
     */
    function register(string calldata agentURI) external returns (uint256 agentId);

    /**
     * @notice Register a new agent with no URI (can be set later)
     * @return agentId The unique agent identifier
     */
    function register() external returns (uint256 agentId);

    /**
     * @notice Update the agent's URI
     * @dev Only callable by the agent owner
     * @param agentId The agent to update
     * @param newURI The new URI
     */
    function setAgentURI(uint256 agentId, string calldata newURI) external;

    /**
     * @notice Set the agent's operational wallet
     * @dev Requires EIP-712 signature from the new wallet to prevent hijacking
     * @param agentId The agent to update
     * @param newWallet The new wallet address
     * @param deadline Signature expiry timestamp
     * @param signature EIP-712 signature from newWallet
     */
    function setAgentWallet(
        uint256 agentId,
        address newWallet,
        uint256 deadline,
        bytes calldata signature
    ) external;

    /**
     * @notice Get metadata value for an agent
     * @param agentId The agent to query
     * @param key The metadata key
     * @return The metadata value
     */
    function getMetadata(uint256 agentId, string calldata key)
        external view returns (string memory);

    /**
     * @notice Set metadata for an agent
     * @dev Only callable by the agent owner
     * @param agentId The agent to update
     * @param key The metadata key
     * @param value The metadata value
     */
    function setMetadata(
        uint256 agentId,
        string calldata key,
        string calldata value
    ) external;

    /**
     * @notice Get the owner of an agent
     * @param agentId The agent to query
     * @return The owner address
     */
    function ownerOf(uint256 agentId) external view returns (address);

    /**
     * @notice Get the operational wallet of an agent
     * @param agentId The agent to query
     * @return The agent wallet address
     */
    function agentWalletOf(uint256 agentId) external view returns (address);

    /**
     * @notice Get the URI for an agent
     * @param agentId The agent to query
     * @return The agent URI
     */
    function agentURI(uint256 agentId) external view returns (string memory);

    /**
     * @notice Check if an agent exists
     * @param agentId The agent to check
     * @return True if the agent exists
     */
    function exists(uint256 agentId) external view returns (bool);
}
