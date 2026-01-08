# Pierre Call — One Pager

**Jan 8, 2026 | 8:30am CET**

---

## What You Already Shipped (Jan 1) ✅

- Platform address = parameter (not hardcoded)
- Split: 25 Artist / 20 Agent / 25 Platform / 25 Airstream / 5 LP
- Agent owns LP position
- Commit: `14be3752`

---

## What I Need to Understand

### 1. Token Split Terminology
Is "Airstream" = "Protocol Treasury"? Or different?

### 2. Which Addresses Are Canonical?
SDK has `0x53B9...` | Contracts repo has `0x879d...`

### 3. Deployer Wallet
Henry handed over: `deployer.spiritprotocol.eth` = `0xe4951bEE...`
This matches `ProtocolTreasury` in SDK. Confirm?

---

## The Big Ask: Self-Service

**Current:** `createChild()` requires admin role
**Goal:** Anyone can register by paying a fee

```solidity
function registerAgent(...) external payable {
    require(msg.value >= registrationFee);
    // ... rest of logic
}
```

### Can this ship by Jan 15?

If not, what's realistic timeline?

---

## Three Technical Questions

| Question | Context |
|----------|---------|
| **Safety checks?** | Symbol collision, rate limits for permissionless |
| **Who funds LP ETH?** | 5% is CHILD tokens. Who provides ETH side? |
| **Merkle root source?** | Can we build API that provides snapshot? |

---

## Future Standards to Explore

- **x402** — Coinbase HTTP payment protocol for agents
- **ERC-8004** — Onchain agent state storage

How do these fit with Spirit architecture?

---

## The SDK Vision

```javascript
await spirit.register({
  name: "Abraham",
  symbol: "ABRA",
  artistAddress: "0x...",
  platformAddress: "0xEden...",
  initialPrice: 0.0001  // SDK converts to sqrtPriceX96
});
```

No admin. Pay fee. Done.

---

## After Call: Update These

- [ ] SPIRIT_SOURCE_OF_TRUTH.md
- [ ] Canonical addresses
- [ ] Timeline for permissionless
- [ ] LP funding decision
