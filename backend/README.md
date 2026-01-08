# Spirit Protocol Backend

Self-service API for agent creation on Spirit Protocol.

## Architecture

Backend-controlled self-service per Pierre's recommendation (Jan 8, 2026):

```
Agent → x402 API → Backend → Contract (admin-protected)
```

**Why backend-controlled:**
- Can't verify merkle root correctness onchain
- Can't verify sqrtPriceX96 correctness onchain
- Permissionless contracts = attack surface
- Backend validates everything before calling contract

## Services

| Service | Description |
|---------|-------------|
| **Snapshot** | Captures Spirit holder balances at a block |
| **Merkle** | Generates merkle trees for airstream claims |
| **Price** | Calculates sqrtPriceX96 for Uniswap V4 |
| **Validation** | Rate limiting, parameter checks, platform approval |
| **x402** | Payment verification via Superfluid streams |

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment config
cp .env.example .env

# Run in development mode
npm run dev

# Build for production
npm run build
npm start
```

## API Endpoints

### Health

- `GET /health` - Basic health check
- `GET /health/detailed` - Service status
- `GET /info` - Service information

### Agents

- `POST /v1/agents/create` - Create agent (x402 payment required if enabled)
- `GET /v1/agents/:symbol` - Get agent by symbol
- `GET /v1/agents` - List all agents

### Snapshots

- `POST /v1/snapshots` - Take new snapshot
- `GET /v1/snapshots/:id` - Get snapshot metadata
- `GET /v1/snapshots/:id/holders` - Get holders from snapshot

### Merkle

- `GET /v1/merkle/:treeId` - Get tree metadata
- `GET /v1/merkle/:treeId/proof/:address` - Get merkle proof for claiming
- `POST /v1/merkle/:treeId/verify` - Verify a proof
- `GET /v1/merkle/:treeId/export` - Export tree JSON

### Price

- `GET /v1/price/spirit` - Current Spirit price
- `GET /v1/price/sqrt` - Calculate sqrtPriceX96
- `POST /v1/price/sqrt/calculate` - Custom FDV calculation
- `POST /v1/price/sqrt/decode` - Decode sqrtPriceX96

## Creating an Agent

```bash
# Without x402 (development)
curl -X POST http://localhost:3000/v1/agents/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Agent",
    "symbol": "MYAG",
    "artist": "0x1234...",
    "agent": "0x5678...",
    "platform": "0xEden..."
  }'

# With x402 (production)
curl -X POST http://localhost:3000/v1/agents/create \
  -H "Content-Type: application/json" \
  -H "x-402-payment: {\"streamId\":\"...\",\"sender\":\"0x...\",\"flowRate\":\"1000000\",\"signature\":\"...\"}" \
  -d '{...}'
```

## sqrtPriceX96 Calculation

Based on [Uniswap V3 Book](https://uniswapv3book.com/milestone_1/calculating-liquidity.html):

```
sqrtPriceX96 = sqrt(childFdv / spiritFdv) * 2^96
```

Example: Spirit at $40K FDV, Child at $40K FDV:
- Ratio = 1:1
- sqrtPriceX96 = 2^96 = 79228162514264337593543950336

```bash
# Calculate sqrtPriceX96
curl http://localhost:3000/v1/price/sqrt?childFdv=40000

# Response
{
  "data": {
    "sqrtPriceX96": "79228162514264337593543950336",
    "priceRatio": 1,
    "spiritFdv": "40000",
    "childFdv": "40000"
  }
}
```

## x402 Integration

HTTP 402 Payment Required via [Superfluid x402](https://x402.superfluid.org/).

**Flow:**
1. Agent opens Superfluid stream to Spirit treasury
2. Agent makes API call with payment proof header
3. Backend verifies stream is active
4. Backend processes request

**Enable x402:**
```env
X402_ENABLED=true
X402_ACCEPTED_TOKEN=0x...  # USDCx or similar
X402_MIN_FLOW_RATE=1000    # Wei per second
X402_RECIPIENT=0x...       # Spirit treasury
```

## Rollout Phases

| Phase | Scope |
|-------|-------|
| **1** | First 10 children, manually approved, Eden = platform |
| **2** | Public API with x402, platform whitelist |
| **3** | Progressive decentralization, onchain criteria |

## Related Documentation

- [BACKEND_ARCHITECTURE.md](../BACKEND_ARCHITECTURE.md) - Full architecture spec
- [SPIRIT_SOURCE_OF_TRUTH.md](../SPIRIT_SOURCE_OF_TRUTH.md) - Canonical parameters
- [X402_INTEGRATION_SPEC.md](../X402_INTEGRATION_SPEC.md) - x402 details

## License

MIT
