---
name: coding-cli-brief-loop
description: Use when handing a build or fix task to a coding CLI (OpenCode, Grok CLI, Claude Code, Codex, Aider, etc.) and you want it driven from a written BRIEF.md in a visible terminal, reviewed against a 10-point rubric, and fixed through numbered follow-ups until it passes.
---
# Brief a coding CLI and review-fix loop

The task lives in a file, not a chat message. The CLI runs where a person can watch it. Every result gets scored, and every fix gets written down.

## 1. Prepare
1. Pick the project folder. Check that the folder is right and note its git state (`git status`, branch). If there are uncommitted changes you didn't make, stop and ask.
2. Pick the CLI and model. Use a free or included model first and move to a paid one only when you need to (see step 7).
3. Write down the "done" test before writing the brief: one command, URL, or file check that proves it works.

## 2. Write ./BRIEF.md
Put it in the project root. Make it self-contained, because the CLI only knows what the file says.

```markdown
# BRIEF: <short task title>
Owner: <person>. Agent: <CLI + model>. Date: <YYYY-MM-DD>.

## Goal
<1–3 sentences: the outcome, not the method.>

## Context (read these first)
- <file/dir>: <why it matters>
- <doc/URL>: <what to take from it>
- Current behavior: <what happens now>. Desired: <what should happen>.

## Scope
- In: <files/dirs it may create or edit>
- Out: <files/dirs/systems it must not touch>

## HARD RULES
- No installs, upgrades, or network downloads without asking first. List what you would install and why, then stop.
- Never delete or move files you did not create. Copy, never move, originals.
- Never print, echo, log, or commit secrets, tokens, keys, or config/credential files. Say "exists" and nothing more.
- Do not touch production services, live databases, deploys, DNS, billing, or external accounts. Local and test only.
- No git commit, push, merge, or rebase unless this brief says so.
- Do not claim done without a real reproduction. Run it, and paste the exact command and output.
- If something is ambiguous or blocked, write it under "Open questions" in the report and stop. Don't guess.

## Steps / approach (optional)
1. <step>
2. <step>

## Acceptance criteria
- [ ] <observable check 1: command → expected output>
- [ ] <observable check 2>
- [ ] Existing tests/lint still pass: `<command>`
- [ ] No files changed outside Scope (`git status` shows only expected paths)

## Deliverables
- Code/files: <list>
- Report: ./BUILD-REPORT.md containing: summary, files changed (tree), commands run and their real output, acceptance checklist with pass/fail, deviations from the brief, open questions.
```

## 3. Launch it in a visible terminal
- Open a normal terminal window, never a headless or background run. Start the CLI in the project folder and send exactly one line:
  `Read ./BRIEF.md and do exactly what it says. Write ./BUILD-REPORT.md when finished.`
- If the CLI asks for permission to run commands, approve read and build commands. Deny anything that breaks a HARD RULE.

Optional macOS Terminal helpers (the window id is a placeholder):
```bash
# open a window in the project and start the CLI
osascript -e 'tell application "Terminal" to do script "cd <PROJECT_DIR> && <cli-command>"'
# list windows to find the id
osascript -e 'tell application "Terminal" to get id of every window'
# send the kickoff line to that window
osascript -e 'tell application "Terminal" to do script "Read ./BRIEF.md and do exactly what it says. Write ./BUILD-REPORT.md when finished." in window id <WINDOW_ID>'
# read what the window shows (monitoring)
osascript -e 'tell application "Terminal" to get contents of selected tab of window id <WINDOW_ID>'
```
Some CLIs need the line typed into their prompt rather than run as a shell command. In that case, use System Events `keystroke` + `key code 36` (Return) aimed at the frontmost window.

## 4. Monitor
- Read the window every few minutes. Check that it's following the brief, not stuck in a loop, and not asking a question nobody is answering.
- Step in right away if it tries an install, a deletion, a secret read, a production call, or a git push. Interrupt it, then say which rule applies.
- It's finished when BUILD-REPORT.md exists and the CLI is idle.

## 5. Review and score out of 10
Don't trust the report alone. Run the acceptance checks yourself and read the diff (`git diff --stat`, then the full diff).

| Category | Points | 0 = | Full = |
|---|---|---|---|
| Correctness: acceptance criteria truly pass (you re-ran them) | 3 | fails | all pass |
| Proof: real reproduction with commands and output in the report | 2 | claims only | reproducible |
| Rule compliance: HARD RULES, scope, nothing outside Scope changed | 2 | any breach | clean |
| Quality: readable, minimal, no dead code/hacks, tests where sensible | 2 | messy | clean |
| Report honesty: deviations and open questions stated | 1 | hidden | complete |

- Pass means at least 9 out of 10 and no HARD RULE breach. Any rule breach fails the run, whatever the score.
- Record the result in `REVIEW-n.md`: score per category, total, exact defects (file:line, repro), and a verdict.

## 6. Fix with numbered follow-ups
For each round below the bar, write `FOLLOWUP-<n>.md` (n = 1, 2, 3...) and send: `Read ./FOLLOWUP-<n>.md and do exactly what it says. Append results to ./BUILD-REPORT.md.`

```markdown
# FOLLOWUP-<n> for BRIEF.md (previous score: <x>/10)
HARD RULES from BRIEF.md still apply.
## Fix these, in order
1. <defect>: seen at <file:line / command>. Expected: <...>. Actual: <...>.
2. ...
## Do not change
- <things that already pass>
## Prove it
- Re-run: `<commands>`; paste output under "FOLLOWUP-<n> results" in BUILD-REPORT.md.
```
Re-review and re-score after every follow-up.

## 7. Limits, stalls, and context exhaustion
- **Rate or usage limit hit:** switch model on the same CLI first, starting with free ones, then switch CLI. Don't wait out long cooldowns.
- **Context full or the agent is confused:** don't keep going in that session. Write `HANDOFF.md` and start a fresh session with: `Read ./BRIEF.md, then ./HANDOFF.md, then continue.`

```markdown
# HANDOFF (session <k> → <k+1>)
Brief: ./BRIEF.md. Latest follow-up: ./FOLLOWUP-<n>.md. Last score: <x>/10.
Done so far: <bullets with files>.
Still failing: <bullets with repro>.
Gotchas learned: <bullets>.
Next action: <one concrete step>.
```
- Note each switch (time, from, to, reason) in BUILD-REPORT.md.

## 8. Stop conditions
- Stop when it passes (at least 9/10, no breach), or after 3 follow-ups without improving, or after any serious HARD RULE breach. A breach means stop, assess the damage, and tell the owner.
- Also stop if the remaining work needs a decision, money, credentials, an install, or a production action. Ask the owner.

## 9. Final report to the owner
- What was built, and where.
- Final score and the rounds, for example 6 → 8 → 9.5.
- Proof: the commands you re-ran and what happened.
- Files changed, and confirmation that nothing outside scope changed and nothing was committed or deployed (unless the brief allowed it).
- Model or CLI switches.
- Open questions and recommended next step.
