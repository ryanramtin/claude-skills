# deploy-and-verify 🚀🔍

It watches your deploys. After you push something live, it pulls the public page and diffs it against your local files, then tells you exactly where they don't match. It checks every live URL (www, apex, platform domain) with cache-busting, confirms images and GIFs return 200, and flags newer drafts sitting in a cloud folder that never made it into the repo that was deployed.

## Install

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills \
  && cp -r /tmp/claude-skills/skills/deploy-and-verify ~/.claude/skills/deploy-and-verify
```

Or copy [`SKILL.md`](./SKILL.md) into `~/.claude/skills/deploy-and-verify/SKILL.md`.

## Use

Invoke with `/deploy-and-verify`, or say "deploy and verify", "check live vs local", "is the live site up to date", "check for deploy drift".

## License

MIT — see [LICENSE](../../LICENSE).
