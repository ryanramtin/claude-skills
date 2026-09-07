# claude-skills

A small collection of [Claude Code](https://claude.com/claude-code) skills I actually use every day.

Each skill is self-contained and individually linkable — grab the one you want, ignore the rest.

## Skills

| Skill | What it does |
|---|---|
| [**emojli** 🧠⚡](https://github.com/ryanramtin/claude-skills/tree/main/skills/emojli) | Extreme clarity, minimal words, logical emoji. Replies you scan instead of read. |
| [**chill-dude** 🤙](https://github.com/ryanramtin/claude-skills/tree/main/skills/chill-dude) | Laid-back surfer voice that still knows engineering. No corporate speak. |
| [**minimize** 🌊](https://github.com/ryanramtin/claude-skills/tree/main/skills/minimize) | 20-second rundown across your projects: what's hot, what landed, what's owed. |
| [**artifact-to-pdf** 📄](https://github.com/ryanramtin/claude-skills/tree/main/skills/artifact-to-pdf) | Save a Claude Artifact or any HTML file as a PDF with layout intact. |

## Install

One skill:

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills
cp -r /tmp/claude-skills/skills/emojli ~/.claude/skills/emojli
```

All of them:

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills
cp -r /tmp/claude-skills/skills/* ~/.claude/skills/
```

Skills load on the next Claude Code session. Invoke one by name, e.g. `/emojli`.

## Layout

```
skills/<name>/SKILL.md      # the skill itself
skills/<name>/README.md     # what it is + install
```

A `SKILL.md` is just frontmatter (`name`, `description`) plus instructions in Markdown. The `description` is what Claude matches against to decide when the skill applies, so it carries the trigger phrases.

## Contributing

Issues and PRs welcome. If you fork one of these into something better, I'd like to see it.

## License

MIT — see [LICENSE](./LICENSE). Use them, change them, ship them.
