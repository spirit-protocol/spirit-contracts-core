# Pierre Call Script — Jan 8, 8:30am CET

---

## Say This First (2 min)

> "Quick recap so we're on the same page:
> We confirmed the multiplier curve (1w=1x, 52w≈12x, 156w=36x) and we're using SpiritVesting/Factory.
>
> What's blocking us now is:
> (a) token distribution — Platform allocation + LP sizing from Agent allocation
> (b) moving from admin-gated to self-service registration
>
> The other blockers are merkle-root for the SPIRIT-holder airstream and safe Uniswap pool init."

---

## Key Message to Pierre

> **"Jan 15 is not realistic, and that's OK. It's more important to get this right than right now. Let's design for self-service properly."**

This removes time pressure and lets you focus on architecture.

---

## 4 Decisions I Need Today

| # | Decision | Notes |
|---|----------|-------|
| 1 | Platform allocation — per-agent configurable? | |
| 2 | Permissionless `createChild()` — what gating? | |
| 3 | Merkle root strategy — who generates, when? | |
| 4 | Pool init — default sqrtPriceX96 or registrant supplies? | |

---

## Questions by Topic

### A. Token Distribution (5 min)

1. "Is Platform allocation now part of agent token mint at 25%?"
2. "LP seeding comes from Agent's 25% (20% staked + 5% LP) — agree?"
3. "Platform per-agent configurable, or hardcode Eden for v1?"
4. "Who owns the LP position NFT?" (Agent? Treasury? Platform?)

### B. Permissionless Self-Service (8 min)

5. "Can we make agent creation permissionless via `register()` wrapper?"
6. "What gating mechanism?"
   - Fee gate (ETH/SPIRIT to treasury)
   - Platform whitelist + signature
   - Artist signature
7. "What's minimal admin involvement?" (Goal: admin only for whitelist + pause)

### C. Merkle Root / Airstream (5 min)

8. "Who generates and posts the merkle root?"

**Three options to propose:**
- **Option 1:** Registrant provides merkleRoot (needs published snapshot tooling)
- **Option 2:** Admin posts merkleRoot after launch (airstream starts later)
- **Option 3:** Switch to SPIRIT stakers (GDA) instead of holders (no merkle needed)

9. "Does Superfluid have standard tooling for merkle root generation?"

### D. Uniswap Pool Init (3 min)

10. "Can we use deterministic default (1:1 vs SPIRIT) or must registrant supply sqrtPriceX96?"
    - If registrant supplies: "SDK helper to compute from human-friendly price?"
    - "Min/max bounds to prevent nonsense?"

### E. Timeline (2 min)

11. "Base Sepolia for everything, or also Ethereum Sepolia?"
12. "Jan 15 is off the table. What's realistic for self-service done right?"
13. "What's the sequencing — what ships first, second, third?"

---

## If Pierre Says... Respond With...

| Pierre Says | You Say |
|-------------|---------|
| "Merkle makes self-serve hard" | "Agreed. Pick one: (1) registrant supplies with published snapshot, (2) decouple launch from airstream, or (3) switch to stakers. Which ships fastest?" |
| "Permissionless createChild is risky" | "I'm not asking pure permissionless. I want a register wrapper with fee + whitelist + pause. What's the smallest gate set you'd accept?" |
| "Platform allocation can't be per-agent yet" | "OK — hardcode Eden for v1, but design storage so it upgrades later." |

---

## Token Split (Desired State)

```
Creator:        25%  →  auto-staked 52w
Platform:       25%  →  liquid, to platform address
Agent:          25%  →  20% staked + 5% LP (NFT to agent wallet)
SPIRIT Holders: 25%  →  airstreamed 52w via merkle
```

**Public framing:** "25% × 4" — LP is implementation detail inside Agent's 25%

---

## Close the Call (Last 2 min)

1. "Can we lock decisions on (a) platform allocation, (b) merkle strategy, (c) register gating today?"
2. "Who owns each change — Pierre vs Spirit core?"
3. "What's fastest sequencing?"
   - Step 1: Platform + LP changes in factory
   - Step 2: Register wrapper + fee gate
   - Step 3: Merkle/airstream workflow
4. "Can we leave with a PR checklist and Base Sepolia test date?"

---

## The Real Blocker

**Merkle root generation is the centralization choke point.**

Unless you:
- Require registrants to supply it, OR
- Decouple launch from airstream, OR
- Change design to stakers instead of holders

Get this decision today. Rest is straightforward engineering.

---

## Standards to Mention (If Time)

- **x402** — Coinbase HTTP payments for agents
- **ERC-8004** — Onchain agent state storage

"Have you looked at these? How might they fit?"
