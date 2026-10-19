# character-sheet-gate 🎨🔒

Character sheets for any animated film, comic, or storybook with recurring characters. You write one spec per character (silhouette, proportions, hex palette, outfit, expressions, do/don't), make turnaround and sample-scene stills, and revise in numbered rounds. Then you lock the approved sheet. Nothing renders until it's approved, and every later render gets checked against the locked sheet. Works with any image or video model.

## Install

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills \
  && cp -r /tmp/claude-skills/skills/character-sheet-gate ~/.claude/skills/character-sheet-gate
```

Or copy [`SKILL.md`](./SKILL.md) into `~/.claude/skills/character-sheet-gate/SKILL.md`.

## Use

Invoke with `/character-sheet-gate`, or say "design the characters", "make a character sheet", "lock the cast before we render".

## License

MIT — see [LICENSE](../../LICENSE).
