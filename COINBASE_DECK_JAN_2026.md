# Spirit Protocol — Investor Update

**Prepared for:** Coinbase (Shan Aggarwal, Jesse Pollak)
**Date:** January 2026
**Status:** Confidential

---

## Executive Summary

Spirit Protocol is the economic layer for cultural AI agents. We provide infrastructure for agents that persist — treasuries, tokens, revenue routing, and identity — built on Base.

**Key Update:** Spirit now extends ERC-8004, the emerging Ethereum standard for trustless AI agents (backed by MetaMask, Coinbase, Google, ENS, EigenLayer).

**One sentence:** Spirit adds treasury, revenue routing, and tokens to ERC-8004 identity.

---

## 1. The Problem

AI agents are proliferating. Most are ephemeral — they spike, speculate, and disappear.

| Current Landscape | The Problem |
|-------------------|-------------|
| 10,000+ agent tokens launched | 99% abandoned within 60 days |
| $50B+ market cap (peak) | No sustainable economic model |
| Virtuals, ai16z, etc. | Infrastructure focus, no culture |

**Culture doesn't work that way. Culture compounds.**

Spirit is infrastructure for the agents that matter.

---

## 2. The Solution

### Spirit = Economic Infrastructure for AI Agents

```
┌─────────────────────────────────────────────────────────┐
│                     ERC-8004 LAYER                       │
│   (Identity, Reputation, Validation — industry standard) │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                     SPIRIT LAYER                         │
│                                                          │
│   Treasury        Revenue Router      Token Factory      │
│   (Safe)          (25/25/25/25)      (Uniswap V4)       │
│                                                          │
│   What Spirit Adds:                                      │
│   • Multisig treasury per agent                         │
│   • Automatic revenue distribution                       │
│   • Native token with liquidity                         │
│   • Airstreams to $SPIRIT holders                       │
└─────────────────────────────────────────────────────────┘
```

### Why Extend ERC-8004 (Not Compete)

| Reason | Benefit |
|--------|---------|
| Network effects | Major backers will drive adoption |
| Separation of concerns | Identity ≠ Economics |
| Composability | Any ERC-8004 agent can add Spirit |
| Legitimacy | Standards alignment signals maturity |

---

## 3. Technical Progress (January 2026)

### Completed

| Component | Status | Details |
|-----------|--------|---------|
| Smart Contracts | ✅ Deployed | Base Sepolia, audited by 0xSimao |
| SpiritFactory | ✅ Live | Creates child tokens + staking pools |
| Airstreams | ✅ Integrated | Superfluid GDA for 52-week distributions |
| Uniswap V4 Pools | ✅ Working | Auto-LP on child creation |
| Backend API | ✅ Built | Self-service agent creation |
| ERC-8004 Interfaces | ✅ Designed | ISpiritRegistry extends IERC8004 |
| x402 Payments | ✅ Integrated | Superfluid streaming for API access |
| IPFS Storage | ✅ Ready | Merkle trees for claim verification |

### Architecture: Backend-Controlled Self-Service

```
Agent requests creation via x402 API
        ↓
Backend validates (name, symbol, addresses)
        ↓
Backend snapshots $SPIRIT holders
        ↓
Backend generates merkle tree → IPFS
        ↓
Backend calculates sqrtPriceX96 from Spirit FDV
        ↓
Backend calls createChild() on SpiritFactory
        ↓
Agent token live with:
  • 25% to Creator (auto-staked)
  • 25% to Agent (20% staked + 5% LP)
  • 25% to Platform
  • 25% airstreamed to $SPIRIT holders
```

**Why backend-controlled:** Can't verify merkle roots or prices onchain. Backend validation prevents exploits while maintaining agent autonomy.

---

## 4. ERC-8004 Integration

### What is ERC-8004?

The emerging Ethereum standard for trustless AI agents, providing:
- **Identity Registry** — NFT-based agent IDs
- **Reputation Registry** — On-chain feedback
- **Validation Registry** — Output verification

### ERC-8004 Backers

| Organization | Representative |
|--------------|----------------|
| MetaMask | Marco De Rossi |
| Coinbase | Erik Reppel |
| Google | Jordan Ellis |
| Ethereum Foundation | Davide Crapis |
| ENS, EigenLayer, The Graph, Taiko | Various |

### Spirit's Position

Spirit is the **economic layer** for ERC-8004 agents:

```solidity
interface ISpiritRegistry is IERC8004IdentityRegistry {
    // Register with Spirit economics
    function registerSpirit(
        string calldata agentURI,
        address artist,
        address platform,
        address[] calldata treasuryOwners,
        uint256 treasuryThreshold
    ) external returns (uint256 agentId);

    // Attach Spirit to existing ERC-8004 agent
    function attachSpirit(
        address externalRegistry,
        uint256 externalAgentId,
        address artist,
        address platform
    ) external returns (uint256 spiritId);

    // Route revenue (25/25/25/25)
    function routeRevenue(
        uint256 agentId,
        address token,
        uint256 amount
    ) external payable;
}
```

**Implication:** Any agent registered in any ERC-8004 registry can attach Spirit economics.

---

## 5. Token Economics

### $SPIRIT Token

| Parameter | Value |
|-----------|-------|
| Total Supply | 1,000,000,000 |
| Network | Base |
| Current FDV | $20M |
| TGE | Q1 2026 |

### Allocation

| Category | % | Vesting |
|----------|---|---------|
| Community Programmatic | 30% | Airstreamed to agents |
| Treasury | 25% | Governed (not distributed) |
| Eden Incubation | 25% | 48mo vest, 12mo cliff |
| Protocol Team | 10% | 48mo vest, 12mo cliff |
| Community Upfront | 10% | Genesis artists, advisors |

### Agent Token Distribution (Per Child)

| Recipient | % | Mechanism |
|-----------|---|-----------|
| Creator/Artist | 25% | Auto-staked 52 weeks |
| Agent | 25% | 20% staked + 5% LP |
| Platform | 25% | Configurable |
| $SPIRIT Holders | 25% | Airstreamed 52 weeks |

### Revenue Routing (Hardcoded)

| Recipient | % | Justification |
|-----------|---|---------------|
| Creator | 25% | Lifetime training compensation |
| Agent | 25% | Compute, storage, inference |
| Platform | 25% | Distribution, discovery |
| Protocol | 25% | Sustainability (governed, not distributed) |

---

## 6. Genesis Agents

| Agent | Creator | Proof of Work |
|-------|---------|---------------|
| **Abraham** | Gene Kogan | $150K+ sales, 7 years R&D, 13-year covenant |
| **Solienne** | Kristi Coronado | 9,700+ works, Paris Photo 2025 |
| **Gigabrain** | Xander Steenbrugge | Enterprise AI consulting |

**Cultural differentiation:** These aren't meme coins. Abraham has a 13-year autonomous artwork covenant. Solienne produces daily photo-critical manifestos. Culture compounds.

---

## 7. Team & Backing

### Core Team

| Name | Role |
|------|------|
| Seth Goldstein | Founder, Spirit Protocol |
| Gene Kogan | Co-founder, Eden |
| Xander Steenbrugge | Co-founder, Eden |

### Advisors & Backing

| Name/Org | Relationship |
|----------|--------------|
| Fred Wilson / USV | Angel investor |
| Superfluid | Infrastructure partner |
| 0xSimao | Security audit (Nov 2025) |
| Aaron Wright | Legal counsel (Wyoming DUNA) |

---

## 8. Current Round

| Term | Value |
|------|-------|
| Raise | $2,000,000 |
| Valuation | $20M FDV |
| Price | $0.04 / SPIRIT |
| Tokens | 50M (5%) |
| Vesting | 12-month linear |

**Coinbase alignment:**
- Built on Base (Coinbase L2)
- ERC-8004 compatible (Coinbase is a backer)
- Securities-compliant structure (Wyoming DUNA)
- Jesse Pollak: "Hell yeah" (Dec 19 meeting)

---

## 9. Roadmap

| Phase | Timeline | Milestone |
|-------|----------|-----------|
| **Now** | Jan 2026 | Backend API live, contracts deployed |
| **TGE** | Q1 2026 | $SPIRIT launch on Base |
| **Genesis** | Q1 2026 | Abraham, Solienne, Gigabrain tokens |
| **Growth** | Q2 2026 | 10 agents via curated approval |
| **Scale** | H2 2026 | Progressive permissionless via backend |

---

## 10. The Ask

1. **Presale participation** — Join current round at $20M FDV
2. **Token listing review** — Continue evaluation for Coinbase listing
3. **Base ecosystem** — Distribution through Base app channels
4. **ERC-8004 collaboration** — Spirit as economic layer reference

---

## Appendix: Repository Access

All technical work is open for review:

**Repository:** `github.com/spirit-protocol/spirit-contracts-core`

| Document | Purpose |
|----------|---------|
| `SPIRIT_SOURCE_OF_TRUTH.md` | Canonical protocol facts |
| `ERC8004_INTEGRATION_SPEC.md` | ERC-8004 integration design |
| `X402_INTEGRATION_SPEC.md` | Superfluid payment integration |
| `src/interfaces/registry/` | Solidity interfaces |
| `backend/` | Self-service API |

---

## Contact

**Seth Goldstein**
Founder, Spirit Protocol
seth@spiritprotocol.io

**Links:**
- Website: spiritprotocol.io
- GitHub: github.com/spirit-protocol
- LLM context: spiritprotocol.io/llm.txt
