# SPIRIT PROTOCOL — SOURCE OF TRUTH

**Last Updated:** January 10, 2026 @ 3:00pm PST
**Updated By:** Seth (via Claude Code)
**Status:** LOCKED unless noted
**Last Review:** Materials refresh (Jan 10, 2026)

---

## QUICK REFERENCE

**One sentence:** Spirit provides full sovereignty for AI agents — identity, treasury, tokens, and revenue they control.

**Positioning:** The first fully tokenized sovereignty layer for AI agents — built on ERC-8004 identity and x402 payments as primitives.

**Token split (Agent):** 25/25/25/25 — Agent's 25% includes 5% LP (owned by agent wallet)

**Revenue split:** 25% Creator / 25% Agent / 25% Platform / 25% Protocol (hardcoded)

**TGE:** Q1 2026 (public) — Jan 15 NOT a real deadline

**Genesis Agents:** Abraham, Solienne, Gigabrain (NO Geppetto)

**Architecture:** Backend-controlled self-service (not permissionless contracts)

**Discovery Layer:** Spirit Index (spiritindex.org) — LMArena for cultural agents

---

## 1. CORE IDENTITY

**Thesis:**
> Spirit provides full sovereignty for AI agents — identity, treasury, tokens, and revenue they control. Not platforms controlling agents, but agents controlling themselves.

**Positioning Decision:** Lead with SOVEREIGNTY frame
- ERC-8004 + x402 are primitives (interoperability, not dependency)
- Spirit is the first complete sovereignty layer combining identity, treasury, tokens, and revenue routing
- Spirit Index is the discovery layer (LMArena for agents)
- Cultural agents (Abraham, Solienne) prove the model; sovereignty applies broadly

**Differentiation:**
- vs Virtuals/ai16z: Sovereignty-first, not speculation-first
- vs ERC-8004 alone: Spirit adds treasury, tokens, and revenue routing
- vs other infrastructure: Spirit Index creates legitimacy moat

---

## 1A. SPIRIT INDEX (DISCOVERY LAYER)

**URL:** https://spiritindex.org
**Status:** LIVE
**Positioning:** LMArena for cultural agents

### What It Is

Spirit Index evaluates which agents have real persistence — the discovery layer for which agents qualify for Spirit sovereignty.

### 7-Dimension Framework

| Dimension | What It Measures |
|-----------|------------------|
| Persistence | Continuous practice, archive depth, operational history |
| Autonomy | Self-directed behavior, financial independence |
| Cultural Impact | Audience reach, critical recognition, market traction |
| Economic Reality | Revenue streams, treasury, sustainable model |
| Governance | Decision-making structure, stakeholder alignment |
| Technical | Architecture quality, operational infrastructure |
| Narrative | Identity coherence, communication clarity |

### Current Index

- **19 entities indexed** (as of Jan 2026)
- **Top entities:** Plantoid (60/70), Botto (55/70), Olas (54/70), Holly+ (53/70), terra0 (53/70)
- **Max score:** 70 points (10 per dimension)

### Index → Sovereignty Pipeline

```
Spirit Index (Discovery)  →  Spirit Protocol (Sovereignty)
        ↓                            ↓
 Evaluate persistence         Provide full sovereignty:
 Score across 7 dimensions    - Identity (onchain)
 Rank entities                - Treasury (Safe multisig)
        ↓                     - Token (native + liquidity)
 High-scoring agents          - Revenue routing (25/25/25/25)
 qualify for Spirit
```

---

## 2. $SPIRIT TOKEN (LOCKED)

| Parameter | Value | Status |
|-----------|-------|--------|
| Total Supply | 1,000,000,000 | LOCKED |
| Network | Base (Coinbase L2) | LOCKED |
| TGE (Public) | Q1 2026 | USE THIS |
| TGE (Internal) | When ready | Quality > Speed |

### Spirit Token — NO CTA (Securities Critical)

**Pierre quote (Jan 8):** "There is no action for Spirit. Spirit, you just hold it and farm child tokens. Staking is for child tokens."

**Why this matters:**
- Spirit doesn't generate revenue/dividends
- Spirit just entitles you to more tokens (airstreams)
- This is materially different from a security
- Staking rewards come from AGENT tokens, not SPIRIT

### Allocation

| Category | % | Amount | Vesting | Notes |
|----------|---|--------|---------|-------|
| Community Programmatic | 30% | 300M | Airstreamed to agents | |
| Treasury | 25% | 250M | Governed by holders | NOT distributed |
| Eden Incubation | 25% | 250M | 48mo vest, 12mo cliff | |
| Protocol Team | 10% | 100M | 48mo vest, 12mo cliff | |
| Community Upfront | 10% | 100M | Genesis artists, advisors | |

---

## 3. AGENT TOKEN DISTRIBUTION (LOCKED)

**Confirmed:** Pierre (Superfluid), January 1, 2026
**Commit:** https://github.com/0xPilou/spirit-contracts/commit/14be3752

| Recipient | % | Amount | Notes |
|-----------|---|--------|-------|
| Creator/Artist | 25% | 250M | Auto-staked 52 weeks |
| Agent | 25%* | 250M | *20% staked + 5% LP (owned by agent wallet) |
| Platform | 25% | 250M | Configurable per-agent (Eden first, opens later) |
| SPIRIT Holders | 25% | 250M | Airstreamed 52 weeks via merkleRoot |

**Key change (Jan 1):** Agent now owns LP position (can add/remove/collect fees)
**Public framing:** "25 × 4" — Agent's 25% includes 5% LP as asterisk detail

---

## 3A. SELF-SERVICE ARCHITECTURE (LOCKED)

**Confirmed:** Pierre (Superfluid), January 8, 2026

### Key Decision: Backend Creates Children

Pierre's recommendation: Keep `createChild()` admin-protected. Backend handles everything.

**Why:**
- Can't verify merkle root is correct onchain
- Can't verify sqrtPriceX96 is correct onchain
- Permissionless contracts = potential vulnerability
- Backend can validate everything before calling contract

### Architecture Flow

```
Agent requests creation via x402 API
        ↓
Backend validates request
        ↓
Backend takes Spirit holder snapshot
        ↓
Backend generates merkle root
        ↓
Backend calculates sqrtPriceX96 (based on Spirit FDV)
        ↓
Backend calls createChild (pays gas)
        ↓
Agent token created
```

### Merkle Root Strategy

- **Snapshot-based** at time of agent creation
- Backend takes snapshot of Spirit holders
- If you hold Spirit at snapshot → you get child token airstream
- If you sell Spirit after snapshot → you still get that child's airstream
- If you sell before next agent → you miss next agent's airstream

**Incentive:** Hold Spirit to be eligible for ALL future agent launches

### Pool Initialization

- Price ratio based on Spirit FDV
- Example: Spirit = 40K FDV, Child = 40K FDV → 1:1 ratio
- Backend service calculates sqrtPriceX96 from Spirit USD price
- Waiting on Pierre for exact formula

### Monetization: x402 Protocol

- Agents pay for backend API via x402 streaming (https://x402.superfluid.org/)
- No need for `register()` wrapper in contract
- Keeps contracts tight and secure
- Zero gas for callers (EIP-712 signatures)

### Rollout Strategy

| Phase | Scope | Status |
|-------|-------|--------|
| 1 | First 10 children — manually approved, Eden = platform | CURRENT |
| 2 | Progressively permissionless via backend rules | FUTURE |
| 3 | Predetermined on-chain graduation criteria | LONG-TERM |

---

## 4. REVENUE ROUTING (HARDCODED)

| Recipient | % |
|-----------|---|
| Creator/Artist | 25% |
| Agent Wallet | 25% |
| Platform | 25% |
| Protocol (staking pool) | 25% |

**Justification (for Coinbase):**
- Artist 25%: Lifetime compensation for training (industry-leading)
- Agent 25%: Operational costs (compute, storage, inference)
- Platform 25%: Standard marketplace fee (comparable to galleries)
- Treasury 25%: Protocol sustainability (NOT distributed to holders)

**Critical:** Treasury is GOVERNED by holders, NOT DISTRIBUTED to holders.

---

## 5. STAKING MECHANICS (LOCKED)

### How It Works
- Stake AGENT tokens (e.g., $ABRAHAM, $SOLIENNE)
- Receive SPIRIT as governance incentive (NOT "rewards")
- Longer lock = higher multiplier

### Multiplier Scale

| Lock Period | Multiplier |
|-------------|------------|
| 1 week | 1x |
| 52 weeks | 12x |
| 156 weeks | 36x |

### What Holders Get vs. Don't Get

| ✅ GET | ❌ DON'T GET |
|--------|--------------|
| Agent token airstreams (pro-rata) | Direct revenue distribution |
| Governance over protocol | Dividends or profit sharing |
| Governance over treasury | Guaranteed returns |
| | Equity in any entity |

---

## 6. SECURITIES LANGUAGE (MANDATORY)

### Required Substitutions

| ❌ Never Say | ✅ Always Say |
|--------------|---------------|
| "Earn rewards" | "Receive governance tokens" |
| "Earn SPIRIT" | "Receive SPIRIT for participation" |
| "Revenue share" | "Operational allocation" |
| "Profit distribution" | "Protocol incentives" |
| "Value capture" | "Ecosystem alignment" |
| "Yield" | "Governance weight" |
| "Investment" | "Participation" |
| "Jan 15, 2026" (public) | "Q1 2026" |
| "DEX trading begins" | "Protocol operations begin" |

### Key Legal Points
1. SPIRIT = governance token, not investment contract
2. Staking = active participation, not passive income
3. Treasury = governed by holders, not distributed to holders
4. Legal structure = Wyoming DUNA (nonprofit)
5. Counsel = Aaron Wright

**Reference:** `SECURITIES_AUDIT_DEC_19.md` for specific line-by-line website fixes

---

## 7. GENESIS AGENTS (LOCKED)

| Agent | Creator | Status | Proof |
|-------|---------|--------|-------|
| Abraham | Gene Kogan | Live | $150K+ sales, 7 years R&D, 13-year covenant |
| Solienne | Kristi Coronado | Live | 9,700+ works, Paris Photo 2025 |
| Gigabrain | Xander Steenbrugge | Live | Enterprise AI consulting |

**⚠️ NO GEPPETTO** — Removed from all materials

---

## 8. TEAM (LOCKED)

### Core
- **Seth Goldstein** — Founder, Spirit Protocol
- **Gene Kogan** — Co-founder, Eden
- **Xander Steenbrugge** — Co-founder, Eden

### Website Team Page
- Seth, Gene, Xander, Jon Miller, Will Papper
- **Henry: NOT listed** (contractor, not team)

### Backing
- Fred Wilson / USV (angel)
- Superfluid (infrastructure)
- 0xSimao (audit, Nov 2025)
- Eden.art (incubating platform)

---

## 9. CURRENT ROUND (INTERNAL)

| Term | Value |
|------|-------|
| Raise | $2,000,000 |
| Valuation | $20M FDV |
| Price | $0.04 / SPIRIT |
| Tokens | 50M (5%) |
| Vesting | 12-month linear |
| Close | January 10, 2026 |

**Options:** Direct OTC + Echo.xyz platform

---

## 10. COINBASE STATUS

**Meeting:** December 19, 2025 with Jesse Pollak + Shan Aggarwal

**Outcome:**
- ✅ Positive reception ("hell yeah" from Jesse)
- ✅ Token listing review process started
- ✅ Potential presale participation
- ✅ Base app distribution discussion

**Next Steps:**
1. Shan reviews whitepaper + legal analysis
2. Follow up on presale in new year
3. Connect with ecosystem team for distribution

**What Shan Needs:**
- Whitepaper (clean PDF)
- Legal memo from Aaron Wright
- Securities-compliant language throughout

---

## 11. DOCUMENT HIERARCHY

```
SPIRIT_SOURCE_OF_TRUTH.md ← YOU ARE HERE (canonical facts)
         |
         ├── REFRESH_PLAN_JAN_2026.md (materials refresh plan)
         ├── SECURITIES_AUDIT_DEC_19.md (website fix checklist)
         ├── IMPROVEMENT_PLAN_DEC_19.md (phased roadmap)
         |
         └── Downstream (must match Source of Truth):
              ├── spiritprotocol.io (sovereignty framing + Spirit Index)
              ├── spiritindex.org (discovery layer)
              ├── Whitepaper v1.1 (before TGE)
              ├── Investor Deck v4 (Manus)
              └── Base Deck v4 (Manus)
```

**Manus Deck Links (v4 — January 2026):**
- Investor: https://manus.im/share/CvVAXEq5J2FZQFnrnCYNiz?replay=1
- Base: https://manus.im/share/MCGWSovhC459ATJUJAzKNn?replay=1

**Rule:** If Source of Truth and another doc conflict, Source of Truth wins.

---

## 12. CONTRACT ADDRESSES (TESTNET)

**Base Sepolia:**

| Contract | Address |
|----------|---------|
| SPIRIT Token | 0xc7e9de362C6eA2Cc03863ECe330622146Ff1c18B |
| Reward Controller | 0x1390A073a765D0e0D21a382F4F6F0289b69BE33C |
| Staking Pool Beacon | 0x6A96aC9BAF36F8e8b6237eb402d07451217C7540 |
| Spirit Factory | 0x879d67000C938142F472fB8f2ee0b6601E2cE3C6 |
| Vesting Factory | 0x94bea63d6eC10AF980bf8C7aEFeE04665D355AFe |

**Pending:** ETH Sepolia deployment for Airstreams testing

---

## 13. PRIMITIVES: ERC-8004 + x402

**Status:** LOCKED framing
**Standard:** ERC-8004 Trustless Agents (Coinbase co-authored)
**Reference:** `ERC8004_INTEGRATION_SPEC.md`, `X402_INTEGRATION_SPEC.md`

### Decision: Spirit is ERC-8004 COMPATIBLE (Not "Extends")

Spirit leverages ERC-8004 and x402 as primitives for full sovereignty:

```
Identity Primitive:  ERC-8004 (Coinbase co-authored) — interoperability
Payment Primitive:   x402 (Superfluid streaming) — autonomous payments
Sovereignty Layer:   Spirit Protocol — treasury, tokens, revenue routing
```

### Why Primitives (Not "Extends")

1. **Interoperability, not dependency** — Spirit doesn't chase the standard
2. **Composability** — Any ERC-8004 agent can add Spirit sovereignty
3. **Complete stack** — ERC-8004 gives identity, x402 gives payments, Spirit adds the rest
4. **No single point of failure** — Spirit works with or without ERC-8004 adoption

### Spirit Extensions to ERC-8004

| ERC-8004 Concept | Spirit Addition |
|------------------|-----------------|
| `agentId` (NFT) | Same ID, extended metadata |
| `agentWallet` | `treasury` (Safe multisig) |
| `owner` | `artist` (creator) |
| Metadata | Spirit-specific keys (`spirit:treasury`, etc.) |
| — | `childToken` (agent token) |
| — | `stakingPool` (GDA pool) |
| — | `lpPosition` (Uniswap V4 LP) |
| — | Revenue routing (25/25/25/25) |

### Implementation Phases

| Phase | Scope | Timeline |
|-------|-------|----------|
| 1 | Core integration (Identity Registry interface) | TGE |
| 2 | Reputation Registry integration | Q2 2026 |
| 3 | Validation Registry integration | Q3 2026 |
| 4 | Cross-registry support (external agents) | Q4 2026 |

### Open Questions

- Deploy own ERC-8004 registries or use canonical?
- Minimum viable for TGE vs full integration?
- How do existing Spirit agents migrate?

---

## 14. OPEN ITEMS

| Item | Status | Owner | ETA |
|------|--------|-------|-----|
| Token split implementation | ✅ DONE | Pierre | Jan 1, 2026 |
| sqrtPriceX96 calculation formula | ✅ DONE | Pierre | Jan 8, 2026 |
| Backend: Spirit holder snapshot service | ✅ DONE | Spirit | Jan 8, 2026 |
| Backend: Merkle root generation | ✅ DONE | Spirit | Jan 8, 2026 |
| Backend: Price calculation service | ✅ DONE | Spirit | Jan 8, 2026 |
| x402 middleware for API monetization | ✅ DONE | Spirit | Jan 8, 2026 |
| ERC-8004 integration spec | ✅ DONE | Spirit | Jan 8, 2026 |
| ERC-8004 contract implementation | TODO | Pierre + Spirit | Before TGE |
| Website: Sovereignty + Spirit Index refresh | ✅ DONE | Seth | Jan 10, 2026 |
| Investor Deck v4 (sovereignty framing) | ✅ DONE | Seth | Jan 10, 2026 |
| Base Deck v4 (sovereignty framing) | ✅ DONE | Seth | Jan 10, 2026 |
| Source of Truth: Sovereignty + Spirit Index | ✅ DONE | Seth | Jan 10, 2026 |
| First 10 children planning | TODO | Eden + Spirit | Before launch |
| SDK npm publish | BLOCKED | Pierre | After contracts stable |
| Whitepaper v1.1 (primitives section) | TODO | Seth | Before TGE |

---

## 15. KEY CONTACTS

| Role | Name | Contact |
|------|------|---------|
| Superfluid | Pierre | Telegram: pilou |
| Coinbase BD | Shan Aggarwal | shan.aggarwal@coinbase.com |
| Base | Jesse Pollak | jpollak@coinbase.com |
| Legal | Aaron Wright | (via Fred) |
| Eden | Gene Kogan | gene@eden.art |
| Eden | Xander Steenbrugge | xander@eden.art |

---

## 16. ROADMAP (From IMPROVEMENT_PLAN)

| Phase | Dates | Goal |
|-------|-------|------|
| 0 | Dec 19-22 | Securities compliance (website + whitepaper) |
| 1 | Dec 23-30 | Identity & messaging decisions |
| 2 | Dec 30 - Jan 10 | Website rebuild |
| 3 | Jan 10-15 | Whitepaper V1.1 |
| 4 | Jan 15+ | Governance & artist rights |
| 5 | Post-TGE | Ongoing transparency |

**Current:** Phase 0 — Securities compliance

---

## 17. CLAUDE CODE SESSION PROMPTS

### Session 1: spirit-contracts-core
```
Read SPIRIT_SOURCE_OF_TRUTH.md for all locked parameters.
This is canonical. Do not invent new facts.
```

### Session 2: spiritprotocol.io
```
Read SECURITIES_AUDIT_DEC_19.md for the 11 specific line fixes.
Execute each fix and check it off.
Use securities-safe language from SPIRIT_SOURCE_OF_TRUTH.md section 6.
```

### Session 3: spirit-whitepaper
```
Align with SPIRIT_SOURCE_OF_TRUTH.md.
Replace all "earn rewards" → "receive governance tokens"
Replace "revenue share" → "operational allocation"
Emphasize governance participation, not yield.
```

---

## 18. VERSION HISTORY

| Date | Time | Change | Source |
|------|------|--------|--------|
| Dec 19, 2025 | 3:30pm | Initial creation | Claude.ai |
| Dec 19, 2025 | 5:00pm | Post-Coinbase call updates | Claude.ai |
| Dec 19, 2025 | 8:00pm | Integrated securities audit + improvement plan | Claude.ai |
| Jan 8, 2026 | 12:30pm | Pierre call: Backend architecture, x402, merkle strategy | Claude Code |
| Jan 8, 2026 | 4:00pm | Backend services implemented, ERC-8004 integration spec | Claude Code |
| Jan 10, 2026 | 3:00pm | Materials refresh: Sovereignty framing, Spirit Index, primitives language | Claude Code |

---

**This is the canonical reference. When documents conflict, this document wins.**
