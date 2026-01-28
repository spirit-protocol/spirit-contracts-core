// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC721 } from "@openzeppelin-v5/contracts/token/ERC721/ERC721.sol";
import { ECDSA } from "@openzeppelin-v5/contracts/utils/cryptography/ECDSA.sol";
import { EIP712 } from "@openzeppelin-v5/contracts/utils/cryptography/EIP712.sol";

import { IERC8004IdentityRegistry } from "../interfaces/registry/IERC8004IdentityRegistry.sol";

/**
 * @title ERC8004IdentityRegistry
 * @notice Implementation of the ERC-8004 Identity Registry standard
 * @dev Extends ERC-721 for NFT-based agent IDs with URI, wallet, and metadata storage.
 *      Reference: https://github.com/ethereum/ERCs/pull/661
 */
contract ERC8004IdentityRegistry is IERC8004IdentityRegistry, ERC721, EIP712 {
    using ECDSA for bytes32;

    //      ________ __                        __
    //     / ___// //_/____  _____  __________/ /______
    //     \__ \/ __/ / ___/ / / / / ___/ __  / __/ ___/
    //    ___/ / / / / /  / /_/ / /__/ /_/ / / (__  )
    //   /____/_/ /_/_/   \__,_/\___/\__,_/_/  /____/

    /// @notice EIP-712 typehash for setAgentWallet signature verification
    bytes32 public constant AGENT_WALLET_TYPEHASH =
        keccak256("SetAgentWallet(uint256 agentId,address newWallet,uint256 deadline)");

    /// @notice Auto-incrementing agent ID counter (starts at 1)
    uint256 private _nextAgentId = 1;

    /// @notice Agent URI storage
    mapping(uint256 agentId => string uri) private _agentURIs;

    /// @notice Agent wallet storage
    mapping(uint256 agentId => address wallet) private _agentWallets;

    /// @notice On-chain metadata key-value store
    mapping(uint256 agentId => mapping(string key => string value)) private _metadata;

    //     ______                 __                  __
    //    / ____/___  ____  _____/ /________  _______/ /_____  _____
    //   / /   / __ \/ __ \/ ___/ __/ ___/ / / / ___/ __/ __ \/ ___/
    //  / /___/ /_/ / / / (__  ) /_/ /  / /_/ / /__/ /_/ /_/ / /
    //  \____/\____/_/ /_/____/\__/_/   \__,_/\___/\__/\____/_/

    constructor(string memory name, string memory symbol) ERC721(name, symbol) EIP712(name, "1") { }

    /// @notice Returns the EIP-712 domain separator
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @inheritdoc IERC8004IdentityRegistry
    function register(string calldata agentURI_, MetadataEntry[] calldata metadata_)
        external
        returns (uint256 agentId)
    {
        agentId = _register(msg.sender, agentURI_);
        for (uint256 i; i < metadata_.length; ++i) {
            _setMetadata(agentId, metadata_[i].key, metadata_[i].value);
        }
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function register(string calldata agentURI_) external returns (uint256 agentId) {
        agentId = _register(msg.sender, agentURI_);
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function register() external returns (uint256 agentId) {
        agentId = _register(msg.sender, "");
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function setAgentURI(uint256 agentId, string calldata newURI) external {
        _requireOwner(agentId);
        _agentURIs[agentId] = newURI;
        emit URIUpdated(agentId, newURI, msg.sender);
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function setAgentWallet(uint256 agentId, address newWallet, uint256 deadline, bytes calldata signature) external {
        _requireOwner(agentId);
        if (block.timestamp > deadline) revert DEADLINE_EXPIRED();

        bytes32 structHash = keccak256(abi.encode(AGENT_WALLET_TYPEHASH, agentId, newWallet, deadline));
        bytes32 digest = _hashTypedDataV4(structHash);
        address recovered = digest.recover(signature);
        if (recovered != newWallet) revert INVALID_SIGNATURE();

        _setAgentWallet(agentId, newWallet);
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function setMetadata(uint256 agentId, string calldata key, string calldata value) external {
        _requireOwner(agentId);
        _setMetadata(agentId, key, value);
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function getMetadata(uint256 agentId, string calldata key) external view returns (string memory) {
        _requireExists(agentId);
        return _metadata[agentId][key];
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function ownerOf(uint256 agentId) public view virtual override(ERC721, IERC8004IdentityRegistry) returns (address) {
        return super.ownerOf(agentId);
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function agentWalletOf(uint256 agentId) external view returns (address) {
        _requireExists(agentId);
        return _agentWallets[agentId];
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function agentURI(uint256 agentId) external view returns (string memory) {
        _requireExists(agentId);
        return _agentURIs[agentId];
    }

    /// @inheritdoc IERC8004IdentityRegistry
    function exists(uint256 agentId) external view returns (bool) {
        return _ownerOf(agentId) != address(0);
    }

    //      ____      __                        __   ______                 __  _
    //     /  _/___  / /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //     / // __ \/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   _/ // / / / /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /___/_/ /_/\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /**
     * @notice Internal registration logic
     * @param owner_ The address that will own the agent NFT
     * @param agentURI_ Initial URI for the agent
     * @return agentId The newly minted agent ID
     */
    function _register(address owner_, string memory agentURI_) internal returns (uint256 agentId) {
        agentId = _nextAgentId++;
        _mint(owner_, agentId);
        if (bytes(agentURI_).length > 0) {
            _agentURIs[agentId] = agentURI_;
        }
        emit Registered(agentId, agentURI_, owner_);
    }

    /**
     * @notice Internal agent wallet setter (no signature required)
     * @param agentId The agent to update
     * @param newWallet The new wallet address
     */
    function _setAgentWallet(uint256 agentId, address newWallet) internal {
        address oldWallet = _agentWallets[agentId];
        _agentWallets[agentId] = newWallet;
        emit AgentWalletSet(agentId, oldWallet, newWallet);
    }

    /**
     * @notice Internal metadata setter
     * @param agentId The agent to update
     * @param key Metadata key
     * @param value Metadata value
     */
    function _setMetadata(uint256 agentId, string memory key, string memory value) internal {
        _metadata[agentId][key] = value;
        emit MetadataSet(agentId, keccak256(bytes(key)), key, value);
    }

    /**
     * @notice Require that agentId exists
     */
    function _requireExists(uint256 agentId) internal view {
        if (_ownerOf(agentId) == address(0)) revert AGENT_NOT_FOUND();
    }

    /**
     * @notice Require that msg.sender is the owner of agentId
     */
    function _requireOwner(uint256 agentId) internal view {
        if (ownerOf(agentId) != msg.sender) revert NOT_OWNER();
    }
}
