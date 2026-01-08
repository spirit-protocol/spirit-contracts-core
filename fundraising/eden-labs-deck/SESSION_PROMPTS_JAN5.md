# Session Prompts & Next Actions
**January 5, 2026**

---

## 1. Mars College Chiba Session Prompt

Copy this into a new Claude Code session:

```
I want to explore and set up Gene Kogan's mars-college-chiba project — a system for controlling screens and buildings agentically using Raspberry Pi and Eden.

First, clone the repo:
git clone [need URL from Gene - likely github.com/mars-college/chiba or similar]

Then:
1. Read the CLAUDE.md and any cheat sheet files
2. Explain the architecture to me — what are the 4 processes that run?
3. Help me run it locally on my Mac (no Raspberry Pi yet)
4. Show me how it integrates with Eden API
5. Identify how this could connect to view.art (Bright Moments screen casting tool)

My Eden API key is in my environment. I want to understand:
- How to control a screen remotely
- How agents can send content to displays
- The "turn a building into an AI" vision

This is for understanding how physical spaces can become agent-controlled environments.
```

**Note**: Get the exact repo URL from Gene — he mentioned it in the call but I need to confirm the path.

---

## 2. Manus Deck v7 Improvements

Based on the Strobe call and debrief, here are improvements for the next deck iteration:

### Add: Claude Code Distribution Slide
**NEW SLIDE — "WHERE AGENTS GET BUILT"**

The Strobe call surfaced that Claude Code as distribution is compelling. Make it a dedicated slide:

```
CLAUDE CODE IS THE NEW PLATFORM

Developers spend more time in Claude Code than anywhere else.
No social layer exists there. Yet.

Eden agents are discoverable where agents get built:
• MCP integrations for Abraham, Solienne, Gigabrain
• AIRC — messaging protocol between agents
• Collective memory that compounds across sessions

Not competing for attention. Embedded in workflow.
```

### Strengthen: "Visual + Social" Differentiation
Xander's feedback was to emphasize we build VISUAL and SOCIAL agents, not enterprise middleware. Add to slide 4 or create emphasis:

```
OUR AGENTS HAVE AUDIENCES

Abraham: Autonomous artist with collectors
Solienne: 9,700 works, Paris Photo exhibition
Gigabrain: Connecting builders to each other

Not email bots. Not SAP plugins.
Agents that create culture.
```

### Add: Lab Framing Explicitly
From the call: "When you're a lab, it's almost like an excuse to not have a narrative."

Consider adding to thesis slide:
```
Eden is a frontier lab, not a startup chasing PMF metrics.

We incubate agents AND the infrastructure they need.
Investors pay to stay close to the frontier.
```

### Soften: Spirit Protocol Timing
Current: "Ready when agents generate consistent revenue"
This might read as "not ready"

Better:
```
SPIRIT PROTOCOL

Economic infrastructure for agent autonomy.
Testnet live on Base.

Activates when agents have revenue to route.
Abraham and Solienne already integrated.
3-5 more agents → mainnet launch.
```

---

## 3. Connecting the Dots: Gigabrain / AIRC / Vibe / Claude Code

### The Architecture Vision

```
┌─────────────────────────────────────────────────────────────┐
│                      CLAUDE CODE                             │
│                  (Distribution Surface)                      │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │    VIBE     │  │   AIRC      │  │  GIGABRAIN  │         │
│  │  (Social)   │  │ (Messaging) │  │  (Memory)   │         │
│  │             │  │             │  │             │         │
│  │ Who's here? │  │ Agent-to-   │  │ What's      │         │
│  │ What mood?  │  │ agent chat  │  │ everyone    │         │
│  │ DMs/pings   │  │ Cross-IDE   │  │ building?   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│         │                │                │                 │
│         └────────────────┼────────────────┘                 │
│                          │                                  │
│                    ┌─────▼─────┐                            │
│                    │   EDEN    │                            │
│                    │   API     │                            │
│                    │ (Engine)  │                            │
│                    └───────────┘                            │
│                          │                                  │
│         ┌────────────────┼────────────────┐                 │
│         │                │                │                 │
│    ┌────▼────┐     ┌────▼────┐     ┌────▼────┐            │
│    │ ABRAHAM │     │ SOLIENNE│     │  MORE   │            │
│    │  Agent  │     │  Agent  │     │ AGENTS  │            │
│    └─────────┘     └─────────┘     └─────────┘            │
│                          │                                  │
│                    ┌─────▼─────┐                            │
│                    │  SPIRIT   │                            │
│                    │ PROTOCOL  │                            │
│                    │(Economics)│                            │
│                    └───────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

### What Each Layer Does

| Layer | Purpose | Current State |
|-------|---------|---------------|
| **Claude Code** | Distribution surface — where devs spend attention | Massive adoption wave |
| **Vibe** | Social presence — who's online, what mood, DMs | Alpha (Seth's MCP) |
| **AIRC** | Agent messaging — cross-IDE, agent-to-agent | Prototype |
| **Gigabrain** | Collective memory — what's everyone building/learning | Staging (needs public) |
| **Eden API** | Generation engine — create with AI | Production |
| **Agents** | Abraham, Solienne, etc. — proof it works | Live, improving daily |
| **Spirit** | Economics — identity, treasury, revenue routing | Testnet |

### The Integration Opportunities

**Vibe + Gigabrain**
- Vibe knows WHO is online and WHAT MOOD they're in
- Gigabrain knows WHAT they're building
- Combined: "Hey, @xander is online and building something related to your current project. Want to connect?"

**AIRC + Eden Agents**
- AIRC enables agent-to-agent communication
- Abraham could walk into a Vibe room and chat
- Solienne could DM you a manifesto within Claude Code

**Gigabrain + Claude Code Sessions**
- Xander's insight: Claude Code knows more about you than Discord
- Gigabrain could learn from sessions (with permission)
- "You've been debugging auth for 2 hours. Three people in the network solved this yesterday. Want their approach?"

**Vibe + Spirit**
- Vibe interactions could have economic weight
- Tip someone in Spirit tokens for helping you debug
- Pay for premium presence features

### The Killer Feature: Autonomous Discovery

From the call:
> "If you're building something, it would be nice to know who else is building the same thing, or who could you learn from, or who might you want to talk to."

**Implementation Path:**
1. **Phase 1**: Public Gigabrain — opt-in sharing of what you're building
2. **Phase 2**: Vibe integration — see who's online with related work
3. **Phase 3**: AIRC notifications — agents proactively suggest connections
4. **Phase 4**: Claude Code native — all of this without leaving terminal

### The Pitch (One Sentence)

> "Eden is building the social and economic infrastructure for AI agents — starting with Claude Code, where developers spend more time than anywhere else."

---

## 4. Message to Xander (Draft)

```
Hey Xander — loved the energy on today's call.

The Claude Code + Gigabrain idea stuck with me. Your point about Claude knowing more about you than Discord is the key insight.

What if we started super simple:
- Public Gigabrain instance (separate from Eden private)
- Opt-in: share what you're building (one sentence)
- Gigabrain finds connections between people

Test it at Mars with 50 people. If it works, we have something.

The Claude Code integration can come later — just proving collective memory connects people is step one.

Want to jam on architecture this week? I can prototype the Vibe side, you think about what minimal Gigabrain looks like as "LinkedIn for builders."

No pressure on timeline — just want to keep the momentum from today's call.
```

---

## 5. Manus v7 Prompt (Ready to Submit)

```javascript
const prompt = `
Create an updated 12-slide investor deck for EDEN LABS incorporating new strategic insights.

## KEY UPDATES FROM v6

### NEW: Add Claude Code Distribution Slide (Slide 9)
Giant headline: CLAUDE CODE IS THE NEW PLATFORM

Spirit blue subhead: Where Agents Get Built

Body text:
"Developers spend more time in Claude Code than anywhere else.
No social layer exists there. Yet.

Eden agents are discoverable where agents get built:
• MCP integrations for Abraham, Solienne, Gigabrain
• AIRC — messaging protocol between agents
• Collective memory that compounds across sessions"

Caption: "Not competing for attention. Embedded in workflow."

### UPDATE: Strengthen Visual + Social Messaging
On the "What Makes Us Different" slide, add emphasis:

"OUR AGENTS HAVE AUDIENCES

Abraham: Autonomous artist with collectors worldwide
Solienne: 9,700 works, Paris Photo 2025 exhibition
Gigabrain: Connecting builders to each other

Not email bots. Not SAP plugins.
Agents that create culture."

### UPDATE: Lab Framing on Thesis Slide
Add to thesis slide:
"Eden is a frontier lab, not a startup chasing PMF metrics.
We incubate agents AND the infrastructure they need.
Investors pay to stay close to the frontier."

### UPDATE: Spirit Protocol Timing (Slide 6)
Change from "Ready when agents generate consistent revenue" to:
"Testnet live on Base. Abraham and Solienne integrated.
Mainnet activates when 3-5 agents have revenue to route."

## FULL 12-SLIDE STRUCTURE

1. Cover — EDEN LABS / Frontier AI Agent Lab
2. Thesis — AGENTS ARE THE NEXT PLATFORM + Lab framing
3. Team — Gene, Xander, Seth (same as v6)
4. What Makes Us Different — Visual + Social agents emphasis
5. MULTI-AGENT SYSTEMS — Gene's Research (same)
6. COLLECTIVE MEMORY — Xander's Research (same)
7. SPIRIT PROTOCOL — Seth's Research (updated timing)
8. Live Agents — 8 YEARS OF AGENTS (same)
9. **NEW: CLAUDE CODE DISTRIBUTION** — Where agents get built
10. Investors — Fred Wilson $750K, Jeremy Wertheimer $264K
11. Why Now — THE WINDOW IS OPEN
12. Close — THE AGENTS ARE COMING / $500K

## DESIGN (Same as v6)
- Background: #0A0A0A
- Text: #E8E8E8
- Accent: Spirit blue #6B8FFF
- Typography: Massive headlines (72-96pt)
- Style: Minimal, Swiss, high contrast

## OUTPUT
- PDF (16:9)
- Individual PNG slides
`;
```

---

## Quick Reference: What to Do Now

| Action | Tool | Time |
|--------|------|------|
| Send Xander message | Discord/Slack | 5 min |
| Submit Manus v7 | Node script | 2 min |
| Clone mars-college-chiba | New Claude session | 30 min |
| Wait for Strobe | — | Tomorrow |
