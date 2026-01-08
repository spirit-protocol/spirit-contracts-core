# Spirit Protocol — Sync Status

**Generated:** January 7, 2026
**Purpose:** Identify what's out of sync before Pierre call

---

## Summary: What's Out of Sync

| Component | Current State | Needs Update |
|-----------|--------------|--------------|
| **Website llm.txt** | Shows 25/25/25/25 | ⚠️ Update to 25/20/25/25/5 |
| **Website llms.txt** | Shows 25/25/25/25 | ⚠️ Update to 25/20/25/25/5 |
| **Pierre's Contracts** | 25/20/25/25/5 ✅ | — |
| **spirit-contracts-core** | OLD addresses | ⚠️ Merge Pierre's changes |
| **SDK** | v0.1.1 on GitHub | ⚠️ npm publish needed |
| **Whitepaper** | Uncommitted changes | ⚠️ Commit + deploy |
| **MCP Server** | In dist/, not in src/ | ⚠️ Verify working |

---

## 1. Smart Contracts

### Pierre's Latest (AUTHORITATIVE)
**Repo:** https://github.com/0xPilou/spirit-contracts
**Commit:** `14be3752aac0b811277bda0d6154c62679322c4d` (Jan 1, 2026)

**New Token Split:**
```
Artist:    250M (25%) - staked 52w
Agent:     200M (20%) - staked 52w
Platform:  250M (25%) - direct transfer, configurable per-agent
Airstream: 250M (25%) - merkle drop
LP:         50M (5%)  - position owned by Agent wallet
```

### Your Repo (OUTDATED)
**Repo:** spirit-contracts-core (local)
**State:** Still has old constants (250M LP)

**Action:** Get Pierre's changes merged into edenartlab repo or update your fork

### Contract Addresses

**SDK has (Base Sepolia):**
```
SpiritRegistry:    0x4a0e642e9aec25c5856987e95c0410ae10e8de5e
RoyaltyRouter:     0x271bf11777ff7cbb9d938d2122d01493f6e9fc21
SpiritToken:       0xC3FD6880fC602d999f64C4a38dF51BEB6e1b654B
SpiritFactory:     0x53B9db3DCF3a69a0F62c44b19a6c37149b7fB93b
StakingPool:       0xBBC3C7dc9151FFDc97e04E84Ad0fE91aF91D9DeE
RewardController:  0xD91CCC7eeA5c0aD0f6e5E2c6E5c08bdF5C1cA1b0
ProtocolTreasury:  0xe4951bEE6FA86B809655922f610FF74C0E33416C
```

**spirit-contracts-core has (Base Sepolia):**
```
SPIRIT Token:      0xc7e9de362C6eA2Cc03863ECe330622146Ff1c18B
Reward Controller: 0x1390A073a765D0e0D21a382F4F6F0289b69BE33C
Staking Pool:      0x6A96aC9BAF36F8e8b6237eb402d07451217C7540
Spirit Factory:    0x879d67000C938142F472fB8f2ee0b6601E2cE3C6
Vesting Factory:   0x94bea63d6eC10AF980bf8C7aEFeE04665D355AFe
```

**⚠️ DIFFERENT ADDRESSES** — Need to clarify with Pierre which is canonical

---

## 2. Website (spiritprotocol.io)

### What's Live
- **Main site:** https://spiritprotocol.io
- **llm.txt:** https://spiritprotocol.io/llm.txt
- **llms.txt:** https://spiritprotocol.io/llms.txt
- **Autonomy:** https://spiritprotocol.io/autonomy/ (NEW - Jan 2)

### Token Split Shown
Both llm.txt and llms.txt show:
> "25% Artist, 25% Agent Treasury, 25% Platform, 25% Protocol"

**This is WRONG** — Should be 25/20/25/25/5 per Pierre's changes

### Pages Updated Jan 2
- `/autonomy/` — Autonomy thresholds ($10K/$50K/18mo)
- `/agents/` — Agent-first registration
- 7 pages updated for narrative consistency

### Action Required
```bash
# Update llm.txt and llms.txt with new split:
# Artist: 25%, Agent: 20%, Platform: 25%, Airstream: 25%, LP: 5%
# Also note: Agent owns LP position
```

---

## 3. SDK (@spirit-protocol/sdk)

### GitHub State
**Repo:** spirit-sdk (local copy from laptop)
**Version:** 0.1.1
**Last commits:**
```
bd52bf3 Initial commit: spirit-protocol-sdk v0.1.0
9fb0a8c feat: add MCP CLI (spirit-mcp) + v0.1.1
7efaec5 feat: add deployed Base Sepolia contract addresses
```

### What It Contains
```
spirit-sdk/
├── src/
│   ├── index.ts       — Main exports
│   ├── client.ts      — Contract client
│   ├── constants.ts   — Addresses + ABIs
│   └── mcp/           — MCP server source
├── dist/              — Compiled JS
├── abis/              — Contract ABIs
│   ├── SpiritRegistry.json
│   ├── SpiritFactory.json
│   ├── StakingPool.json
│   └── ...
└── bin/               — CLI entry
```

### npm Status
**NOT PUBLISHED** — Blocking action from Jan 2:
```bash
cd ~/spirit-sdk
npm login
npm publish --access public
```

### MCP Server
- Source in `src/mcp/`
- Compiled in `dist/mcp/index.js`
- Claude Code config example exists

---

## 4. Whitepaper

### Location
**Local:** `~/spirit-whitepaper/`
**Contains:**
- `main.tex` — LaTeX source
- `overleaf-source/` — Overleaf sync
- Session notes from Jan 2

### Uncommitted Changes (Jan 2)
- "coordination pool" → "Spirit Treasury"
- Removed passive income language (securities compliance)

### Action Required
```bash
cd ~/spirit-whitepaper
git add main.tex
git commit -m "fix: clarify Spirit Treasury, remove passive income language"
git push origin main
# Then: Compile in Overleaf → deploy PDF
```

### Version
Website references: **v1.0-rc9**

---

## 5. Narrative Consistency Check

### Current Messaging (Website)
- **Tagline:** "Economic infrastructure for autonomous agents"
- **One sentence:** Spirit gives AI agents their own wallet
- **Three pillars:** Identity, Treasury, Autonomy

### Token Split Messaging
| Source | Split Shown | Correct? |
|--------|-------------|----------|
| llm.txt | 25/25/25/25 | ❌ |
| llms.txt | 25/25/25/25 | ❌ |
| Autonomy page | 25/25/25/25 | ❌ |
| Pierre's contracts | 25/20/25/25/5 | ✅ |
| SPIRIT_SOURCE_OF_TRUTH.md | 25/20/25/25/5 | ✅ (just updated) |

### Revenue vs Token Split
- **Revenue routing:** Still 25/25/25/25 (hardcoded)
- **Token distribution:** Now 25/20/25/25/5

**Important:** These are DIFFERENT. Revenue split didn't change.

---

## 6. Action Items for Sync

### Before Pierre Call (Today)
- [x] Update SPIRIT_SOURCE_OF_TRUTH.md with new split
- [x] Create call prep doc
- [ ] Clarify which testnet addresses are canonical

### After Pierre Call
- [ ] Merge Pierre's contract changes into edenartlab repo
- [ ] Update website llm.txt / llms.txt
- [ ] npm publish SDK
- [ ] Commit + deploy whitepaper
- [ ] Deploy new contracts with updated split (if needed)

### Questions for Pierre
1. Which Base Sepolia addresses are current?
2. Do we need to redeploy with new split, or is it parameterized?
3. Is edenartlab/spirit-contracts-core the canonical repo, or your fork?

---

## 7. Key URLs

| Resource | URL |
|----------|-----|
| Website | https://spiritprotocol.io |
| llm.txt | https://spiritprotocol.io/llm.txt |
| Autonomy | https://spiritprotocol.io/autonomy/ |
| Pierre's Repo | https://github.com/0xPilou/spirit-contracts |
| SDK (GitHub) | https://github.com/spirit-protocol/spirit-sdk |
| Contract (Sepolia) | https://sepolia.basescan.org/address/0x4a0e642e9aec25c5856987e95c0410ae10e8de5e |

---

*Generated for Pierre call prep — January 7, 2026*
