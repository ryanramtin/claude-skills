---
name: claude-statusline
description: Install or fix a Claude Code status line showing model, directory, git branch, rate limits and context window usage. Use when the status line is missing, blank, wrong, or shows no limits, or when someone asks "how much context do I have left", "how do I see my rate limits", or wants the model and branch always visible.
---

# claude-statusline

One line at the bottom of Claude Code: model, folder, branch, weekly limit, 5-hour limit, context used.

```
🤖 Opus 4.8 📁 my-project 🌿 main* week ███░░░░░ 38% 5hr █████░░░ 61% ctx ██░░░░░░
```

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/ryanramtin/claude-skills/main/skills/claude-statusline/install.sh | sh
```

It downloads the script to `~/.claude/statusline.sh` and wires `statusLine` into `~/.claude/settings.json`, backing the file up first. Restart Claude Code afterwards.

No `jq` on the machine? The installer stops and prints the two lines to add by hand. Do that instead of installing `jq` for this.

## Fixing a broken line

- **Nothing appears** → `statusLine` is missing from settings, or the command path is wrong. Re-run the installer.
- **Limits missing** → no subscription usage data is being reported yet. The segment hides itself rather than lying; this is expected on API-key-only setups.
- **Context always 0** → the transcript path in the JSON payload isn't resolving. Check that the script is executable and that `~/.claude/statusline.sh` exists.
- **Line looks like raw JSON** → settings point at a file that isn't the script, or the script lost its shebang.

## Reading the bars

Each bar is 8 blocks. `week` is the 7-day limit, `5hr` is the rolling 5-hour limit, `ctx` is the context window against 200k. A `*` after the branch means the tree is dirty.

Do not add segments. The whole value of this line is that it stays short enough to read at a glance.
