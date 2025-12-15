# Spirit Protocol ↔ Superfluid Handoff
**Prepared:** December 14, 2025
**TGE:** January 15, 2026 (32 days)
**Contact:** Seth Goldstein

---

## Summary

Spirit Protocol is launching SPIRIT token on Base. Superfluid is a key infrastructure partner with two allocations totaling 10M SPIRIT (1% of supply). We need to coordinate on contract deployment, vesting setup, and the staker streaming program.

---

## What We're Providing to Superfluid

### 1. Testnet Addresses (Base Sepolia)

| Contract | Address |
|----------|---------|
| SPIRIT Token | `0xc7e9de362C6eA2Cc03863ECe330622146Ff1c18B` |
| Reward Controller | `0x1390A073a765D0e0D21a382F4F6F0289b69BE33C` |
| Staking Pool Beacon | `0x6A96aC9BAF36F8e8b6237eb402d07451217C7540` |
| Spirit Factory | `0x879d67000C938142F472fB8f2ee0b6601E2cE3C6` |
| Vesting Factory | `0x94bea63d6eC10AF980bf8C7aEFeE04665D355AFe` |

### 2. Superfluid Allocations

| Allocation | Amount | % of Supply | Mechanism |
|------------|--------|-------------|-----------|
| Superfluid DAO | 5,000,000 SPIRIT | 0.5% | Direct transfer to DAO multisig |
| Superfluid Stakers | 5,000,000 SPIRIT | 0.5% | 1-year streaming program to SUP stakers |

**Total:** 10,000,000 SPIRIT (1% of 1B supply)

### 3. Vesting Schedule (Attached)

See `vesting_schedule.csv` for complete recipient list:
- **35 recipients** across 4 buckets
- **Vesting pattern:** 12-month cliff (20% unlocks Jan 15, 2027) + 36-month linear stream
- **Cliff amount calculation:** 20% of total allocation
- **End date:** January 15, 2030

The Superfluid allocations are from Treasury bucket (no cliff/vesting - operational distribution).

### 4. Contract Constants (Hardcoded)

```
StakingPool.sol:
- MIN_MULTIPLIER = 10,000 (1x)
- MAX_MULTIPLIER = 360,000 (36x) ← NEEDS CONFIRMATION
- MINIMUM_LOCKING_PERIOD = 1 week
- MAXIMUM_LOCKING_PERIOD = 156 weeks (3 years)
- STAKEHOLDER_LOCKING_PERIOD = 52 weeks
- STAKEHOLDER_AMOUNT = 250M

SpiritFactory.sol:
- CHILD_TOTAL_SUPPLY = 1B
- DEFAULT_LIQUIDITY_SUPPLY = 250M
- AIRSTREAM_SUPPLY = 250M
- AIRSTREAM_DURATION = 52 weeks ← NEEDS CONFIRMATION
- DEFAULT_POOL_FEE = 1%
```

---

## What We Need from Superfluid

### 1. DAO Multisig Address
**Priority: HIGH**
We need the Superfluid DAO multisig address on Base to send the 5M SPIRIT allocation at TGE.

### 2. Confirmation on Contract Constants
**Priority: HIGH**
Please confirm these values are correct before mainnet deployment:
- `MAX_MULTIPLIER = 360,000` (36x) — Is this the intended max staking boost?
- `AIRSTREAM_DURATION = 52 weeks` — Correct for agent token streaming?

### 3. SUP Staker Program Setup
**Priority: MEDIUM (Post-TGE)**
- How should the 5M SPIRIT → SUP staker streaming work?
- Do you have existing infrastructure for this, or do we deploy?
- Timeline for staker program activation?

### 4. Agent Token Distribution / LP Question
**Priority: MEDIUM**
- When an agent launches a child token, how should LP be seeded?
- Default 250M liquidity supply - correct allocation?

### 5. Testnet Walkthrough
**Priority: LOW**
- Can we schedule a testnet walkthrough before mainnet deploy?
- Suggested: Week of Dec 21-28 or Jan 1-12

---

## Timeline Constraints

| Date | Milestone |
|------|-----------|
| Dec 15-20 | NYC Fundraising Week |
| Dec 21-28 | Base Sepolia dry-run |
| Jan 1-12 | Final contract testing |
| **Jan 15** | **TGE - Mainnet deploy** |
| Jan 15+ | Vesting contracts created |
| Q1 2026 | SUP staker program activation |

**Hard deadline:** All contract constants must be confirmed by **Jan 10** to allow final testing before TGE.

---

## Attachments

1. `config/tokenomics.json` - Machine-readable tokenomics
2. `config/vesting_schedule.csv` - Individual allocations (35 rows)
3. Contract audit report (0xSimao, Nov 28, 2025)

---

## Contact

**Seth Goldstein**
Spirit Protocol / Eden
[Preferred contact method]

**Henry Pye**
Smart Contracts Lead
[Technical questions]

---

*Spirit Protocol: Infrastructure for Autonomous Artists*
