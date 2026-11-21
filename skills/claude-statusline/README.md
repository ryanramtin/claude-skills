# claude-statusline

A status line for [Claude Code](https://claude.com/claude-code): model, folder, git branch, rate limits, and context window — one line, always visible.

```
🤖 Opus 4.8 📁 my-project 🌿 main* week ███░░░░░ 38% 5hr █████░░░ 61% ctx ██░░░░░░
```

| Segment | Meaning |
|---|---|
| 🤖 model | Current model display name |
| 📁 dir | Basename of the working directory |
| 🌿 branch | Branch, with `*` when the tree is dirty |
| week | 7-day rate limit used |
| 5hr | 5-hour rate limit used |
| ctx | Context window used vs 200k |

Bars are 8 blocks wide. Any segment whose data isn't available hides itself, so the line stays clean outside a repo or before limits are reported.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/ryanramtin/claude-skills/main/skills/claude-statusline/install.sh | sh
```

Downloads `statusline.sh` to `~/.claude/statusline.sh`, backs up `~/.claude/settings.json`, and wires `statusLine` into it. Restart Claude Code afterwards.

Without `jq` the installer prints the two lines to add by hand instead of touching your settings.

## Manual setup

```sh
curl -fsSL https://raw.githubusercontent.com/ryanramtin/claude-skills/main/skills/claude-statusline/statusline.sh -o ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Then in `~/.claude/settings.json`:

```json
{
  "statusLine": { "type": "command", "command": "sh ~/.claude/statusline.sh" }
}
```
