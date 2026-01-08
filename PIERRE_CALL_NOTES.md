# Pierre Call Notes — Jan 8, 2026

## Key Confirmations

### Token Split ✅
- 5% LP comes from Agent's 25%
- LP position goes to Agent wallet
- Split is implemented in contract

### Spirit Token - NO CTA ✅
> "There is no action for Spirit. Spirit, you just hold it and farm child tokens. Staking is for child tokens."

**Securities implication:** Spirit doesn't generate revenue/dividends, just more tokens.

### Merkle Root Strategy ✅
- **Snapshot-based** at time of agent creation
- Backend takes snapshot of Spirit holders
- Backend generates merkle root
- If you hold Spirit at snapshot → you get child token airstream
- If you sell Spirit after snapshot → you still get that child's airstream
- If you sell before next agent → you miss next agent's airstream

**Incentive:** Hold Spirit to be eligible for ALL future agent launches

### Pool Initialization ✅
- Price ratio based on Spirit FDV
- Example: Spirit = 40K FDV, Child = 40K FDV → 1:1 ratio
- Need to express in sqrtPriceX96
- Backend service calculates from Spirit USD price

## Self-Service Architecture (Proposed)

```
Agent requests creation via API
        ↓
Backend receives request
        ↓
Backend takes snapshot (Spirit holders at that moment)
        ↓
Backend generates merkle root
        ↓
Backend calls contract (pays gas)
        ↓
Agent created - user didn't pay fees
```

## Timeline Discussion

- Jan 15 is NOT a deadline
- Quality > Speed
- Pre-sale may happen before children launch
- Coinbase conversations going well
- No gun to head for TGE

## x402 Integration (Superfluid Native!)

**https://x402.superfluid.org/**

- HTTP 402 payments for AI agents
- Zero gas (EIP-712 signatures)
- Real-time streaming
- Built for agentic economy

**Question for Pierre:** Can Spirit Treasury fund agent x402 payments?

This enables agents to:
- Pay for APIs/services autonomously
- Stream payments from their treasury
- Complete the "persist economically" loop

## sqrtPriceX96 Formula (RESOLVED)

**Source:** https://uniswapv3book.com/milestone_1/calculating-liquidity.html

```python
q96 = 2**96

def price_to_sqrtp(p):
    return int(math.sqrt(p) * q96)
```

**Pierre's explanation:**
1. Look at current USD value of Spirit
2. Calculate ratio between Spirit FDV and target Child FDV (40K)
3. Take square root of ratio
4. Multiply by 2^96

**Example:** Spirit = 40K FDV, Child = 40K FDV → ratio 1:1 → sqrtPriceX96 = 2^96

## LP Position Details

- **Single-sided position** in Child token only
- No ETH provided at initialization
- Buyers provide ETH when they purchase
- Price discovery happens via market

## Open Questions

- [ ] Backend infrastructure for snapshot service
- [ ] Gas funding for backend calls
- [ ] Rate limiting / spam prevention
- [ ] x402 integration with Spirit Treasury
- [ ] Pierre mentioned existing merkle repo — need to locate

## Key Decision: Backend Creates Children

**Pierre's recommendation:** Keep `createChild` admin-protected. Backend handles everything.

**Why:**
- Can't verify merkle root is correct onchain
- Can't verify sqrtPriceX96 is correct onchain
- Permissionless = potential vulnerability
- Backend can validate everything before calling contract

**Architecture:**
```
Agent calls API (pays via x402)
        ↓
Backend validates request
        ↓
Backend takes Spirit holder snapshot
        ↓
Backend generates merkle root
        ↓
Backend calculates sqrtPriceX96
        ↓
Backend calls createChild (pays gas)
        ↓
Agent token created
```

**x402 monetization:**
- Agent pays for backend API call via x402 streaming
- No need for register() wrapper in contract
- Keeps contracts tight and secure

## Rollout Strategy

1. **First 10 children** - Manually approved, Eden = platform
2. **After 10** - Progressively permissionless via backend rules
3. **Future** - Predetermined on-chain graduation criteria (like oracle/prediction market)

## Action Items

- [ ] Pierre sends sqrtPriceX96 calculation formula
- [ ] Build backend service for:
  - [ ] Spirit holder snapshot
  - [ ] Merkle root generation
  - [ ] Price calculation
- [ ] Integrate x402 for API monetization
- [ ] Align website with contract reality
- [ ] First 10 children planning with Eden
