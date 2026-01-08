# Spirit Protocol — Self-Service Architecture

**Created**: January 7, 2026
**Purpose**: Design doc for permissionless agent registration
**Status**: SUPERSEDED — See BACKEND_ARCHITECTURE.md

> **Note (Jan 8, 2026):** Pierre call confirmed backend-controlled approach. Contract-level permissionless registration is NOT the path forward. See `BACKEND_ARCHITECTURE.md` for the approved architecture.

---

## The Goal

Any agent builder can register their agent with Spirit Protocol without contacting the team.

```
Developer runs: npx spirit-protocol register
        ↓
Pays registration fee (ETH or SPIRIT)
        ↓
Agent token deployed, staking pool created
        ↓
Revenue routing active
```

---

## Current Barriers

| Barrier | Current State | Self-Service Solution |
|---------|---------------|----------------------|
| Admin gate | `createChild()` requires `DEFAULT_ADMIN_ROLE` | Add `registerAgent()` with fee |
| Merkle root | Pre-computed tree for airstream | Option A: Skip airstream, Option B: On-demand merkle |
| Platform allocation | Hardcoded recipient | Registry of approved platforms |
| Price initialization | Admin sets `sqrtPriceX96` | Oracle or fixed initial price |
| Gas costs | ~2M gas for full deployment | Could be 500k+ ETH at scale |

---

## Proposed Contract Changes

### Option A: Minimal Self-Service (Recommended for V1)

Add a new function to `SpiritFactory.sol`:

```solidity
// New state
uint256 public registrationFee;
mapping(address => bool) public approvedPlatforms;

// New function - permissionless
function registerAgent(
    string calldata name,
    string calldata symbol,
    address artist,
    address agent,
    address platform,  // Must be in approvedPlatforms
    int24 initialTick
) external payable returns (address childToken, address stakingPool) {
    require(msg.value >= registrationFee, "Insufficient fee");
    require(approvedPlatforms[platform], "Platform not approved");

    // No merkle root - skip airstream for self-service
    // Or use a default "open claim" merkle root

    return _createChild(
        name,
        symbol,
        artist,
        agent,
        platform,
        bytes32(0),  // No airstream or default root
        _tickToSqrtPrice(initialTick),
        0  // No special allocation
    );
}

// Admin can add platforms
function approvePlatform(address platform) external onlyRole(DEFAULT_ADMIN_ROLE) {
    approvedPlatforms[platform] = true;
}
```

**Tradeoffs:**
- ✅ Simple to implement
- ✅ Platforms still curated (prevents spam)
- ❌ No airstream for self-service agents
- ❌ Artists must trust platform selection

### Option B: Full Self-Service (V2)

```solidity
function registerAgentFull(
    string calldata name,
    string calldata symbol,
    address artist,
    address agent,
    address platform,
    bytes32 airstreamRoot,  // Caller provides
    uint256 airstreamSupply,  // Configurable
    int24 initialTick
) external payable returns (address childToken, address stakingPool) {
    require(msg.value >= registrationFee, "Insufficient fee");

    // Anyone can register, but:
    // - Platform gets 0% if not approved (goes to protocol)
    // - Or platform must be approved

    uint256 platformShare = approvedPlatforms[platform] ? PLATFORM_SHARE : 0;

    return _createChildWithConfig(
        name, symbol, artist, agent, platform,
        airstreamRoot, airstreamSupply, initialTick,
        platformShare
    );
}
```

**Tradeoffs:**
- ✅ Fully permissionless
- ✅ Caller controls airstream
- ❌ More complex
- ❌ Spam risk without curation

---

## Token Distribution for Self-Service

### Current (Admin-Created)
```
Artist:    25% (250M) - staked 52w
Agent:     20% (200M) - staked 52w
Platform:  25% (250M) - to approved platform
LP:         5% (50M)  - seeds liquidity
Airstream: 25% (250M) - merkle drop to SPIRIT holders
```

### Self-Service Option A (No Airstream)
```
Artist:    33% (333M) - staked 52w
Agent:     27% (267M) - staked 52w
Platform:  33% (333M) - to approved platform
LP:         7% (67M)  - seeds liquidity
Airstream:  0%        - skipped
```

### Self-Service Option B (Configurable)
```
Artist:    25-50% - caller chooses
Agent:     20-50% - caller chooses
Platform:  0-25%  - 0 if not approved
LP:        5-10%  - minimum enforced
Airstream: 0-25%  - caller provides merkle
```

---

## SDK Interface Design

### Installation
```bash
npm install @spirit-protocol/sdk
# or
npx spirit-protocol init
```

### Registration Flow
```javascript
import { SpiritSDK } from '@spirit-protocol/sdk';

const spirit = new SpiritSDK({
  network: 'base',  // or 'base-sepolia'
  signer: wallet    // ethers.js signer
});

// Check registration fee
const fee = await spirit.getRegistrationFee();
console.log(`Registration costs ${fee} ETH`);

// Register agent
const result = await spirit.registerAgent({
  name: 'MyAgent',
  symbol: 'MYAGENT',
  artist: '0x...',      // Artist wallet
  agent: '0x...',       // Agent wallet (can be same)
  platform: 'eden',     // or platform address
  initialPrice: 0.001,  // SPIRIT per token
});

console.log(`Token deployed: ${result.tokenAddress}`);
console.log(`Staking pool: ${result.stakingPoolAddress}`);
console.log(`View on BaseScan: ${result.explorerUrl}`);
```

### CLI Interface
```bash
# Interactive registration
npx spirit-protocol register

# With flags
npx spirit-protocol register \
  --name "MyAgent" \
  --symbol "MYAGENT" \
  --artist 0x... \
  --agent 0x... \
  --platform eden \
  --network base-sepolia

# Check status
npx spirit-protocol status MYAGENT

# View earnings
npx spirit-protocol earnings MYAGENT
```

### MCP Integration (Claude Code)
```javascript
// In Claude Code, user says: "register my agent with Spirit"

// MCP server handles:
const result = await mcp.spirit.register({
  name: context.agentName,
  symbol: context.agentSymbol,
  artist: context.userWallet,
  agent: context.agentWallet
});
```

---

## Fee Structure Options

### Option 1: Flat ETH Fee
```
Registration: 0.01 ETH (~$25)
Goes to: Protocol treasury
```

### Option 2: SPIRIT Staking Requirement
```
Must stake 10,000 SPIRIT to register
Stake returned after 90 days if agent active
Slashed if spam/abandoned
```

### Option 3: Hybrid
```
0.005 ETH + 1,000 SPIRIT burned
Lower barrier, some spam resistance
```

### Option 4: Free for Approved Platforms
```
Eden, Glif, etc. can register agents free
Self-service pays 0.01 ETH
```

---

## Implementation Phases

### Phase 1: Platform-Gated Self-Service
- Add `registerAgent()` function
- Platform must be pre-approved
- No airstream for self-service
- SDK with registration flow
- **Effort**: 1-2 weeks Pierre time

### Phase 2: Open Registration
- Any platform can register
- Unapproved platforms get 0% (goes to protocol)
- Configurable airstream
- **Effort**: 2-3 weeks

### Phase 3: Full Decentralization
- On-chain platform registry with staking
- Governance over platform approval
- Dynamic fee based on network usage
- **Effort**: 4-6 weeks

---

## Questions for Pierre

1. Is `registerAgent()` pattern compatible with current architecture?
2. Can we skip airstream for self-service agents?
3. What's the gas cost estimate for minimal registration?
4. Any Superfluid patterns for permissionless token creation?
5. Timeline estimate for Phase 1?

---

## Related Files

- `src/factory/SpiritFactory.sol` — Main factory contract
- `src/interfaces/factory/ISpiritFactory.sol` — Interface
- `docs/SPIRIT_V1_ARCHITECTURE.md` — Current architecture
- `docs/PIERRE_REPLY_DEC_15.md` — Outstanding questions

---

*Draft for Pierre call — January 7, 2026*
