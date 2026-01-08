# Spirit Protocol — Backend Architecture

**Created:** January 8, 2026
**Source:** Pierre call decisions
**Status:** APPROVED ARCHITECTURE

---

## Overview

The self-service layer for Spirit Protocol is **backend-controlled**, not permissionless contracts.

**Why:**
- Can't verify merkle root correctness onchain
- Can't verify sqrtPriceX96 correctness onchain
- Permissionless contracts = attack surface
- Backend validates everything before calling contract

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     AGENT (Caller)                            │
│   Wants to create a child token for their autonomous agent    │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ▼ x402 API call (pays via streaming)
┌──────────────────────────────────────────────────────────────┐
│                   SPIRIT BACKEND SERVICE                      │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐  │
│  │ Snapshot Service│  │ Merkle Service  │  │ Price Service│  │
│  │                 │  │                 │  │              │  │
│  │ Query Spirit    │  │ Generate tree   │  │ Fetch Spirit │  │
│  │ holders at      │  │ from snapshot   │  │ FDV, compute │  │
│  │ block height    │  │ Return root     │  │ sqrtPriceX96 │  │
│  └────────┬────────┘  └────────┬────────┘  └──────┬───────┘  │
│           │                    │                   │          │
│           └────────────────────┼───────────────────┘          │
│                                ▼                              │
│                    ┌───────────────────────┐                  │
│                    │   Validation Layer    │                  │
│                    │ - Rate limiting       │                  │
│                    │ - Anti-spam           │                  │
│                    │ - Parameter sanity    │                  │
│                    │ - Platform approval   │                  │
│                    └───────────┬───────────┘                  │
└────────────────────────────────┼─────────────────────────────┘
                                 │
                                 ▼ Admin-signed transaction
┌──────────────────────────────────────────────────────────────┐
│               SPIRIT FACTORY CONTRACT (Base)                  │
│                                                               │
│   createChild(name, symbol, artist, agent, platform,         │
│               merkleRoot, sqrtPriceX96, ...)                 │
│                                                               │
│   Requires: DEFAULT_ADMIN_ROLE                               │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                  PER-AGENT INFRASTRUCTURE                     │
│                                                               │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐         │
│   │ ChildToken   │ │ StakingPool  │ │ Uniswap V4   │         │
│   │ (1B supply)  │ │ (GDA)        │ │ Pool         │         │
│   └──────────────┘ └──────────────┘ └──────────────┘         │
│                                                               │
│   ┌──────────────┐                                           │
│   │ Airstream    │ ← merkle root enables claiming            │
│   │ (52w vest)   │                                           │
│   └──────────────┘                                           │
└──────────────────────────────────────────────────────────────┘
```

---

## Backend Services

### 1. Snapshot Service

**Purpose:** Capture Spirit holder balances at child creation time.

**Implementation:**
```typescript
interface SnapshotService {
  // Take snapshot at current block
  takeSnapshot(): Promise<Snapshot>;

  // Get snapshot by ID
  getSnapshot(id: string): Promise<Snapshot>;

  // Query holders from snapshot
  getHolders(snapshotId: string): Promise<Holder[]>;
}

interface Snapshot {
  id: string;
  blockNumber: number;
  timestamp: number;
  totalHolders: number;
  totalSupplyHeld: bigint;
}

interface Holder {
  address: string;
  balance: bigint;
  percentOfSupply: number;
}
```

**Data Source Options:**
1. **The Graph** — Index Spirit token Transfer events
2. **Alchemy/Infura** — eth_getBalance at block
3. **Dune Analytics** — Precomputed holder tables
4. **Custom indexer** — Most control, more work

**Recommended:** The Graph subgraph for Spirit token.

---

### 2. Merkle Root Service

**Purpose:** Generate merkle tree from snapshot for airstream claims.

**Implementation:**
```typescript
interface MerkleService {
  // Generate tree from snapshot
  generateTree(snapshotId: string): Promise<MerkleTree>;

  // Get proof for specific address
  getProof(treeId: string, address: string): Promise<string[]>;

  // Verify proof
  verifyProof(root: string, proof: string[], address: string, amount: bigint): boolean;
}

interface MerkleTree {
  id: string;
  snapshotId: string;
  root: string;
  leafCount: number;
  ipfsHash?: string;  // Store full tree for claims
}
```

**Leaf format:**
```
leaf = keccak256(abi.encodePacked(address, amount))
```

**Storage:**
- Root stored onchain (in createChild call)
- Full tree stored on IPFS for claiming
- Proofs generated on-demand via API

---

### 3. Price Service

**Purpose:** Calculate sqrtPriceX96 for Uniswap V4 pool initialization.

**Implementation:**
```typescript
interface PriceService {
  // Get current Spirit price
  getSpiritPrice(): Promise<PriceData>;

  // Calculate sqrtPriceX96 for child token
  calculateSqrtPrice(childFdv: bigint, spiritFdv: bigint): bigint;
}

interface PriceData {
  spiritPriceUsd: number;
  spiritFdv: bigint;
  source: 'coingecko' | 'dexscreener' | 'onchain';
  timestamp: number;
}
```

**sqrtPriceX96 Formula:**

Source: https://uniswapv3book.com/milestone_1/calculating-liquidity.html

Uniswap uses Q64.96 fixed-point format to store prices:

```
sqrtPriceX96 = √price × 2^96
```

**Python implementation (from Uniswap book):**
```python
import math

q96 = 2**96

def price_to_sqrtp(p):
    return int(math.sqrt(p) * q96)

# Example: price ratio of 5000 → 5602277097478614198912276234240
```

**TypeScript implementation for Spirit:**
```typescript
const Q96 = BigInt(2) ** BigInt(96);

function calculateSqrtPriceX96(
  spiritPriceUsd: number,  // Current Spirit price in USD
  childTargetFdv: number   // Target FDV for child (e.g., 40000)
): bigint {
  // Calculate price ratio: how many CHILD per SPIRIT
  // If Spirit FDV = 40K and Child FDV = 40K → ratio = 1:1
  const spiritFdv = spiritPriceUsd * 1_000_000_000; // 1B supply
  const ratio = childTargetFdv / spiritFdv;

  // Convert to sqrtPriceX96
  const sqrtRatio = Math.sqrt(ratio);
  const sqrtPriceX96 = BigInt(Math.floor(sqrtRatio * Number(Q96)));

  return sqrtPriceX96;
}

// Example usage:
// Spirit at $0.00004 (40K FDV), Child target 40K FDV
// → ratio = 1:1, sqrtPriceX96 = 2^96 = 79228162514264337593543950336
```

**Pierre's explanation (Jan 8 call):**
- Look at current USD value of Spirit
- Calculate ratio between Spirit FDV and target Child FDV (40K)
- Take square root of ratio
- Multiply by 2^96
- Pass to contract as `sqrtPriceX96` parameter

---

### 4. Validation Layer

**Purpose:** Prevent spam, validate parameters, enforce rules.

**Checks:**
```typescript
interface ValidationRules {
  // Rate limiting
  maxCreationsPerDay: number;        // e.g., 10
  maxCreationsPerAddress: number;    // e.g., 1 per 24h

  // Parameter validation
  nameMinLength: number;             // e.g., 3
  nameMaxLength: number;             // e.g., 32
  symbolMinLength: number;           // e.g., 2
  symbolMaxLength: number;           // e.g., 8

  // Platform rules
  approvedPlatforms: string[];       // Whitelist
  requirePlatformApproval: boolean;  // Phase 1 = true

  // Anti-spam
  minimumSpiritHeld: bigint;         // Optional: require Spirit holdings
  x402PaymentRequired: boolean;      // Payment via x402
}
```

---

## x402 Integration

**What is x402?**
HTTP 402 Payment Required — standardized payments for API calls.

**Superfluid-native:** https://x402.superfluid.org/

**Why x402:**
- Agents pay for API calls via streaming
- No upfront gas costs for callers
- Backend covers contract gas
- Monetization without token gating

**Implementation:**
```typescript
// API endpoint with x402 payment
app.post('/v1/agents/create', x402Middleware, async (req, res) => {
  // x402 middleware verifies payment stream
  // If insufficient, returns 402 Payment Required

  const { name, symbol, artist, agent, platform } = req.body;

  // Validate
  await validationService.validate(req.body);

  // Snapshot
  const snapshot = await snapshotService.takeSnapshot();

  // Merkle
  const tree = await merkleService.generateTree(snapshot.id);

  // Price
  const sqrtPriceX96 = await priceService.calculateSqrtPrice();

  // Create child (backend wallet pays gas)
  const tx = await spiritFactory.createChild(
    name, symbol, artist, agent, platform,
    tree.root, sqrtPriceX96
  );

  res.json({
    childToken: tx.childTokenAddress,
    stakingPool: tx.stakingPoolAddress,
    merkleTreeIpfs: tree.ipfsHash,
    tx: tx.hash
  });
});
```

**x402 Payment Flow:**
```
Agent → Opens Superfluid stream to Spirit treasury
      → Makes API call with stream proof
      → Backend verifies stream is active
      → Backend processes request
      → Stream continues (per-second payment)
```

---

## Rollout Phases

### Phase 1: Manual (Current)

- First 10 children manually approved
- Eden = platform for all
- Backend runs locally or simple deployment
- No x402 yet (internal calls only)

### Phase 2: Semi-Permissionless

- Backend API publicly accessible
- x402 payment required
- Platform whitelist enforced
- Rate limiting active

### Phase 3: Progressive Decentralization

- Backend rules relax over time
- Predetermined graduation criteria
- Eventually: onchain oracle/prediction market for approval

---

## API Endpoints

### POST /v1/agents/create

Create a new child token/agent.

**Request:**
```json
{
  "name": "MyAgent",
  "symbol": "MYAG",
  "artist": "0x...",
  "agent": "0x...",
  "platform": "0xEden..."
}
```

**Response:**
```json
{
  "success": true,
  "childToken": "0x...",
  "stakingPool": "0x...",
  "lpPosition": "0x...",
  "merkleRoot": "0x...",
  "merkleTreeIpfs": "ipfs://...",
  "transactionHash": "0x..."
}
```

### GET /v1/agents/:symbol

Get agent details.

### GET /v1/merkle/:treeId/proof/:address

Get merkle proof for airstream claim.

### GET /v1/snapshots/:id

Get snapshot details.

---

## Infrastructure Requirements

| Component | Recommendation | Notes |
|-----------|----------------|-------|
| API Server | Node.js + Fastify | Or Go for performance |
| Database | PostgreSQL | Snapshots, trees, requests |
| Cache | Redis | Rate limiting, hot data |
| Queue | Bull/BullMQ | Async processing |
| Indexer | The Graph | Spirit holder data |
| Storage | IPFS/Pinata | Merkle trees |
| Wallet | AWS KMS or Fireblocks | Secure admin key |

---

## Security Considerations

1. **Admin Key Protection**
   - Use HSM/KMS for signing
   - Multi-sig for high-value operations
   - Rate limit contract calls

2. **Merkle Root Integrity**
   - Deterministic tree generation
   - Publish tree on IPFS before tx
   - Anyone can verify root matches tree

3. **Price Manipulation**
   - Use TWAP, not spot price
   - Multiple oracle sources
   - Sanity bounds on ratio

4. **x402 Abuse**
   - Minimum stream rate
   - Cooldown between requests
   - Ban list for abusers

---

## Open Questions for Pierre

1. Exact sqrtPriceX96 formula and token ordering?
2. Minimum viable infrastructure for Phase 1?
3. Can Spirit treasury fund x402 agent payments?
4. Standard Superfluid tooling for merkle generation?

---

## Related Documents

- `SPIRIT_SOURCE_OF_TRUTH.md` — Canonical parameters
- `PIERRE_CALL_NOTES.md` — Call transcript
- `SELF_SERVICE_ARCHITECTURE.md` — Original design (now superseded)
- https://x402.superfluid.org/ — x402 documentation

---

*Created from Pierre call (Jan 8, 2026) — Quality > Speed*
