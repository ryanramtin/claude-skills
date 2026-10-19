---
name: code-rendered-video
description: "Use when asked to make a promo, explainer, product demo, logo reel, or motion-graphics video with any coding agent: the agent writes rendering code (HyperFrames, Remotion, or plain HTML/canvas + ffmpeg), you render, finish to one loudness target, and check the MP4 before calling it done."
---
# Code-rendered video

Coding agents don't output MP4 files. They write code that draws each frame, and you render and encode that code. This works with any capable coding agent or CLI.

Prompt ideas: https://github.com/real-leo/awesome-opus-videos-aggregate (846 curated examples, 430 with prompts; see by-category.md and prompts.md). The upstream lists are athemeroy/awesome-opus-5-5-videos (production paths), joeseesun/opus-video-prompts (copy-ready prompts), and yihui-dev/awesome-opus5-5-videos (the largest prompt set).

## 1. Lock the spec before any code
Write down the duration in seconds, aspect ratio (16:9, 9:16, or 1:1), resolution, fps (30 is the default), scene beats with timestamps, the ending call to action, and whether there's voice or music. Collect the real brand: logo, colors (hex), fonts, screenshots, and copy. Generic input gives generic output.

## 2. Pick a renderer
| Renderer | Best for | Render |
|---|---|---|
| **HyperFrames** (HTML compositions + timeline, GSAP by default; Lottie/Three.js/canvas adapters) | Promos, explainers, story shorts, anything web-styled | `npx hyperframes check` → `npx hyperframes snapshot --at <s>` → `npx hyperframes render` (draft first, then high quality). See `npx hyperframes --help` for current flags. |
| **Remotion** (React to video) | Data-driven or templated videos, product UI in React | `npx remotion render <CompositionId> out.mp4` |
| **Plain HTML/Canvas/SVG** (+GSAP), p5.js, Three.js | One-off, single-file pieces, 3D | Capture frames with headless Chromium at a fixed timestep, then use ffmpeg (below) |
| **Manim** | Math or technical explainers | `manim -qh scene.py Scene` |

Ask for ONE self-contained deliverable: a single HTML file or a single project. It should use deterministic, time-based animation (a `draw(t)` or seekable timeline, no `Date.now()` and no randomness without a seed), local assets, and relative paths.

Frame capture for plain HTML:
```bash
# page exposes window.seek(t) or renders from ?t=; capture N = fps*duration frames with Playwright/Puppeteer
ffmpeg -framerate 30 -i frames/frame_%05d.png -c:v libx264 -pix_fmt yuv420p -crf 18 video.mp4
```

## 3. Prompt patterns that work
- Showreel: "Make a dynamic 15-second motion graphics video that shows what an incredible motion designer you are. Go all out."
- Product promo from the real UI: "Analyze <url or codebase> and build a product promo from our own UI, not generic components."
- Business explainer: "Adopt the role of an expert motion designer. Build a 30-second animated explainer for my business as a single HTML page."
- Logo reel: "Make this logo into a 10-second dynamic reel, as a world-class motion designer."
- Autonomy: "Make a 60-second fully animated explainer end to end, completely on your own."
- Style reference: name a famous ad or music-video style, and add "avoid border text or frames."
- Vertical app tour: "Make a 45-second vertical video: a glance inside the app."
Always add the spec from step 1. Then add: "Use deterministic time-based animation; one self-contained project; no network assets."

## 4. Pre-render gate
- Run the renderer's own check (for example `npx hyperframes check`). It must pass before any full render.
- Take still snapshots at the start, middle, and end of every scene and in the middle of each transition. Check text is readable (on screen at least about 1 s per 3 words), safe margins, brand colors, and that nothing gets cut off.
- Do a draft render first, and the final render only after the draft has been reviewed.

## 5. Shared finish step (audio + poster)
Use one loudness target for the whole project:
- **Web and social promos: −14 LUFS integrated, true peak ≤ −1 dBTP.**
- Dialogue-heavy or long-form content may use −16 LUFS integrated. Pick one target and don't mix them within a series.
- Keep music under voice. A music bed of about 0.3–0.4 gain is typical, never above 0.5. Voice should sit about 10 dB above the ducked music.
```bash
# mux voice/music if separate, then two-pass loudnorm
ffmpeg -i video.mp4 -i mix.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest muxed.mp4
ffmpeg -i muxed.mp4 -af loudnorm=I=-14:TP=-1:LRA=11:print_format=json -f null - 2> ln.txt   # pass 1: read measured_* values
ffmpeg -i muxed.mp4 -af loudnorm=I=-14:TP=-1:LRA=11:measured_I=<..>:measured_TP=<..>:measured_LRA=<..>:measured_thresh=<..>:offset=<..>:linear=true \
  -c:v copy -c:a aac -b:a 192k final.mp4                                                      # pass 2
ffmpeg -ss <poster_s> -i final.mp4 -frames:v 1 poster.jpg                                      # poster image
```
For narration, a local TTS engine is fine. Give it the exact script, and run speech-to-text on the final mix to confirm every line can be heard.

## 6. Render-and-check before calling it done
```bash
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height,r_frame_rate,pix_fmt -of compact final.mp4
ffmpeg -i final.mp4 -af ebur128=peak=true -f null - 2>&1 | tail -12              # confirm integrated LUFS and true peak
ffmpeg -i final.mp4 -vf blackdetect=d=0.5:pix_th=0.10 -an -f null - 2>&1 | rg blackdetect   # unexpected black gaps
ffmpeg -i final.mp4 -vf "fps=1/<interval_s>,scale=480:-1,tile=4x4" -frames:v 1 contact.png     # contact sheet
```
Checklist:
- [ ] Duration within ±0.2 s of the spec. Resolution, fps, and aspect match. Pixel format is yuv420p and codec is h264, so it plays everywhere.
- [ ] An audio stream exists if expected, loudness is within ±1 LU of the target, and true peak is ≤ −1 dBTP.
- [ ] No unexpected black frames or frozen sections. Look at the contact sheet, and check jumps across scene boundaries.
- [ ] Text is readable and spelled right, brand colors and logo are correct, and the ending CTA is visible long enough to read.
- [ ] Watch it once all the way through with sound.
Fix and re-render until every box is ticked. Don't call it done before that.

## 7. Deliver
`final.mp4`, `poster.jpg`, `contact.png`, the source project, and a short note with spec, renderer, loudness, and duration. Add captions (`.srt`) and a share caption if the video is going on social media.

## Tips
- Feed it the real brand. Use screenshots of the actual product UI instead of mock components.
- Specify duration, aspect ratio, scene beats, and an ending CTA every time.
- Credit creators. Don't republish other people's prompts or footage. Use licensed or original music only.
