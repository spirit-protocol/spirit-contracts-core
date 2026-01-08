# Spirit Protocol — Pierre Sync
## January 8, 2026

---

# Slide 1: Goal

**Get self-service right, not fast.**

Jan 15 is off the table.

Let's design the architecture properly.

---

# Slide 2: What You Shipped (Jan 1) ✅

```
✅ Platform address = parameter (not hardcoded)
✅ New split: 25/20/25/25/5
✅ Agent owns LP position
```

**Commit:** `14be3752`

This is the foundation. Thank you.

---

# Slide 3: Current Token Split

| Recipient | % | Mechanism |
|-----------|---|-----------|
| Artist | 25% | Auto-staked 52w |
| Agent | 20% | Auto-staked 52w |
| Platform | 25% | Direct transfer |
| Airstream | 25% | Merkle drop to SPIRIT holders |
| LP | 5% | Uniswap position → Agent wallet |

**Q: Is this correct? Is "Airstream" same as "Protocol"?**

---

# Slide 4: Website vs Reality

| Website Says | Reality |
|--------------|---------|
| 25/25/25/25 split | Now 25/20/25/25/5 |
| "Hardcoded, immutable" | Just changed |
| SDK available | Not on npm |
| Register an agent | Admin-gated |
| Revenue routing | Testnet only |

**Gap:** Website is ahead of implementation.

---

# Slide 5: The Self-Service Vision

```javascript
await spirit.register({
  name: "MyAgent",
  symbol: "MYAG",
  artist: "0x...",
  platform: "0xEden...",
  initialPrice: 0.0001
});
```

**No admin. Pay fee. Done.**

---

# Slide 6: What's Blocking Self-Service

| Blocker | Current State |
|---------|---------------|
| Access control | `createChild()` requires admin role |
| Merkle root | Who generates it? When? |
| Pool init | Who supplies sqrtPriceX96? |
| Platform validation | Whitelist? Signature? Open? |

---

# Slide 7: Merkle Root — The Real Choke Point

**Three options:**

| Option | Pros | Cons |
|--------|------|------|
| **A: Registrant supplies** | Fully permissionless | Needs tooling + snapshot rule |
| **B: Admin posts later** | Simple | Delays airstream, centralized |
| **C: Switch to stakers** | No merkle needed | Product change |

**Which do you recommend?**

---

# Slide 8: Proposed Gating for Self-Service

```
register() wrapper around createChild()

Checks:
├── Fee paid (ETH or SPIRIT → Treasury)
├── Platform whitelisted OR signed
├── Optional: Artist signature
└── Parameter sanity (name length, nonzero addresses)

Admin role only for:
├── Platform whitelist management
└── Emergency pause
```

---

# Slide 9: Contract Architecture

```
┌─────────────────────────────────────┐
│         SpiritFactory               │
│  ┌─────────────────────────────┐    │
│  │ register() ← permissionless │    │
│  │     ↓                       │    │
│  │ _createChild() ← internal   │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
            ↓
┌─────────────────────────────────────┐
│  Per-Agent Infrastructure           │
│  ├── ChildToken (1B supply)         │
│  ├── StakingPool (GDA)              │
│  ├── Uniswap V4 Pool                │
│  └── Airstream (merkle)             │
└─────────────────────────────────────┘
```

---

# Slide 10: Questions for You

1. **Merkle strategy** — A, B, or C?

2. **Gating mechanism** — Fee + whitelist enough?

3. **LP funding** — Who provides ETH side?

4. **Timeline** — What's realistic for self-service done right?

5. **Sequencing** — What ships first?

---

# Slide 11: Proposed Sequencing

| Phase | Scope | Estimate |
|-------|-------|----------|
| **1** | Platform + LP changes (done?) | ✅ |
| **2** | Register wrapper + fee gate | ? weeks |
| **3** | Merkle tooling / airstream | ? weeks |
| **4** | SDK + npm publish | ? weeks |
| **5** | Mainnet deploy | ? |

**What's your estimate?**

---

# Slide 12: Standards to Explore

**x402** — Coinbase HTTP payment protocol
- Agents pay for services via HTTP 402
- Spirit Treasury as funding source

**ERC-8004** — Onchain agent state storage
- Standardized agent identity
- Fits with Spirit Registry

**Worth integrating?**

---

# Slide 13: Wallet Addresses (Henry Handover)

| ENS | Address |
|-----|---------|
| deployer.spiritprotocol.eth | `0xe4951bEE...` |
| signer.spiritprotocol.eth | `0x1C848ad8...` |
| spiritprotocol.eth | `0x5D6D8518...` |

**Q: Which addresses are canonical for testnet?**

SDK has different addresses than contracts repo.

---

# Slide 14: Decisions to Lock Today

| Decision | Your Answer |
|----------|-------------|
| Merkle strategy (A/B/C) | |
| Gating (fee + whitelist?) | |
| LP ETH funding | |
| Realistic timeline | |
| Who owns what work | |

---

# Slide 15: Next Steps

- [ ] Lock decisions from this call
- [ ] PR checklist for changes
- [ ] Base Sepolia test date
- [ ] Update website to match reality
- [ ] SDK npm publish

---

# Thank You

**Quality > Speed**

Let's build self-service right.
