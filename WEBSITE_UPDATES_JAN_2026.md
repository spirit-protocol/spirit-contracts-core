# Website Updates — January 2026

**Purpose:** Align spiritprotocol.io with contract reality
**Priority:** HIGH — Website currently shows incorrect information
**Source:** Pierre call (Jan 8, 2026) + token split changes (Jan 1, 2026)

---

## Critical Updates

### 1. Token Split (WRONG on website)

**Current website says:**
```
25% Creator / 25% Agent / 25% Platform / 25% SPIRIT Holders
```

**Should say:**
```
25% Creator / 20% Agent / 25% Platform / 25% SPIRIT Holders / 5% LP
```

**Files to update:**
- Homepage hero section
- Tokenomics page
- Whitepaper references
- llm.txt / llms.txt

---

### 2. "Hardcoded, Immutable" Claims (MISLEADING)

**Current website says:**
> "Splits are hardcoded and immutable"

**Reality:**
- Pierre changed the split on Jan 1, 2026
- Contract is upgradeable
- "Immutable" was aspirational, not actual

**Should say:**
> "Splits are enforced by smart contract. Current allocation: 25/20/25/25/5"

---

### 3. SDK Availability (WRONG)

**Current website says:**
> "SDK available" / "npm install @spirit-protocol/sdk"

**Reality:**
- SDK not published to npm
- SDK has different addresses than contracts repo
- Self-service registration not live

**Should say:**
> "SDK coming Q1 2026" or remove SDK claims entirely

---

### 4. Self-Service Registration (MISLEADING)

**Current website implies:**
> Anyone can register an agent

**Reality:**
- `createChild()` requires admin role
- First 10 children are manually approved
- Self-service is backend-controlled (not contract-level)

**Should say:**
> "Agent registration currently by invitation. Self-service launching Q1 2026."

---

### 5. Revenue Routing (UNVERIFIED)

**Current website says:**
> "Revenue routing active"

**Reality:**
- Only on testnet (Base Sepolia)
- No mainnet deployment yet
- No agents actually routing revenue

**Should say:**
> "Revenue routing live on Base Sepolia testnet. Mainnet Q1 2026."

---

## Suggested Page-by-Page Updates

### Homepage

| Section | Current | Update To |
|---------|---------|-----------|
| Hero | "25/25/25/25 split" | "25/20/25/25/5 — Agent-first economics" |
| CTA | "Register an agent" | "Join waitlist" or "Coming Q1 2026" |
| Features | "SDK available" | "SDK launching soon" |

### Tokenomics Page

| Section | Current | Update To |
|---------|---------|-----------|
| Split diagram | 4-way split | 5-way split with LP |
| "Hardcoded" claim | Remove | "Enforced by smart contract" |
| Agent allocation | 25% | 20% + 5% LP (owned by agent) |

### For Developers

| Section | Current | Update To |
|---------|---------|-----------|
| npm install | Show command | "Coming soon" badge |
| Code examples | Active | "Preview — not production ready" |
| Contract addresses | May be wrong | Link to contracts repo |

### llm.txt / llms.txt

These files are used by AI systems to understand the protocol. They MUST be accurate.

**Update:**
```
Token Distribution:
- Creator/Artist: 25% (auto-staked 52 weeks)
- Agent: 20% (auto-staked 52 weeks)
- Platform: 25% (configurable per-agent)
- SPIRIT Holders: 25% (airstreamed 52 weeks)
- LP: 5% (Uniswap V4, owned by agent wallet)

Status:
- Contracts: Live on Base Sepolia testnet
- SDK: Not yet published
- Mainnet: Q1 2026
- Self-service: Backend-controlled (not permissionless)
```

---

## Securities Language Reminders

From SECURITIES_AUDIT_DEC_19.md — these must remain accurate:

| Never Say | Always Say |
|-----------|------------|
| "Earn rewards" | "Receive governance tokens" |
| "Revenue share" | "Operational allocation" |
| "Yield" | "Governance weight" |
| "Investment" | "Participation" |

---

## Deployment Checklist

- [ ] Update homepage hero
- [ ] Update tokenomics page
- [ ] Update for-developers page
- [ ] Update llm.txt
- [ ] Update llms.txt
- [ ] Remove/update SDK claims
- [ ] Update contract addresses
- [ ] Add "testnet" badges where appropriate
- [ ] Review all "hardcoded/immutable" claims
- [ ] Check securities language throughout

---

## Where is the Website?

**Repository:** Unknown on this machine (Mac Studio)

**Likely locations:**
- `spiritprotocol.io` repo (not found)
- May be on laptop (MacBook Pro)
- Check Vercel dashboard

**To find:**
```bash
# Check Vercel
vercel list

# Or search laptop when connected
find /Volumes/MacBook* -name "spiritprotocol*" 2>/dev/null
```

---

## Related Documents

- `SPIRIT_SOURCE_OF_TRUTH.md` — Canonical parameters
- `BACKEND_ARCHITECTURE.md` — Self-service architecture
- `SECURITIES_AUDIT_DEC_19.md` — Language requirements
- `SYNC_STATUS_JAN_7_2026.md` — Full sync audit

---

*Created: January 8, 2026*
*Priority: Complete before any external communications*
