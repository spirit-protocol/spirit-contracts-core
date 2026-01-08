# SPIRIT PROTOCOL — SOURCE OF TRUTH

**Last Updated:** January 8, 2026 @ 4:00pm PST
**Updated By:** Seth (via Claude Code)
**Status:** LOCKED unless noted
**Last Review:** Pierre call (Jan 8, 2026)

---

## QUICK REFERENCE

**One sentence:** Spirit is how cultural AI agents persist — economically.

**Token split (Agent):** 25/25/25/25 — Agent's 25% includes 5% LP (owned by agent wallet)

**Revenue split:** 25% Creator / 25% Agent / 25% Platform / 25% Protocol (hardcoded)

**TGE:** Q1 2026 (public) — Jan 15 NOT a real deadline

**Genesis Agents:** Abraham, Solienne, Gigabrain (NO Geppetto)

**Architecture:** Backend-controlled self-service (not permissionless contracts)

---

## 1. CORE IDENTITY

**Thesis:**
> AI agents are proliferating. Most are ephemeral — they spike, speculate, and disappear. Culture doesn't work that way. Culture compounds. Spirit is infrastructure for the agents that matter.

**Positioning Decision:** Lead with CULTURAL frame (not infrastructure)
- Abraham's 13-year covenant is unique
- Infrastructure can be replicated; culture can't
- Differentiation from Virtuals, ai16z, etc.

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
| Valuation | $40M FDV |
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
         ├── SECURITIES_AUDIT_DEC_19.md (website fix checklist)
         ├── IMPROVEMENT_PLAN_DEC_19.md (phased roadmap)
         |
         └── Downstream (must match Source of Truth):
              ├── ONE_PAGER.md
              ├── spiritprotocol.io
              ├── Whitepaper
              └── Deck
```

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

## 13. ERC-8004 INTEGRATION (DRAFT)

**Status:** DRAFT — Needs team review
**Standard:** ERC-8004 Trustless Agents (Draft v1, Oct 2025)
**Reference:** `ERC8004_INTEGRATION_SPEC.md`

### Decision: Spirit EXTENDS ERC-8004

Spirit implements the ERC-8004 Identity Registry interface and adds economic extensions:

```
ERC-8004 Layer: Identity + Reputation + Validation
Spirit Layer:   Treasury + Revenue Router + Token Factory
```

### Why Extend (Not Replace)

1. **Network effects** — ERC-8004 has MetaMask, Coinbase, EF, Google backing
2. **Separation of concerns** — Identity ≠ Economics
3. **Composability** — Any ERC-8004 agent can add Spirit economics
4. **x402 alignment** — Both ERC-8004 and Spirit use x402 for payments

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
| Website: Fix 25/25/25/25 framing | TODO | Seth | This week |
| First 10 children planning | TODO | Eden + Spirit | Before launch |
| SDK npm publish | BLOCKED | Pierre | After contracts stable |
| Whitepaper PDF update | TODO | Seth | After architecture locked |

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

---

**This is the canonical reference. When documents conflict, this document wins.**
