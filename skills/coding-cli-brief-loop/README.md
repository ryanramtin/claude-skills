# coding-cli-brief-loop 🧑‍💻🔁

Hand a build or fix task to any coding CLI (OpenCode, Grok CLI, Claude Code, Codex, Aider) through a written `BRIEF.md` with hard rules built in. You run it in a terminal you can watch, score the result out of 10 against a rubric, and send numbered `FOLLOWUP-n.md` fixes until it passes. Covers what to do when the model or CLI hits a limit: switch, prefer free models, and continue from a `HANDOFF.md`.

## Install

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills \
  && cp -r /tmp/claude-skills/skills/coding-cli-brief-loop ~/.claude/skills/coding-cli-brief-loop
```

Or copy [`SKILL.md`](./SKILL.md) into `~/.claude/skills/coding-cli-brief-loop/SKILL.md`.

## Use

Invoke with `/coding-cli-brief-loop`, or say "brief OpenCode on this", "write a BRIEF.md for the CLI", "review and score what the agent built".

## License

MIT — see [LICENSE](../../LICENSE).
