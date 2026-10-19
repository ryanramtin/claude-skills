# code-rendered-video 🎬

Promos, explainers, logo reels, and motion graphics where a coding agent writes the rendering code (HyperFrames, Remotion, or plain HTML/canvas + ffmpeg). You render it, finish the audio to one loudness target (−14 LUFS for web), and check the MP4 with ffprobe, a contact sheet, and a black-frame scan before calling it done.

## Install

```bash
git clone --depth 1 https://github.com/ryanramtin/claude-skills.git /tmp/claude-skills \
  && cp -r /tmp/claude-skills/skills/code-rendered-video ~/.claude/skills/code-rendered-video
```

Or copy [`SKILL.md`](./SKILL.md) into `~/.claude/skills/code-rendered-video/SKILL.md`.

## Use

Invoke with `/code-rendered-video`, or say "make a 30-second promo", "animated explainer", "logo reel", "render this as an MP4".

## License

MIT — see [LICENSE](../../LICENSE).
