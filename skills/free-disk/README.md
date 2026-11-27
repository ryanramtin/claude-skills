# free-disk 💾🧹

Your Mac is out of space and a build just died. This skill frees it safely. It clears regenerable caches first, then finds the stale Chrome self-copies that quietly pile up in temp (70+ GB on one machine), then offloads idle dev folders to an external drive. Every repo goes through a git safety gate (no dirty trees, stashes or unpushed commits). It's copied, verified with a diff, and only deleted after you say so.

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
