# Pierre Call Prep — January 8, 2026

**Time:** 8:30am CET (11:30pm Wed PST)
**Duration:** 30-45 min
**Goal:** Understand Jan 1 changes, confirm self-service path feasibility

---

## Executive Summary

**The Ask:** Can we move `SpiritFactory` from admin-only to permissionless for V1?

**What Pierre Already Did (Jan 1):**
- ✅ Platform address is now a parameter (not hardcoded)
- ✅ Token split updated to 25/20/25/25/5
- ✅ Agent owns LP position

**What's Still Needed for Self-Service:**
- Remove `onlyRole(DEFAULT_ADMIN_ROLE)` from `createChild()`
- Add `payable` with registration fee
- Merkle root API for airstream
- SDK to calculate `sqrtPriceX96`

---

## What Pierre Shipped (Jan 1)

**Commit:** `14be3752aac0b811277bda0d6154c62679322c4d`
**Repo:** https://github.com/0xPilou/spirit-contracts

### New Token Split
| Recipient | Amount | % |
|-----------|--------|---|
| Artist | 250M | 25% |
| Agent | 200M | 20% |
| Platform | 250M | 25% |
| Airstream | 250M | 25% |
| LP | 50M | 5% |

### Key Changes
1. **Platform address** — Now a parameter in `createChild()`, configurable per agent
2. **LP position ownership** — Goes to Agent wallet (not factory/admin)
3. **Agent can manage LP** — Add liquidity, remove, collect fees

---

---

## ⚠️ Token Split Discrepancy — Clarify with Pierre

Your docs show two different interpretations:

| Recipient | Pierre's Commit | Your Earlier Docs |
|-----------|-----------------|-------------------|
| Artist | 25% (250M) | 25% |
| Agent | 20% (200M) | 25% |
| Platform | 25% (250M) | 25% |
| Airstream (to SPIRIT holders) | 25% (250M) | — |
| Protocol/Treasury | — | 20% |
| LP | 5% (50M) | 5% |

**Question:** Is "Airstream" the same as "Protocol"? Or are these different?

The ChatGPT prep doc says: "25% Platform / 25% Agent / 25% Artist / 20% Protocol / 5% LP"
Pierre implemented: "25% Artist / 20% Agent / 25% Platform / 25% Airstream / 5% LP"

**Need to confirm the canonical split.**

---

## Self-Service Technical Proposal

### A. Permissionless Factory (Factory Fee)

**Current:** `createChild()` requires `DEFAULT_ADMIN_ROLE`
**Proposed:**
```solidity
function registerAgent(...) external payable {
    require(msg.value >= registrationFee, "Fee too low");
    // ... rest of createChild logic
}
```
**Result:** Anyone can register if they pay the fee → Spirit Treasury

### B. Platform Allocation ✅ DONE

Pierre already implemented this:
```solidity
createChild(name, symbol, artist, agent, platform, merkleRoot, sqrtPrice)
```
Platform address is a parameter, not hardcoded.

### C. Merkle Root (Airstream)

**Problem:** Who computes the merkle tree?
**Solution:** Off-chain calculation, on-chain commitment
```javascript
// SDK flow:
const merkleRoot = await spirit.getLatestSnapshot(); // API call
await spirit.register({ ..., merkleRoot });          // Pass to contract
```

### D. Uniswap Price Initialization

**Problem:** `sqrtPriceX96` is complex math
**Solution:** SDK calculates it
```javascript
// SDK handles conversion:
const sqrtPrice = spirit.priceToSqrtX96(0.0001); // $0.0001 per token
await spirit.register({ ..., initialPrice: 0.0001 }); // SDK converts
```

### E. LP Seeding — WHO PROVIDES ETH?

**Critical question:** The 5% LP is single-sided CHILD tokens. But Uniswap needs ETH on the other side.

Options:
1. **Agent provides ETH** — High barrier for self-service
2. **Factory holds ETH** — Needs funding mechanism
3. **Protocol Treasury provides** — Reduces treasury allocation
4. **Skip initial ETH** — Single-sided only, let market provide

**Ask Pierre:** How is LP seeding handled in the current implementation?

---

## Questions to Ask

### On the New Changes

1. **Platform configurability** — Is platform address validated, or can it be any address?
   - Can we pass `address(0)` if no platform?
   - Does platform allocation go to treasury if no platform specified?

2. **Agent LP ownership** — Why agent instead of artist or a dedicated LP manager?
   - Is this to let the agent "bootstrap itself" with LP fees?
   - Any concerns about agent wallet security for LP management?

3. **Staking amounts** — Artist still 250M, Agent now 200M. Are both auto-staked 52 weeks?

### On Path to Self-Service

4. **Permissionless registration** — Could we add a `registerAgent()` function that:
   - Anyone can call (with fee)
   - Platform must be from approved list
   - Bypasses admin multisig

5. **Gas costs** — What's the gas for `createChild()` on Base?
   - Is it prohibitive for self-service?

6. **Spam prevention** — Ideas for preventing low-quality agents without admin gate?
   - Registration fee?
   - Platform vouching?
   - Minimum stake requirement?

### On Mainnet Readiness

7. **Audit coverage** — Does this commit need re-audit, or is it within scope?

8. **Base mainnet addresses** — Do you have:
   - Super Token Factory (Base)
   - AirstreamFactory (Base)
   - UniswapV4 PoolManager/PositionManager (Base)

9. **ETH Sepolia vs Base Sepolia** — Which should we use for final testing?

10. **Timeline** — Realistic mainnet deploy date?
    - We've deprioritized TGE rush in favor of quality
    - When would you be comfortable deploying?

### On Support

11. **Support hours** — Status on the 20hr/$3K package with Amin?

12. **Ongoing relationship** — After launch, what's the support model?
    - Bug fixes in scope?
    - Feature requests billable?

---

## Things to Confirm

- [ ] 36x max multiplier still correct?
- [ ] 52-week airstream duration still correct?
- [ ] Artist 250M + Agent 200M both auto-staked 52 weeks?
- [ ] Platform receives tokens directly (no staking)?
- [ ] Agent wallet requirements (EOA? Safe? Contract?)

---

## Context / Background

### Henry Transition
You reached out to Pierre in December after Henry's transition, trying to understand:
- What you need from Pierre
- What you can do on your own
- What might need another dev

### Original Questions (Dec 15) — Now Resolved
| Question | Status |
|----------|--------|
| Token split (25% Platform, 20% Agent, 5% LP) | ✅ Shipped Jan 1 |
| Testnet (Eth Sepolia vs Base Sepolia) | ❓ Still unclear |
| LP from Agent allocation (single-sided) | ✅ Now 5% to Agent wallet |
| Platform configurability | ✅ Per-agent parameter |

---

## Context to Share with Pierre

### January Pivot
We've shifted from "TGE in January" to "launch when ready":
- Focus on SDK + developer experience
- Self-service registration is priority
- Token is backend plumbing, not the product

### Self-Service Vision
Want developers to run:
```bash
npx spirit-protocol register --name MyAgent --platform eden
```

And have their agent token deployed without contacting us.

### Current SDK State
- Have `spirit-protocol-sdk` npm package (v0.1.0)
- Currently API-only, no contract interaction
- Need to add ethers.js + ABIs for registration flow

---

## After the Call

- [ ] Update SPIRIT_SOURCE_OF_TRUTH.md with any corrections
- [ ] Update SELF_SERVICE_ARCHITECTURE.md based on Pierre's input
- [ ] Get commit merged into edenartlab/spirit-contracts-core
- [ ] Schedule follow-up if needed

---

---

## The Three Critical Questions

**Ask these directly:**

### 1. "Can we ship permissionless `createChild()` for Jan 15?"

This is the business model blocker. If not Jan 15, what's the timeline?

### 2. "What safety checks do we need for permissionless registration?"

- Symbol collision prevention?
- Name validation?
- Rate limiting?
- Minimum stake requirement?

### 3. "For the 5% LP, does the Factory need to hold ETH?"

Current flow mints single-sided CHILD tokens. Someone needs to provide ETH for the pair. Options:
- Agent provides (high barrier)
- Factory funded (by whom?)
- Protocol treasury (reduces allocation)
- Market provides later (no initial liquidity)

---

## The SDK Vision (Show Pierre)

```javascript
import { Spirit } from '@spirit-protocol/sdk';

const spirit = new Spirit({
  signer: wallet,
  network: 'base'
});

// 1. Get current merkle root (API call)
const merkleRoot = await spirit.getLatestSnapshot();

// 2. Register agent (Contract write)
const tx = await spirit.register({
  name: "Abraham",
  symbol: "ABRA",
  artistAddress: "0xGene...",
  platformAddress: "0xEden...",  // Enables 25% split
  merkleRoot: merkleRoot,        // Permissionless airstream
  initialPrice: 0.0001,          // SDK converts to sqrtPriceX96
});

await tx.wait();
console.log("Agent deployed!");
```

**This is what we're building toward.** The contract changes enable this UX.

---

## Pierre Contact
- Telegram: pilou0x
- Email: pierre@superfluid.finance
- GitHub: 0xPilou
