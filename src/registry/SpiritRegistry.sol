// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin-v5/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin-v5/contracts/token/ERC20/utils/SafeERC20.sol";

import { IERC8004IdentityRegistry } from "../interfaces/registry/IERC8004IdentityRegistry.sol";
import { ISpiritRegistry } from "../interfaces/registry/ISpiritRegistry.sol";
import { ERC8004IdentityRegistry } from "./ERC8004IdentityRegistry.sol";

/**
 * @title SpiritRegistry
 * @notice Spirit Protocol's agent registry — extends ERC-8004 Identity Registry
 *         with treasury, revenue routing, and token creation primitives.
 * @dev Implements ISpiritRegistry on top of ERC8004IdentityRegistry.
 *
 *      Integration modes:
 *      1. Native: registerSpirit() creates ERC-8004 identity + Spirit economics in one call
 *      2. Attached: attachSpirit() links an external ERC-8004 agent to Spirit economics
 */
contract SpiritRegistry is ISpiritRegistry, ERC8004IdentityRegistry {
    using SafeERC20 for IERC20;

    //      ________ __                        __
    //     / ___// //_/____  _____  __________/ /______
    //     \__ \/ __/ / ___/ / / / / ___/ __  / __/ ___/
    //    ___/ / / / / /  / /_/ / /__/ /_/ / / (__  )
    //   /____/_/ /_/_/   \__,_/\___/\__,_/_/  /____/

    /// @notice Protocol treasury address
    address public immutable override protocolTreasury;

    /// @notice Spirit config per agent
    mapping(uint256 agentId => SpiritConfig config) private _spiritConfigs;

    /// @notice Revenue config per agent
    mapping(uint256 agentId => RevenueConfig config) private _revenueConfigs;

    /// @notice Whether an agent has Spirit economics attached
    mapping(uint256 agentId => bool attached) private _spiritAttached;

    /// @notice External agent references (spiritId => ExternalAgent)
    mapping(uint256 spiritId => ExternalAgent ref) private _externalAgents;

    /// @notice NOT_TREASURY error for updateTreasury access control
    error NOT_TREASURY();

    /// @notice NOT_IMPLEMENTED error for stub functions
    error NOT_IMPLEMENTED();

    /// @notice NO_ETH_SENT error
    error NO_ETH_SENT();

    /// @notice ETH_WITH_ERC20 error
    error ETH_WITH_ERC20();

    //     ______                 __                  __
    //    / ____/___  ____  _____/ /________  _______/ /_____  _____
    //   / /   / __ \/ __ \/ ___/ __/ ___/ / / / ___/ __/ __ \/ ___/
    //  / /___/ /_/ / / / (__  ) /_/ /  / /_/ / /__/ /_/ /_/ / /
    //  \____/\____/_/ /_/____/\__/_/   \__,_/\___/\__/\____/_/

    /**
     * @param protocolTreasury_ Address of the Spirit Protocol treasury
     */
    constructor(address protocolTreasury_) ERC8004IdentityRegistry("Spirit Registry", "SPIRIT-ID") {
        protocolTreasury = protocolTreasury_;
    }

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @inheritdoc ISpiritRegistry
    function registerSpirit(
        string calldata agentURI_,
        address artist,
        address platform,
        address[] calldata, /* treasuryOwners — ignored in MVP */
        uint256 /* treasuryThreshold — ignored in MVP */
    ) external returns (uint256 agentId) {
        // Register ERC-8004 identity with artist as owner
        agentId = _register(artist, agentURI_);

        // Set agentWallet = artist (treasury) via internal call
        _setAgentWallet(agentId, artist);

        // Store Spirit config
        _spiritConfigs[agentId] = SpiritConfig({
            treasury: artist,
            childToken: address(0),
            stakingPool: address(0),
            lpPosition: address(0),
            artist: artist,
            platform: platform,
            createdAt: block.timestamp,
            hasToken: false
        });

        // Set default revenue config (25/25/25/25)
        _revenueConfigs[agentId] = RevenueConfig({
            artistBps: 2500,
            agentBps: 2500,
            platformBps: 2500,
            protocolBps: 2500
        });

        _spiritAttached[agentId] = true;

        emit SpiritRegistered(agentId, artist, artist, platform);
    }

    /// @inheritdoc ISpiritRegistry
    function attachSpirit(
        address externalRegistry,
        uint256 externalAgentId,
        address artist,
        address platform
    ) external returns (uint256 spiritId) {
        // Verify caller owns the external agent
        address externalOwner = IERC8004IdentityRegistry(externalRegistry).ownerOf(externalAgentId);
        if (externalOwner != msg.sender) revert EXTERNAL_VERIFICATION_FAILED();

        // Register a local Spirit entry for this external agent
        spiritId = _register(msg.sender, "");
        _setAgentWallet(spiritId, msg.sender);

        // Store external reference
        _externalAgents[spiritId] = ExternalAgent({
            registry: externalRegistry,
            agentId: externalAgentId
        });

        // Store Spirit config
        _spiritConfigs[spiritId] = SpiritConfig({
            treasury: msg.sender,
            childToken: address(0),
            stakingPool: address(0),
            lpPosition: address(0),
            artist: artist,
            platform: platform,
            createdAt: block.timestamp,
            hasToken: false
        });

        // Set default revenue config
        _revenueConfigs[spiritId] = RevenueConfig({
            artistBps: 2500,
            agentBps: 2500,
            platformBps: 2500,
            protocolBps: 2500
        });

        _spiritAttached[spiritId] = true;

        emit SpiritAttached(spiritId, externalRegistry, externalAgentId);
    }

    /// @inheritdoc ISpiritRegistry
    function createChildToken(
        uint256, /* agentId */
        string calldata, /* name */
        string calldata, /* symbol */
        bytes32, /* merkleRoot */
        uint160 /* initialSqrtPriceX96 */
    ) external pure {
        revert NOT_IMPLEMENTED();
    }

    /// @inheritdoc ISpiritRegistry
    function routeRevenue(uint256 agentId, address token, uint256 amount) external payable {
        if (!_spiritAttached[agentId]) revert SPIRIT_NOT_ATTACHED();

        SpiritConfig storage config = _spiritConfigs[agentId];
        RevenueConfig storage rev = _revenueConfigs[agentId];

        if (token == address(0)) {
            // ETH distribution
            if (msg.value == 0) revert NO_ETH_SENT();
            uint256 total = msg.value;
            uint256 artistAmt = (total * rev.artistBps) / 10_000;
            uint256 agentAmt = (total * rev.agentBps) / 10_000;
            uint256 platformAmt = (total * rev.platformBps) / 10_000;
            uint256 protocolAmt = total - artistAmt - agentAmt - platformAmt;

            _sendETH(config.artist, artistAmt);
            _sendETH(config.treasury, agentAmt);
            _sendETH(config.platform, platformAmt);
            _sendETH(protocolTreasury, protocolAmt);

            emit RevenueRouted(agentId, address(0), total, artistAmt, agentAmt, platformAmt, protocolAmt);
        } else {
            // ERC-20 distribution
            if (msg.value > 0) revert ETH_WITH_ERC20();
            IERC20 erc20 = IERC20(token);
            uint256 artistAmt = (amount * rev.artistBps) / 10_000;
            uint256 agentAmt = (amount * rev.agentBps) / 10_000;
            uint256 platformAmt = (amount * rev.platformBps) / 10_000;
            uint256 protocolAmt = amount - artistAmt - agentAmt - platformAmt;

            erc20.safeTransferFrom(msg.sender, config.artist, artistAmt);
            erc20.safeTransferFrom(msg.sender, config.treasury, agentAmt);
            erc20.safeTransferFrom(msg.sender, config.platform, platformAmt);
            erc20.safeTransferFrom(msg.sender, protocolTreasury, protocolAmt);

            emit RevenueRouted(agentId, token, amount, artistAmt, agentAmt, platformAmt, protocolAmt);
        }
    }

    /// @inheritdoc ISpiritRegistry
    function updateTreasury(uint256 agentId, address newTreasury) external {
        if (!_spiritAttached[agentId]) revert SPIRIT_NOT_ATTACHED();
        SpiritConfig storage config = _spiritConfigs[agentId];
        if (msg.sender != config.treasury) revert NOT_TREASURY();

        address oldTreasury = config.treasury;
        config.treasury = newTreasury;
        _setAgentWallet(agentId, newTreasury);

        emit TreasuryUpdated(agentId, oldTreasury, newTreasury);
    }

    /// @inheritdoc ISpiritRegistry
    function setRevenueConfig(uint256 agentId, RevenueConfig calldata config) external {
        _requireOwner(agentId);
        if (!_spiritAttached[agentId]) revert SPIRIT_NOT_ATTACHED();
        uint256 total = uint256(config.artistBps) + config.agentBps + config.platformBps + config.protocolBps;
        if (total != 10_000) revert INVALID_REVENUE_CONFIG();
        _revenueConfigs[agentId] = config;
    }

    //     _    ___                 ______                 __  _
    //    | |  / (_)__ _      __   / ____/_  ______  _____/ /_(_)___  ____  _____
    //    | | / / / _ \ | /| / /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //    | |/ / /  __/ |/ |/ /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //    |___/_/\___/|__/|__/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /// @notice Override to resolve ambiguity between ISpiritRegistry and ERC8004IdentityRegistry
    function ownerOf(uint256 agentId)
        public
        view
        override(ERC8004IdentityRegistry, IERC8004IdentityRegistry)
        returns (address)
    {
        return super.ownerOf(agentId);
    }

    /// @inheritdoc ISpiritRegistry
    function getSpiritConfig(uint256 agentId) external view returns (SpiritConfig memory) {
        _requireExists(agentId);
        return _spiritConfigs[agentId];
    }

    /// @inheritdoc ISpiritRegistry
    function getRevenueConfig(uint256 agentId) external view returns (RevenueConfig memory) {
        _requireExists(agentId);
        return _revenueConfigs[agentId];
    }

    /// @inheritdoc ISpiritRegistry
    function getTreasury(uint256 agentId) external view returns (address) {
        _requireExists(agentId);
        return _spiritConfigs[agentId].treasury;
    }

    /// @inheritdoc ISpiritRegistry
    function getChildToken(uint256 agentId) external view returns (address) {
        _requireExists(agentId);
        return _spiritConfigs[agentId].childToken;
    }

    /// @inheritdoc ISpiritRegistry
    function getStakingPool(uint256 agentId) external view returns (address) {
        _requireExists(agentId);
        return _spiritConfigs[agentId].stakingPool;
    }

    /// @inheritdoc ISpiritRegistry
    function hasSpiritAttached(uint256 agentId) external view returns (bool) {
        return _spiritAttached[agentId];
    }

    /// @inheritdoc ISpiritRegistry
    function getExternalAgent(uint256 spiritId) external view returns (ExternalAgent memory) {
        _requireExists(spiritId);
        return _externalAgents[spiritId];
    }

    /// @inheritdoc ISpiritRegistry
    function defaultRevenueConfig() external pure returns (RevenueConfig memory) {
        return RevenueConfig({ artistBps: 2500, agentBps: 2500, platformBps: 2500, protocolBps: 2500 });
    }

    //      ____      __                        __
    //     /  _/___  / /____  _________  ____ _/ /
    //     / // __ \/ __/ _ \/ ___/ __ \/ __ `/ /
    //   _/ // / / / /_/  __/ /  / / / / /_/ / /
    //  /___/_/ /_/\__/\___/_/  /_/ /_/\__,_/_/

    function _sendETH(address to, uint256 amount) internal {
        if (amount == 0) return;
        (bool success,) = to.call{ value: amount }("");
        require(success, "ETH_TRANSFER_FAILED");
    }
}
