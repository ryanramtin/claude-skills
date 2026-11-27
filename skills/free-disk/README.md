# free-disk 💾🧹

AI coding agents generate a lot: worktrees per task, a fresh `node_modules` in each, build caches, temp copies. Your disk fills up and the next build dies with "No space left on device". free-disk cleans up after them. It clears regenerable caches and stale `node_modules`, removes the Chrome self-copies that pile up in temp, and moves old worktrees and idle repos to an external drive. Every repo passes a git safety gate first (no dirty trees, stashes or unpushed commits), gets copied and diff-verified, and is only deleted after you say so.

It triggers on its own when Claude hits "No space left on device" or you say "free up disk".

## Install

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills \
  && cp -r /tmp/claude-skills/skills/free-disk ~/.claude/skills/free-disk \
  && chmod +x ~/.claude/skills/free-disk/scripts/*.sh
```

## Use

Invoke with `/free-disk`, or say "free up disk", "disk is full", "clean up my Mac". It also kicks in when a command fails with ENOSPC.

## What's inside

| File | Does |
|---|---|
| `SKILL.md` | The playbook: measure, free, ask, offload, report |
| `scripts/caches.sh` | Clears regenerable caches (CocoaPods, DerivedData, pnpm, npm, uv…) |
| `scripts/chrome-clones.sh` | Lists or deletes stale Chrome `code_sign_clone` copies, keeping the newest and any in use |
| `scripts/gate.sh` | Read-only git check: PASS or SKIP with reasons |
| `scripts/offload.sh` | Copies to the external drive and verifies with `diff -rq`. Never deletes |

macOS + zsh. Tested on Apple Silicon.

## License

MIT — see [LICENSE](../../LICENSE).
