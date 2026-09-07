---
name: minimize
description: Give a short, chill rundown of what's actually happening across the user's projects — recent work, live blockers, what's shipped, what's owed. Cuts the tech noise into a scannable digest. Use when the user invokes /minimize, or says "minimize", "what's going on", "catch me up", "where are we", "status", "what's the state of things", "sitrep", or "give me the rundown".
---

# Minimize 🌊

Give the user a **chill, scannable** picture of where things stand. Not an essay. Not a report. Just: here's the vibe, here's what's hot, here's what's owed. Then stop.

## The one rule

**Signal only.** If it wouldn't change what they do next, cut it. The whole thing should read in ~20 seconds.

## Gather (fast, parallel)

Pull from whatever's available — run these together, don't block on any one:

1. **claude-mem** — most recent observations. The session-start `$CMEM` block is often already in context; use it. Otherwise call `mcp__plugin_claude-mem_mcp-search__timeline` or `search` for the last day or two.
2. **Live blockers** — if a project-tracking MCP is connected, pull its open blockers/risks. Skip silently if not.
3. **Git** — for the 2-3 repos touched most recently, a quick `git -C <path> log --oneline -5` and `git -C <path> status -s`. Uncommitted work and un-pushed branches are the real "what's going on."

Don't over-gather. Two or three sources is plenty. If one's slow or missing, drop it and move on — never make the user wait.

## Format the rundown

Keep it tight. Structure like this, but only include lines that have something:

```
🌊 Here's the vibe — {date}

🔥 Hot right now
  • {the 1-3 things actively in motion}

✅ Landed
  • {what shipped since last check — with the win, not the mechanics}

⛔ Owed / blocked
  • {what's waiting on you or stuck — the ONE thing that matters most first}

😎 All quiet elsewhere.
```

Rules:
- **Max ~3 bullets per section.** More than that = you're dumping, not curating.
- Lead each bullet with the outcome, not the plumbing. "Sharing is live in prod" beats "merged PR #14 into main at f3ad4c9."
- Drop empty sections entirely. No "Nothing to report here" filler.
- One emoji per section header. Don't carpet-bomb.
- If everything's calm, say so in one line and stop. That's a valid answer.

## Tone

Laid-back but sharp — think a good teammate leaning over your desk, not a Jira export. Plain sentences. If the user has chill-dude vibes going, match it; otherwise stay warm and terse. Never pad. Never apologize for a short answer — short *is* the answer.

## Don't

- Don't re-explain project history they already know.
- Don't list every commit or every observation.
- Don't editorialize or add "next steps" unless they're genuinely blocking.
- Don't end with "let me know if you'd like more detail" — just leave the door open by being brief.
