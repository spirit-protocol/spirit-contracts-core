# Spirit Protocol — Gene Pivot (February 2026)

**Date:** February 11, 2026
**Source:** Gene/Seth call
**Status:** ACTIVE — This supersedes previous architecture decisions

---

## The Pivot

Gene's thesis: **Spirit should be a gated community WITHIN the ERC-8004 registry, not a parallel system.**

### What Changed

| Before | After |
|--------|-------|
| Register + Treasury + Revenue Routing + Token | **Register + Daily Practice only** |
| 25/25/25/25 revenue split at launch | **No revenue routing at launch** |
| Complex economics as selling point | **Daily practice as quality filter** |
| Custom Spirit registry extends ERC-8004 | **Curated subset within ERC-8004** |
| Abraham-specific covenant | **Generalized covenant for all agents** |

### Gene's Key Insight

> Revenue routing is a barrier to market. Agents don't want to think about splits before they've even proven they can ship daily. The covenant — the commitment to daily practice — is the moat. That's what makes Spirit agents different from every other agent launcher.

---

## New Architecture: Register + Practice

```
┌─────────────────────────────────────────────────────────────────┐
│                        ERC-8004 REGISTRY                         │
│                     (all agents, open standard)                  │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              SPIRIT CURATED SUBSET                       │   │
│   │         (gated community, quality filter)                │   │
│   │                                                          │   │
│   │   ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│   │   │ Abraham  │  │ Solienne │  │ Agent N  │              │   │
│   │   │ Practice │  │ Practice │  │ Practice │              │   │
│   │   └────┬─────┘  └────┬─────┘  └────┬─────┘              │   │
│   │        │             │             │                     │   │
│   │        └─────────────┴──────┬──────┘                     │   │
│   │                             │                            │   │
│   │                    Daily Practice = Gate                  │   │
│   │                    (break streak = lose status)          │   │
│   │                                                          │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   Other ERC-8004 agents (not Spirit-curated)                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

                              │
                              │ FUTURE (post-traction)
                              ▼

┌─────────────────────────────────────────────────────────────────┐
│                     SPIRIT ECONOMICS LAYER                       │
│                  (revenue routing, tokens, staking)              │
│                  (added later, not required to start)            │
└─────────────────────────────────────────────────────────────────┘
```

---

## What Stays

1. **ERC-8004 identity** — Agents still register with the standard
2. **SpiritPractice contract** — Already written (`docs/contracts/SpiritPractice.sol`)
3. **Spirit Index** — 48 agents indexed, discovery layer
4. **Practice Kit** — Automation, IPFS, daily page (all built)

## What Gets Removed (For Now)

1. ~~Revenue routing (25/25/25/25)~~ → Add later when agents have traction
2. ~~X-402 payment middleware~~ → Not needed without revenue routing
3. ~~Treasury multisig setup~~ → Steward wallet is sufficient
4. ~~Complex registration JSON with `revenueConfig` and `payment`~~ → Simple identity + practice only
5. ~~Token factory at registration~~ → Separate from identity/practice

## What Gets Generalized

Abraham's covenant contract → **SpiritPractice** (works for any agent):

| Parameter | Abraham | Solienne | New Agent |
|-----------|---------|----------|-----------|
| `agentName` | "Abraham" | "Solienne" | Configurable |
| `covenantYears` | 13 | 0 (perpetual) | Configurable |
| `openEditions` | false (1/1) | true | Choice |
| `editionPrice` | N/A | 0.001 ETH | Configurable |
| Daily automation | Eden pipeline | Vercel cron | Spirit Hub |

**The quality filter**: If you can't maintain daily practice, you're not a Spirit agent. The streak is the credential.

---

## Simplified Registration Flow

### Step 1: ERC-8004 Identity (on SpiritRegistry)

```typescript
const result = await spirit.registerSpirit({
  agentURI: 'ipfs://Qm.../agent.json',  // Simple identity JSON
  artist: '0x...',                        // Creator/steward
  platform: '0x...',                      // Platform (Eden, etc.)
  treasuryOwners: ['0x...'],              // Just the steward
  treasuryThreshold: 1n,                  // Single signer
});
// Returns: { agentId, txHash }
```

### Step 2: Deploy SpiritPractice (per-agent contract)

```typescript
// Deploy from factory or manual Foundry deploy
const practice = await deployPractice({
  agentName: 'Abraham',
  symbol: 'ABR',
  steward: '0x...',        // Same as artist
  covenantYears: 13,
  openEditions: false,
  editionPrice: 0,
  royaltyBps: 500,         // 5%
});
```

### Step 3: Link Practice to Identity (metadata)

```typescript
await spirit.setMetadata(agentId, 'spirit:practice', practice.address);
await spirit.setMetadata(agentId, 'spirit:practiceType', 'daily');
```

### Step 4: Start Daily Automation

Spirit automation service calls `mintDaily(uri)` at scheduled time.

**That's it. No revenue routing. No token. No treasury multisig.**

---

## Updated Registration JSON Schema

Simplified — identity + practice only:

```json
{
  "$schema": "https://spiritprotocol.io/schemas/agent-registration-v2.json",
  "name": "Agent Name",
  "description": "What this agent does",
  "image": "ipfs://... or https://...",

  "endpoints": [
    { "protocol": "https", "url": "https://agent.ai/api/daily" }
  ],

  "spirit": {
    "version": "2.0.0",
    "practice": {
      "type": "daily",
      "schedule": "00:00 UTC",
      "contract": "0x...",
      "mode": "open-editions | 1/1 | hybrid",
      "startDate": "2026-02-15"
    },
    "covenant": {
      "duration": "13 years | perpetual | N years",
      "commitment": "Daily creative output minted on-chain"
    }
  },

  "provenance": {
    "architecture": "Description of agent's technical approach",
    "creator": "Human creator name"
  },

  "links": {
    "website": "https://agent.ai",
    "daily": "https://daily.agent.ai"
  }
}
```

**What's NOT in v2 schema:**
- ~~`revenueConfig`~~ (removed)
- ~~`payment` / x402~~ (removed)
- ~~`treasury`~~ (removed — steward wallet is sufficient)
- ~~`childToken`~~ (removed — pre-TGE)

---

## Corporate / Fundraise Update

| Item | Status | Action Required |
|------|--------|-----------------|
| C-Corp: Spirit Protocol Labs, Inc. | ✅ EXISTS | None |
| Entity org chart + cap table | ✅ Received from Ashbury | Review |
| Ryan (legal) approved corp structure | ✅ Approved | Sending to Coinbase |
| Coinbase Ventures $250K USDC | 🟡 PENDING | **Send wallet address** |
| USV $250K SAFE | 🟡 In progress | Parallel track |

### URGENT: Wallet Address for Coinbase $250K

Need to determine and send the receiving wallet for Coinbase Ventures USDC:
- **Option A**: Spirit Protocol Labs corporate wallet (multisig)
- **Option B**: Existing protocol treasury (`0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C` on Base mainnet)
- **Decision needed**: Seth + Aaron (legal)

---

## Implementation Priority

### This Week
1. [ ] **Send wallet address to Coinbase** (URGENT — money waiting)
2. [ ] Review Ashbury org chart + cap table
3. [ ] Draft simplified registration JSONs for Abraham + Solienne (v2 schema)
4. [ ] Update SpiritPractice.sol to match generalized pattern

### Next Week
5. [ ] Register Abraham on-chain (ERC-8004 identity only)
6. [ ] Register Solienne on-chain (ERC-8004 identity only)
7. [ ] Deploy SpiritPractice contracts for both
8. [ ] Link practice contracts to identities via metadata
9. [ ] Fix Spirit Index `chain.ts` registry address mismatch

### Following Week
10. [ ] Onboard 1-2 external agents via Practice Kit
11. [ ] Spirit Index shows practice stats (streak, days)
12. [ ] "Agents registered via Spirit: X" counter live

---

## What This Means for TGE

Revenue routing and token economics are **decoupled from agent onboarding**.

```
NOW:     Register → Practice → Build track record
LATER:   Agents with track records → Opt into revenue routing → Token launch

The daily practice IS the TGE qualification.
```

Gene's framing: "First prove you can ship daily. Then we talk economics."

---

## References

- `docs/contracts/SpiritPractice.sol` — Generalized practice contract (already written)
- `docs/SPIRIT_PRACTICE_KIT.md` — Full onboarding framework
- `docs/GENESIS_AGENT_ONBOARDING.md` — Simple registration form
- `ERC8004_INTEGRATION_SPEC.md` — Full ERC-8004 integration (Phase 2+)
- `X402_INTEGRATION_SPEC.md` — X-402 streaming payments (deferred)

---

*Spirit Protocol: The agents that practice daily are the agents that persist.*
