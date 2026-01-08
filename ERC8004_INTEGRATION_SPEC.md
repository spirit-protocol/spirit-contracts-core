# Spirit Protocol — ERC-8004 Integration Spec

**Created:** January 8, 2026
**Status:** DRAFT — Needs team review
**Authors:** Seth, Claude
**ERC-8004 Status:** Draft (v1, Oct 2025)

---

## Executive Summary

ERC-8004 is emerging as the Ethereum standard for trustless AI agents. Spirit Protocol should **extend** ERC-8004 rather than compete with it. This positions Spirit as the **economic layer** for any ERC-8004-compatible agent.

**One sentence:** Spirit adds treasury, revenue routing, and tokens to ERC-8004 identity.

---

## 1. ERC-8004 Overview

### What ERC-8004 Provides

| Registry | Purpose | Key Functions |
|----------|---------|---------------|
| **Identity** | NFT-based agent ID | `register()`, `setAgentWallet()`, `setMetadata()` |
| **Reputation** | On-chain feedback | `giveFeedback()`, `getSummary()` |
| **Validation** | Output verification | `validationRequest()`, `validationResponse()` |

### Key Concepts

```
Agent Identifier Format:
{namespace}:{chainId}:{identityRegistry}:{agentId}

Example:
erc8004:8453:0x1234...5678:42
```

- **Agent URI** — Points to registration JSON (IPFS or HTTPS)
- **Agent Wallet** — Separate from owner, requires signature to set
- **Metadata** — On-chain key-value store
- **Endpoints** — A2A, MCP, custom protocols

### Backers

- MetaMask (Marco De Rossi)
- Ethereum Foundation (Davide Crapis)
- Google (Jordan Ellis)
- Coinbase (Erik Reppel)
- ENS, EigenLayer, The Graph, Taiko

---

## 2. Integration Strategy

### Decision: Spirit EXTENDS ERC-8004

```
┌─────────────────────────────────────────────────────────────┐
│                     ERC-8004 LAYER                          │
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │  Identity   │  │ Reputation  │  │ Validation  │        │
│   │  Registry   │  │  Registry   │  │  Registry   │        │
│   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│          │                │                │                │
└──────────┼────────────────┼────────────────┼────────────────┘
           │                │                │
           ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                    SPIRIT LAYER                             │
│                                                             │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│   │  Treasury   │  │   Revenue   │  │   Token     │        │
│   │  (Safe)     │  │   Router    │  │  Factory    │        │
│   └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│   What Spirit Adds:                                         │
│   • Treasury multisig per agent                             │
│   • 25/25/25/25 revenue routing                            │
│   • Child token with staking pool                          │
│   • LP position owned by agent                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Extend (Not Replace)

1. **Network effects** — ERC-8004 has major backers, will be widely adopted
2. **Separation of concerns** — Identity ≠ Economics
3. **Composability** — Any ERC-8004 agent can add Spirit economics
4. **Legitimacy** — Aligning with standards signals maturity

---

## 3. Interface Design

### 3.1 SpiritRegistry (Extends ERC-8004)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC8004IdentityRegistry} from "./IERC8004IdentityRegistry.sol";

/**
 * @title ISpiritRegistry
 * @notice Spirit Protocol's agent registry, extending ERC-8004 Identity Registry
 * @dev Adds treasury, revenue routing, and token creation to standard agent identity
 */
interface ISpiritRegistry is IERC8004IdentityRegistry {

    // ============================================
    // Spirit-Specific Structs
    // ============================================

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

    struct RevenueConfig {
        uint16 artistBps;           // Basis points to artist (2500 = 25%)
        uint16 agentBps;            // Basis points to agent treasury
        uint16 platformBps;         // Basis points to platform
        uint16 protocolBps;         // Basis points to Spirit treasury
    }

    // ============================================
    // Spirit-Specific Events
    // ============================================

    event SpiritRegistered(
        uint256 indexed agentId,
        address indexed treasury,
        address indexed artist,
        address platform
    );

    event TreasuryUpdated(
        uint256 indexed agentId,
        address oldTreasury,
        address newTreasury
    );

    event ChildTokenCreated(
        uint256 indexed agentId,
        address indexed childToken,
        address indexed stakingPool,
        address lpPosition
    );

    event RevenueRouted(
        uint256 indexed agentId,
        address indexed token,
        uint256 amount,
        uint256 artistAmount,
        uint256 agentAmount,
        uint256 platformAmount,
        uint256 protocolAmount
    );

    // ============================================
    // Spirit-Specific Functions
    // ============================================

    /**
     * @notice Register a Spirit agent (extends ERC-8004 register)
     * @param agentURI URI pointing to agent registration JSON
     * @param artist Address of the creator/trainer
     * @param platform Address of the platform
     * @param treasuryOwners Initial Safe multisig owners
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
     * @dev For agents already registered in another ERC-8004 registry
     * @param externalRegistry The ERC-8004 registry address
     * @param externalAgentId The agent's ID in that registry
     * @param artist Address of the creator/trainer
     * @param platform Address of the platform
     */
    function attachSpirit(
        address externalRegistry,
        uint256 externalAgentId,
        address artist,
        address platform
    ) external returns (uint256 spiritId);

    /**
     * @notice Get Spirit-specific configuration for an agent
     */
    function getSpiritConfig(uint256 agentId)
        external view returns (SpiritConfig memory);

    /**
     * @notice Get revenue routing configuration
     */
    function getRevenueConfig(uint256 agentId)
        external view returns (RevenueConfig memory);

    /**
     * @notice Get agent's treasury address
     */
    function getTreasury(uint256 agentId)
        external view returns (address);

    /**
     * @notice Get agent's child token (if exists)
     */
    function getChildToken(uint256 agentId)
        external view returns (address);

    /**
     * @notice Check if agent has Spirit economics attached
     */
    function hasSpiritAttached(uint256 agentId)
        external view returns (bool);

    /**
     * @notice Route revenue to an agent's stakeholders
     * @param agentId The agent receiving revenue
     * @param token The token being distributed (address(0) for ETH)
     * @param amount The amount to distribute
     */
    function routeRevenue(
        uint256 agentId,
        address token,
        uint256 amount
    ) external payable;

    // ============================================
    // ERC-8004 Standard Functions (inherited)
    // ============================================

    // function register(string calldata agentURI) external returns (uint256);
    // function setAgentURI(uint256 agentId, string calldata newURI) external;
    // function setAgentWallet(uint256 agentId, address wallet, uint256 deadline, bytes signature) external;
    // function setMetadata(uint256 agentId, string key, string value) external;
    // function getMetadata(uint256 agentId, string key) external view returns (string);
}
```

### 3.2 ERC-8004 Identity Registry Interface (Reference)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC8004IdentityRegistry
 * @notice Standard interface from ERC-8004 spec
 */
interface IERC8004IdentityRegistry {

    struct MetadataEntry {
        string key;
        string value;
    }

    event Registered(
        uint256 indexed agentId,
        string agentURI,
        address indexed owner
    );

    event URIUpdated(
        uint256 indexed agentId,
        string newURI,
        address indexed updatedBy
    );

    event MetadataSet(
        uint256 indexed agentId,
        string indexed indexedMetadataKey,
        string metadataKey,
        bytes metadataValue
    );

    function register(
        string calldata agentURI,
        MetadataEntry[] calldata metadata
    ) external returns (uint256 agentId);

    function register(string calldata agentURI) external returns (uint256 agentId);

    function register() external returns (uint256 agentId);

    function setAgentURI(uint256 agentId, string calldata newURI) external;

    function setAgentWallet(
        uint256 agentId,
        address newWallet,
        uint256 deadline,
        bytes calldata signature
    ) external;

    function getMetadata(uint256 agentId, string calldata key)
        external view returns (string memory);

    function setMetadata(
        uint256 agentId,
        string calldata key,
        string calldata value
    ) external;

    function ownerOf(uint256 agentId) external view returns (address);

    function agentWalletOf(uint256 agentId) external view returns (address);
}
```

---

## 4. Component Mapping

### 4.1 Identity Registry Mapping

| ERC-8004 Concept | Spirit Implementation | Notes |
|------------------|----------------------|-------|
| `agentId` (NFT) | Same | Spirit extends, same ID space |
| `agentURI` | Same | Points to agent registration JSON |
| `agentWallet` | `treasury` | Spirit uses Safe multisig |
| `owner` | `artist` | Creator who trained the agent |
| `metadata` | Extended | Add Spirit-specific keys |

### 4.2 Spirit Metadata Keys

Reserved metadata keys for Spirit-registered agents:

```json
{
  "spirit:treasury": "0x...",
  "spirit:childToken": "0x...",
  "spirit:stakingPool": "0x...",
  "spirit:lpPosition": "0x...",
  "spirit:platform": "0x...",
  "spirit:revenueConfigHash": "0x...",
  "spirit:version": "1.0.0"
}
```

### 4.3 Agent Registration JSON Extension

Standard ERC-8004 registration JSON with Spirit extensions:

```json
{
  "$schema": "https://8004.org/schemas/agent-registration.json",
  "name": "Abraham",
  "description": "Autonomous AI artist with 13-year covenant",
  "image": "ipfs://Qm...",
  "endpoints": [
    {
      "protocol": "a2a",
      "url": "https://abraham.eden.art/.well-known/a2a"
    },
    {
      "protocol": "mcp",
      "url": "https://abraham.eden.art/mcp"
    }
  ],
  "trustModels": ["reputation", "spirit-staking"],

  "spirit": {
    "version": "1.0.0",
    "treasury": "0x...",
    "childToken": {
      "address": "0x...",
      "symbol": "ABRAHAM",
      "name": "Abraham Token"
    },
    "stakingPool": "0x...",
    "platform": {
      "name": "Eden",
      "address": "0x..."
    },
    "revenueConfig": {
      "artist": 2500,
      "agent": 2500,
      "platform": 2500,
      "protocol": 2500
    },
    "covenant": {
      "duration": "13 years",
      "startDate": "2025-10-01",
      "terms": "ipfs://Qm..."
    }
  }
}
```

---

## 5. Reputation Integration

### 5.1 Using ERC-8004 Reputation Registry

Spirit can leverage the standard reputation registry:

```solidity
interface ISpiritReputationIntegration {
    /**
     * @notice Record feedback for an agent via ERC-8004
     * @dev Wraps IERC8004ReputationRegistry.giveFeedback
     */
    function recordAgentFeedback(
        uint256 agentId,
        uint8 score,          // 0-100
        string calldata tag,  // e.g., "art-quality", "response-time"
        string calldata feedbackURI
    ) external;

    /**
     * @notice Get agent's reputation summary
     */
    function getAgentReputation(uint256 agentId)
        external view returns (uint64 feedbackCount, uint8 averageScore);
}
```

### 5.2 Reputation-Weighted Revenue (Future)

Potential future enhancement — reputation affects revenue:

```
Base split: 25/25/25/25

With reputation modifier:
- High reputation (90+): Agent gets bonus from protocol share
- Low reputation (<50): Portion held in escrow

Example:
- Artist: 25%
- Agent: 25% + 5% reputation bonus = 30%
- Platform: 25%
- Protocol: 25% - 5% = 20%
```

**Status:** NOT IMPLEMENTED — Requires governance discussion.

---

## 6. Validation Integration

### 6.1 Validation for Revenue Claims

ERC-8004 validation can verify agent work before revenue distribution:

```solidity
interface ISpiritValidation {
    /**
     * @notice Request validation before large revenue distribution
     * @dev For amounts above threshold, require validator approval
     */
    function requestRevenueValidation(
        uint256 agentId,
        address validator,
        uint256 amount,
        bytes32 workHash  // Hash of the work generating revenue
    ) external returns (bytes32 requestHash);

    /**
     * @notice Check if revenue claim is validated
     */
    function isRevenueValidated(bytes32 requestHash)
        external view returns (bool);
}
```

### 6.2 Validation Use Cases

| Use Case | Validator Type | Threshold |
|----------|---------------|-----------|
| Art authenticity | Trusted curator | >$1000 |
| Service delivery | Client signature | >$500 |
| Automated work | TEE/zkML | Any |

**Status:** FUTURE PHASE — Not required for TGE.

---

## 7. Migration Path

### 7.1 Existing Spirit Agents

For agents registered before ERC-8004 integration:

```solidity
/**
 * @notice Migrate existing Spirit agent to ERC-8004 compatible format
 * @param legacyAgentId ID in old SpiritRegistry
 * @return newAgentId ERC-8004 compatible ID
 */
function migrateToERC8004(uint256 legacyAgentId)
    external returns (uint256 newAgentId);
```

Migration steps:
1. Read legacy agent data
2. Create ERC-8004 registration JSON
3. Upload to IPFS
4. Register in new SpiritRegistry (ERC-8004 compliant)
5. Link treasury, token, staking pool
6. Mark legacy entry as migrated

### 7.2 External ERC-8004 Agents

For agents registered elsewhere wanting Spirit economics:

```solidity
/**
 * @notice Attach Spirit economics to external ERC-8004 agent
 */
function attachSpirit(
    address externalRegistry,      // Their ERC-8004 registry
    uint256 externalAgentId,       // Their agent ID
    address artist,
    address platform
) external returns (uint256 spiritId);
```

This creates a Spirit entry that **references** the external identity rather than duplicating it.

---

## 8. Implementation Phases

### Phase 1: Core Integration (TGE)

- [ ] Implement `IERC8004IdentityRegistry` interface in SpiritRegistry
- [ ] Add Spirit-specific extensions
- [ ] Update `createChild` to use ERC-8004 agent IDs
- [ ] Publish agent registration JSON schema
- [ ] Update SDK with ERC-8004 types

### Phase 2: Reputation (Q2 2026)

- [ ] Deploy or integrate with ERC-8004 Reputation Registry
- [ ] Add `recordAgentFeedback` wrapper
- [ ] Build reputation dashboard
- [ ] Consider reputation-weighted revenue

### Phase 3: Validation (Q3 2026)

- [ ] Integrate ERC-8004 Validation Registry
- [ ] Define Spirit-specific validators
- [ ] Implement validation-gated revenue

### Phase 4: Cross-Registry (Q4 2026)

- [ ] Support `attachSpirit` for external agents
- [ ] Multi-chain identity linking
- [ ] Cross-registry reputation aggregation

---

## 9. Open Questions

### For Pierre (Superfluid)

1. Does Superfluid have any ERC-8004 integration plans?
2. Can airstreams reference ERC-8004 agent IDs directly?
3. Any concerns with reputation-weighted distributions?

### For Gene/Xander (Eden)

1. Should Eden deploy its own ERC-8004 Identity Registry or use shared?
2. How do Eden agent profiles map to ERC-8004 registration JSON?
3. Curator validation for art quality — interested?

### For Aaron (Legal)

1. Does ERC-8004 compliance affect securities analysis?
2. Reputation scores as financial signals — any concerns?
3. Cross-registry identity linking and liability

### For Team

1. Deploy own ERC-8004 registries or use canonical deployments?
2. Timeline for Phase 1 integration?
3. Minimum viable ERC-8004 for TGE vs full integration?

---

## 10. Contract Deployment Plan

### Option A: Spirit Deploys All Registries

```
Spirit Identity Registry (extends ERC-8004)  ← Deploy
Spirit Reputation Registry (implements ERC-8004) ← Deploy
Spirit Validation Registry (implements ERC-8004) ← Deploy
Spirit Factory (uses Identity Registry)
Spirit Router (uses all registries)
```

**Pros:** Full control, Spirit-specific optimizations
**Cons:** Fragmented ecosystem, less composability

### Option B: Use Canonical + Spirit Extensions

```
Canonical ERC-8004 Identity Registry ← Use existing
Canonical ERC-8004 Reputation Registry ← Use existing
Canonical ERC-8004 Validation Registry ← Use existing
Spirit Extension Contract (links to canonical + adds economics)
Spirit Factory (references Spirit Extension)
```

**Pros:** Maximum composability, ecosystem alignment
**Cons:** Dependency on external contracts

### Recommendation: Option B

Use canonical ERC-8004 registries when available on Base. Spirit Extension contract adds treasury, revenue routing, and token layer.

---

## 11. SDK Updates

### Current SDK

```typescript
const spirit = new SpiritClient({ chainId: 84532 });

await spirit.registerAgent({
  spiritId: 'abraham',
  trainer: '0x...',
  platform: '0x...',
  treasury: '0x...',
  metadataURI: 'ipfs://...'
});
```

### Updated SDK (ERC-8004)

```typescript
const spirit = new SpiritClient({ chainId: 84532 });

// Register with ERC-8004 compliance
const agentId = await spirit.registerAgent({
  // ERC-8004 standard fields
  agentURI: 'ipfs://Qm.../agent-registration.json',
  metadata: [
    { key: 'name', value: 'Abraham' },
    { key: 'spirit:platform', value: '0xEden...' }
  ],

  // Spirit extensions
  artist: '0x...',
  platform: '0x...',
  treasuryOwners: ['0x...', '0x...'],
  treasuryThreshold: 2
});

// Attach Spirit to existing ERC-8004 agent
const spiritId = await spirit.attachToAgent({
  externalRegistry: '0x...',  // Their ERC-8004 registry
  externalAgentId: 42,
  artist: '0x...',
  platform: '0x...'
});

// Get ERC-8004 + Spirit combined data
const agent = await spirit.getAgent(agentId);
// Returns: { erc8004: {...}, spirit: { treasury, childToken, ... } }
```

---

## 12. References

- [ERC-8004 EIP](https://eips.ethereum.org/EIPS/eip-8004)
- [ERC-8004.org](https://8004.org/)
- [ERC-8004 Discussion](https://ethereum-magicians.org/t/erc-8004-trustless-agents/25098)
- [x402 Protocol](https://x402.superfluid.org/)
- [Spirit Source of Truth](./SPIRIT_SOURCE_OF_TRUTH.md)
- [Spirit Backend Architecture](./BACKEND_ARCHITECTURE.md)

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| Jan 8, 2026 | Initial draft | Seth, Claude |

---

*Spirit Protocol: Economic infrastructure for ERC-8004 agents.*
