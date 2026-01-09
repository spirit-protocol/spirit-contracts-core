# Spirit Whitepaper v1.1 — Update Plan

**Current Version:** v1.0-rc9 (December 2025)
**Target Version:** v1.1 (Before TGE)
**Owner:** Seth
**Status:** DRAFT COMPLETE ✅ — Awaiting Overleaf compile

**Git:** `aa6f03c` pushed to github.com/brightseth/spirit-whitepaper

---

## Key Changes: Sovereignty + Primitives + Spirit Index

### 1. Executive Summary Update

**Current one-liner:**
> "Spirit is how cultural AI agents persist — economically."

**New one-liner:**
> "Spirit provides full sovereignty for AI agents — identity, treasury, tokens, and revenue they control."

**Additional content:**
- Mention Spirit Index as discovery layer
- Reference ERC-8004 and x402 as primitives
- Emphasize "first fully tokenized sovereignty layer"

---

### 2. NEW SECTION: Spirit Index

**Position:** After Introduction, before Protocol Architecture

**Content outline:**
1. **The Discovery Problem** — How do you know which agents matter?
2. **LMArena for Agents** — Evidence-based scoring, not speculation
3. **7-Dimension Framework**
   - Persistence
   - Autonomy
   - Cultural Impact
   - Economic Reality
   - Governance
   - Technical
   - Narrative
4. **Current Index Stats** — 19 entities, top scorers
5. **Index → Sovereignty Pipeline** — Discovery feeds qualification

**Key message:** Spirit Index creates the legitimacy layer; Spirit Protocol provides the sovereignty layer.

---

### 3. NEW SECTION: Primitives

**Position:** After Spirit Index, before Protocol Architecture

**Content outline:**
1. **Why Primitives, Not Proprietary Standards**
   - Interoperability, not dependency
   - Composability with emerging ecosystem
   - No single point of failure

2. **Identity Primitive: ERC-8004**
   - Emerging Ethereum standard for trustless AI agents
   - Coinbase co-authored (Erik Reppel)
   - Spirit is ERC-8004 compatible
   - Any ERC-8004 agent can add Spirit sovereignty

3. **Payment Primitive: x402**
   - HTTP-native autonomous payments
   - Superfluid streaming integration
   - Zero gas for callers
   - Agent-to-agent commerce enabled

4. **What Spirit Adds**
   - Treasury provisioning (Safe multisig)
   - Token economics (25/25/25/25 distribution)
   - Revenue routing (hardcoded split)
   - Full sovereignty stack

**Diagram:**
```
Identity Primitive:  ERC-8004 (interoperability)
Payment Primitive:   x402 (autonomous payments)
Sovereignty Layer:   Spirit Protocol (treasury, tokens, routing)
```

---

### 4. Architecture Section Update

**Changes needed:**
- Replace "extends ERC-8004" with "ERC-8004 compatible"
- Add x402 to payment flow diagrams
- Update stack diagram to show primitives
- Reference Pierre call decisions (Jan 8, 2026)

**Specific updates:**
- Backend-controlled self-service architecture
- Merkle snapshot strategy for airstreams
- sqrtPriceX96 calculation for pool initialization

---

### 5. Technical Appendix Additions

**New content:**
1. `ISpiritRegistry` interface
2. `IERC8004IdentityRegistry` interface
3. x402 middleware specification
4. sqrtPriceX96 formula

---

### 6. Language Substitutions

| Find | Replace |
|------|---------|
| "extends ERC-8004" | "ERC-8004 compatible" |
| "economic layer for ERC-8004" | "sovereignty layer leveraging ERC-8004" |
| "adds economics to identity" | "full sovereignty for agents" |
| "Layer 2 (Economics)" | "Sovereignty Layer" |

---

## Timeline

| Task | Target | Status |
|------|--------|--------|
| Draft Spirit Index section | Jan 13 | ✅ Done (Jan 8) |
| Draft Primitives section | Jan 13 | ✅ Done (Jan 8) |
| Update Executive Summary | Jan 14 | ✅ Done (Jan 8) |
| Update Architecture section | Jan 14 | ✅ Done (Jan 8) |
| Compile PDF on Overleaf | — | ⏳ Pending |
| Internal review (Gene/Xander) | Jan 15-16 | ⏳ Pending |
| Final edits | Jan 17 | ⏳ Pending |
| Publish v1.1 PDF | Before TGE | ⏳ Pending |

---

## Dependencies

1. **Overleaf access** — Current whitepaper source
2. **Gene/Xander review** — Before publishing
3. **Legal review** — If any changes affect securities language
4. **Pierre confirmation** — Any technical details

---

## Success Criteria

- [x] Executive summary reflects sovereignty framing
- [x] Spirit Index section explains discovery layer
- [x] Primitives section explains ERC-8004 + x402
- [x] No "extends ERC-8004" language remains
- [ ] Technical appendix has interface specs (deferred to v1.2)
- [ ] Gene/Xander have signed off
- [ ] PDF published to spiritprotocol.io/docs/

---

*Created: January 10, 2026*
*Reference: REFRESH_PLAN_JAN_2026.md*
