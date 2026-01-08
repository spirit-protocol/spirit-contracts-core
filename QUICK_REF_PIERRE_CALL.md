# Quick Reference — Pierre Call (15 min)

## Wallet Addresses (From Henry Handover)

| ENS | Address | Funds |
|-----|---------|-------|
| spiritprotocol.eth | `0x5D6D8518A1d564c85ea5c41d1dc0deca70F2301C` | 0.001 ETH (Base) |
| signer.spiritprotocol.eth | `0x1C848ad8Af40c911833A2963BE69973935C53C29` | 0.09 ETH |
| deployer.spiritprotocol.eth | `0xe4951bEE6FA86B809655922f610FF74C0E33416C` | 0.002 ETH |

**Note:** `deployer` address matches `ProtocolTreasury` in SDK!

---

## The 3 Questions (Ask These)

1. **Can permissionless `createChild()` ship by Jan 15?**

2. **What safety checks for permissionless?**
   - Symbol collision?
   - Rate limits?

3. **Who provides ETH for LP?**
   - Current: Single-sided CHILD only
   - Need: ETH for Uniswap pair

---

## Token Split to Confirm

Pierre implemented:
```
Artist:    25% (250M) - staked
Agent:     20% (200M) - staked
Platform:  25% (250M) - direct transfer
Airstream: 25% (250M) - merkle drop
LP:         5% (50M)  - agent owns position
```

**Q: Is "Airstream" same as "Protocol Treasury"?**

---

## What Pierre Already Did ✅

- Platform address = parameter (not hardcoded)
- Agent owns LP position
- Commit: `14be3752`

---

## What You Want

```javascript
// Self-service registration
await spirit.register({
  name: "Abraham",
  symbol: "ABRA",
  artistAddress: "0x...",
  platformAddress: "0xEden...",
  initialPrice: 0.0001
});
```

No admin gate. Pay fee. Done.

---

## Contract Addresses (Clarify Which Are Current)

**SDK has:**
- SpiritFactory: `0x53B9db3DCF3a69a0F62c44b19a6c37149b7fB93b`
- ProtocolTreasury: `0xe4951bEE6FA86B809655922f610FF74C0E33416C` ← matches deployer.eth!

**spirit-contracts-core has:**
- SpiritFactory: `0x879d67000C938142F472fB8f2ee0b6601E2cE3C6`

**Ask:** Which Base Sepolia deployment is current?
