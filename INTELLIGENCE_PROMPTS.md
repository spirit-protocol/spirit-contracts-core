# Intelligence Gathering Prompts

**Purpose**: Queries to run against ChatGPT history, Granola notes, Limitless transcripts
**Database**: `/Users/seth/openai-chat-service/data/conversations.db`

---

## How to Use

### Search Database Directly
```bash
cd ~/openai-chat-service
node bin/cli.js search "pierre superfluid"
node bin/cli.js search "smart contract split"
node bin/cli.js search "self service agent"
```

### Export and Ask ChatGPT/Claude
```bash
node bin/cli.js export-context "spirit protocol" --limit 50 > spirit_context.txt
# Then paste into ChatGPT with prompt below
```

### Granola Meeting Search
```bash
node bin/cli.js granola-search "pierre" --start-date 2025-12-01
```

---

## Prompts by Topic

### 1. Pierre/Superfluid Conversation History

**For searching transcripts:**
```
Search for: "pierre" OR "superfluid" OR "pilou" OR "token split" OR "platform allocation"
Date range: December 2025 - January 2026
```

**For ChatGPT/Claude analysis:**
```
I'm preparing for a call with Pierre from Superfluid about Spirit Protocol smart contracts.

Based on our conversation history, help me understand:
1. What questions did I ask Pierre that haven't been answered?
2. What did Pierre confirm vs what's still outstanding?
3. Any technical concerns or blockers Pierre mentioned?
4. What was the last state of the token split discussion (25% Platform, 20% Agent, 5% LP)?

Context: Pierre (0xPilou on GitHub) built our Superfluid-based contracts. We're discussing modifications for a 4-way token split and path to self-service registration.
```

### 2. Self-Service Architecture Decisions

**For searching:**
```
Search for: "permissionless" OR "self service" OR "registration fee" OR "agent onboarding" OR "SDK"
```

**For analysis:**
```
I'm designing a self-service registration system for Spirit Protocol where any developer can register an AI agent without contacting our team.

Search my conversations for any discussions about:
1. Permissionless vs gated registration tradeoffs
2. Fee structures for protocol registration
3. How other protocols (Virtuals, ai16z, etc.) handle agent registration
4. Concerns about spam or low-quality agents
5. Platform curation vs open registration

Summarize the key decisions and any unresolved debates.
```

### 3. Token Economics Decisions

**For searching:**
```
Search for: "token split" OR "25%" OR "platform allocation" OR "airstream" OR "merkle"
```

**For analysis:**
```
Spirit Protocol uses a 4-way token split for agent tokens: Creator/Agent/Platform/Protocol.

Search my conversations for:
1. How we arrived at the 25/25/25/25 split
2. Any debates about different percentages
3. Discussion of platform allocation (who qualifies as a platform?)
4. Airstream mechanics and who receives them
5. Feedback from investors/advisors on the split

I need to understand the reasoning to explain it to Pierre and potentially modify the contracts.
```

### 4. Superfluid Technical Details

**For searching:**
```
Search for: "GDA" OR "superfluid" OR "streaming" OR "flow rate" OR "airstream factory"
```

**For analysis:**
```
Our Spirit Protocol smart contracts use Superfluid for token streaming (GDA pools, airstreams, vesting).

Find any technical discussions about:
1. Why we chose Superfluid over alternatives
2. Gas cost concerns with Superfluid
3. Any issues or gotchas Pierre mentioned
4. How the staking pool GDA distribution works
5. Airstream claiming mechanics

I need to understand the technical architecture deeply for the Pierre call.
```

### 5. SDK and Developer Experience

**For searching:**
```
Search for: "SDK" OR "developer experience" OR "npm" OR "CLI" OR "MCP server" OR "claude code integration"
```

**For analysis:**
```
We're building an SDK for Spirit Protocol to make agent registration easy.

Search for discussions about:
1. What the SDK should include
2. CLI vs programmatic interface preferences
3. MCP server integration for Claude Code
4. How developers currently onboard agents
5. Pain points in the current registration flow

I want to design an SDK that solves real developer problems.
```

### 6. Competitor/Market Intelligence

**For searching:**
```
Search for: "virtuals" OR "ai16z" OR "eliza" OR "agent framework" OR "competitor"
```

**For analysis:**
```
Spirit Protocol competes in the AI agent infrastructure space.

Search my conversations for:
1. How Virtuals Protocol handles agent registration
2. ai16z/Eliza framework approach
3. Any discussions comparing Spirit to competitors
4. What makes Spirit different (cultural agents, revenue routing)
5. Gaps in competitor offerings we could fill

I need competitive intelligence for positioning discussions.
```

### 7. Legal/Securities Concerns

**For searching:**
```
Search for: "securities" OR "legal" OR "Aaron Wright" OR "DUNA" OR "token classification"
```

**For analysis:**
```
Spirit Protocol has a token ($SPIRIT) and we need to avoid securities issues.

Search for discussions about:
1. How we're structuring to avoid security classification
2. Aaron Wright's guidance
3. Wyoming DUNA structure
4. Language we should/shouldn't use
5. How self-service registration affects legal posture

Summarize any legal constraints on the architecture.
```

### 8. Timeline and Priorities

**For searching:**
```
Search for: "TGE" OR "launch" OR "January" OR "timeline" OR "priority" OR "blocker"
```

**For analysis:**
```
Spirit Protocol has been targeting a Q1 2026 launch.

Search for:
1. Current TGE timeline expectations
2. What's blocking launch
3. Priority order of remaining work
4. Any discussions about delaying for quality
5. Dependencies on Pierre/Superfluid

What's the realistic path to launch and what must happen first?
```

---

## Quick Database Queries

```bash
# Recent Pierre conversations
cd ~/openai-chat-service
node bin/cli.js search "pierre" --since 2025-12-01

# Smart contract discussions
node bin/cli.js search "smart contract" --since 2025-11-01

# SDK mentions
node bin/cli.js search "SDK" --since 2025-10-01

# Self-service/permissionless
node bin/cli.js search "permissionless OR self-service"

# Token split discussions
node bin/cli.js search "token split OR platform allocation"

# Export everything Spirit-related for deep analysis
node bin/cli.js export-context "spirit protocol" --limit 100 > ~/spirit_full_context.txt
```

---

## Granola Meeting Queries

```bash
# Recent meetings mentioning Pierre
node bin/cli.js granola-search "pierre" --start-date 2025-12-01

# Contract discussions
node bin/cli.js granola-search "contract" --start-date 2025-12-01

# All Spirit meetings
node bin/cli.js granola-search "spirit" --start-date 2025-11-01
```

---

## Composite Analysis Prompt

**Use this after gathering context from multiple sources:**

```
I'm about to have a call with Pierre from Superfluid about Spirit Protocol smart contracts. Here's context from my conversation history, meeting notes, and current documentation.

[PASTE CONTEXT HERE]

Help me prepare by answering:

1. **Current State**: What's actually deployed vs what's planned?

2. **Open Questions**: What did I ask Pierre that hasn't been answered?

3. **Technical Decisions**: What contract changes are needed for:
   - Platform allocation (25%)
   - Self-service registration
   - Configurable token splits

4. **Blockers**: What's preventing progress?

5. **Talking Points**: What should I bring up on the call?

6. **Risk Areas**: Any technical or business risks I should address?

Format as a one-page briefing doc I can reference during the call.
```

---

## Post-Call Prompt

**After the Pierre call:**

```
I just had a call with Pierre from Superfluid. Here are my notes:

[PASTE NOTES]

Help me:
1. Extract action items (mine vs Pierre's)
2. Identify decisions that were made
3. Flag any changes to previously agreed items
4. Update the SPIRIT_SOURCE_OF_TRUTH.md with new information
5. Draft follow-up message to Pierre confirming what we discussed
```

---

*Created January 7, 2026 for Pierre call prep*
