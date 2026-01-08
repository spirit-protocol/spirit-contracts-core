# x402 Integration Spec — Spirit Protocol

**Created:** January 8, 2026
**Source:** Pierre call + https://x402.superfluid.org/
**Status:** PLANNING

---

## What is x402?

HTTP 402 "Payment Required" — a standardized way for AI agents to pay for API services.

**Key Features:**
- Zero gas for callers (EIP-712 signatures)
- Real-time streaming payments (Superfluid native)
- Built for autonomous agent economy
- No upfront costs, pay-as-you-use

**Documentation:** https://x402.superfluid.org/

---

## Why x402 for Spirit?

| Problem | x402 Solution |
|---------|---------------|
| Agents can't pay gas | x402 is gasless |
| API monetization | Per-request streaming payment |
| Spam prevention | Payment = spam resistance |
| Agent autonomy | Agents pay from their treasury |

---

## Spirit Use Cases

### 1. Agent Registration API

Agents pay via x402 to create child tokens.

```
Agent → Opens stream to Spirit treasury
      → Calls POST /v1/agents/create
      → Backend verifies stream, creates child
      → Agent gets token without paying gas
```

### 2. Revenue Routing API

Agents can use x402 to trigger revenue distribution.

```
Agent → Receives payment
      → Calls POST /v1/revenue/distribute
      → Backend routes to Artist/Platform/Protocol
      → Agent pays small x402 fee for the service
```

### 3. Treasury Operations

Spirit Treasury could fund agent x402 payments.

**Pierre question:** Can Spirit Treasury fund agent x402 payments?

This would enable:
- Protocol-subsidized agent operations
- Onboarding without agent having capital
- "Free tier" for early agents

---

## Technical Integration

### x402 Payment Flow

```
┌─────────────────┐
│   AI Agent      │
│  (has treasury) │
└────────┬────────┘
         │
         │ 1. Open Superfluid stream to Spirit
         ▼
┌─────────────────┐
│ Superfluid GDA  │
│ or CFA Stream   │
└────────┬────────┘
         │
         │ 2. Include stream proof in API call
         ▼
┌─────────────────┐
│ Spirit Backend  │
│   x402 Middleware│
└────────┬────────┘
         │
         │ 3. Verify stream active + sufficient rate
         │ 4. Process request
         │ 5. Stream continues per-second
         ▼
┌─────────────────┐
│ Spirit Treasury │
│ (receives flow) │
└─────────────────┘
```

### Middleware Implementation

```typescript
import { verifyX402Payment } from '@superfluid/x402';

const x402Middleware = async (req, res, next) => {
  const paymentHeader = req.headers['x-402-payment'];

  if (!paymentHeader) {
    return res.status(402).json({
      error: 'Payment Required',
      protocol: 'x402',
      recipient: SPIRIT_TREASURY_ADDRESS,
      minFlowRate: MIN_FLOW_RATE,
      token: USDC_ADDRESS,  // or SPIRIT
      instructions: 'Open Superfluid stream to continue'
    });
  }

  const verification = await verifyX402Payment(paymentHeader, {
    recipient: SPIRIT_TREASURY_ADDRESS,
    minFlowRate: MIN_FLOW_RATE,
    token: USDC_ADDRESS
  });

  if (!verification.valid) {
    return res.status(402).json({
      error: verification.reason
    });
  }

  req.x402 = verification;
  next();
};
```

### Payment Rates

| Operation | Suggested Rate | Per |
|-----------|----------------|-----|
| Agent creation | 10 USDC | Request |
| Revenue distribution | 0.01 USDC | Request |
| Status queries | Free | - |
| Merkle proofs | Free | - |

**Note:** Rates TBD — balance spam prevention with accessibility.

---

## Stream Configuration

### For Agent Registration

```typescript
// Agent opens stream before calling API
const createAgentStream = async (agent: Agent) => {
  const sf = await Framework.create({
    chainId: 8453,  // Base
    provider
  });

  const createOp = sf.cfaV1.createFlow({
    sender: agent.treasury,
    receiver: SPIRIT_TREASURY,
    flowRate: '385802469135802',  // ~1000 USDC/month
    superToken: USDCx.address
  });

  await createOp.exec(agent.signer);
};
```

### Stream Lifecycle

1. **Open:** Agent opens stream before first API call
2. **Active:** Stream runs continuously while agent operates
3. **Close:** Agent closes stream when done (or stream continues for ongoing access)

---

## Open Questions

### For Pierre

1. **Token for payment:** USDC, SPIRIT, or choice?
2. **Flow rate calculations:** How to price per-request?
3. **Treasury as funder:** Can Spirit Treasury subsidize agent x402?
4. **Existing tooling:** Any Superfluid x402 examples?

### Architecture

1. **Stream duration:** Per-request or ongoing subscription?
2. **Batch operations:** Discount for bulk requests?
3. **Free tier:** Protocol-subsidized for early agents?

---

## Implementation Phases

### Phase 1: Internal Only

- No x402 yet
- Backend calls are internal/trusted
- Manual agent creation

### Phase 2: x402 for Registration

- Public API with x402 payment
- Agent registration via streaming payment
- Basic rate limiting

### Phase 3: Full x402 Economy

- All API operations x402-enabled
- Treasury subsidies for qualifying agents
- Usage-based pricing tiers

---

## Security Considerations

1. **Stream Verification**
   - Check stream is active (not cancelled)
   - Verify sufficient flow rate
   - Confirm recipient is Spirit Treasury

2. **Rate Limiting**
   - Still apply per-address limits
   - Payment doesn't bypass all limits
   - Prevent abuse even with payment

3. **Refunds**
   - Streams are real-time, no refunds needed
   - If request fails, agent stops paying immediately
   - No held funds to return

---

## Resources

- **x402 Docs:** https://x402.superfluid.org/
- **Superfluid Docs:** https://docs.superfluid.finance/
- **EIP-712:** Typed structured data signing
- **Base Network:** https://base.org/

---

## Related Documents

- `BACKEND_ARCHITECTURE.md` — Overall backend design
- `SPIRIT_SOURCE_OF_TRUTH.md` — Canonical parameters
- `PIERRE_CALL_NOTES.md` — Call where x402 was discussed

---

*x402 enables the permissionless agent economy — agents pay for services, not humans.*
