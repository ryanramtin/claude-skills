---
name: character-sheet-gate
description: "Use before rendering any animated film, comic, storybook, or ad that has recurring characters: design each character, get explicit sign-off on a locked, versioned sheet, then keep every later render consistent with it. Works with any image/video model; callable as the character step of a film skill."
---
# Character sheets with approval gate

**The gate:** nothing gets rendered for the production until the owner explicitly approves the locked sheet. "Looks good" about a draft is feedback, not approval. Approval means words like "approved, lock it."

## 1. Gather the inputs
Ask for whatever is missing, all in one message:
- The cast: name, role (lead, support, background), age or species, and the one trait that matters most for each.
- Look and style: the art style, plus 1–3 reference images or style words. Use principles and mood only, never copied characters, designs, or shots from existing works.
- Real people: if anyone is based on a real person, get their consent and that person's own notes on how they want to look. Keep this private.
- Format: aspect ratio, where it will be shown, the age of the audience.
- Fixed facts that can't change: heights, things a character always carries, things a character never wears.

## 2. Write one spec per character
Save it as `cast/<character>.md`, using plain words and numbers:

```markdown
# <NAME>: <role>, <age/species>
One line: <who they are, in a sentence>.

## Silhouette and shape
- Readable in solid black: <key shape, e.g. round head, tall triangle body>
- Shape language: <round/soft | square/steady | spiky/edgy>
## Proportions and scale
- Height <cm> = <n> heads tall. Next to <other character>: <relation, e.g. head at their waist>.
## Palette (hex)
| Part | Hex | Notes |
|---|---|---|
| Skin / fur | #...... | |
| Hair | #...... | |
| Eyes | #...... | catchlight, sclera never pure white |
| Outfit main | #...... | |
| Accent / prop | #...... | |
## Outfit and props
- Default: <...>. Variants (weather/night/etc.): <...>; what must stay visible in every variant: <...>.
## Distinguishing features
- <the 3–5 things that make them recognizable at thumbnail size>
## Expressions (3–6)
- neutral, happy, scared, determined, <...>. How each reads: <e.g. scared = goes still and small, not a big face>.
## Key poses / body language
- <e.g. leans forward like about to run>
## Voice (if animated)
- <pitch, pace, one sample line>
## DO / DON'T
- DO: <...>
- DON'T: <...> (e.g. no text on clothing, never a hat, no outlines)
## Prompt block (reused verbatim later)
<one paragraph that describes the character fully, plus the shared style line>
```
Also write `cast/LINEUP.md`, a table of every character with height, head count, and main colors, so scale stays consistent across the cast.

## 3. Make the preview stills
Use whatever image or video model you have. For each character:
1. A turnaround: front, three-quarter, side, and back views, all on one sheet with a neutral background.
2. An expression sheet with every expression listed in the spec.
3. A cast lineup, with everyone side by side at the correct relative heights.
4. **One sample scene:** two or more characters together in a real moment from the story, in the final style and lighting. This is where problems show up: scale, palette clashes, and style drift.

Use the same seed or reference image, the same style line, and the same resolution for every still. Write down the model, version, seed, and exact prompt for each image.

## 4. Show a contact sheet
- Put all the stills on one page, labeled `<character>_<view>_v<round>`. Example: `ffmpeg -i img_%02d.png -filter_complex tile=4x3 contact.png`, or any image tool.
- Under it, list what changed since the last round and ask specific questions, like "Is the jacket color right?", rather than "thoughts?"
- Say clearly: **"Draft for review. Nothing will be rendered until you approve."**

## 5. Revision rounds
- Number the rounds v1, v2, v3. Never overwrite an earlier round; keep each in `cast/rounds/v<n>/`.
- Keep a change log in `cast/CHANGELOG.md`:
  `v<n> | <date> | <character> | <what changed> | <why / whose note>`
- Change only what the feedback asked for, so the rest stays stable.
- If it isn't settled after about 4 rounds, offer 2–3 clearly different options side by side instead of making more small tweaks.

## 6. Lock the sheet (the gate)
When the owner says it's approved:
1. Copy the approved round to `cast/LOCKED-v<n>/`. It holds the reference stills, the final `cast/<character>.md` specs, the prompt blocks, and the model, version, and seed details.
2. Record the approval in `cast/LOCKED-v<n>/APPROVAL.md` with who approved it, when, their exact words, and anything left open.
3. Treat the locked folder as read-only. Any change after this means a new round and a new lock (v<n+1>) with fresh approval.
4. Approve and lock each character on its own. Characters still waiting on approval stay out of renders. Use a placeholder or cut the shot.

## 7. Use the locked sheet in later renders
- Every render prompt starts with the character's locked prompt block and the shared style line, word for word.
- Attach the locked turnaround or expression stills as references, using the model's reference, IP-adapter, or image-to-image input, with the same seed when it can be reused.
- For any new outfit, pose, or season variant, run steps 3–6 just for that variant first.
- Tell the downstream film or story skill which `LOCKED-v<n>` it should read.

## 8. Check each render against the sheet
Before accepting a render, check:
- [ ] Silhouette and proportions match (head count, relative heights in the frame).
- [ ] Every palette color looks right (sample with a color picker if unsure).
- [ ] Outfit, props, and distinguishing features are present, and no DON'T is broken.
- [ ] The expression reads as intended at full size and as a thumbnail.
- [ ] No drift across shots. Put frames from several shots side by side.
If it fails, re-render using the locked references. Don't loosen the sheet to match a bad render.

## Outputs
`cast/<character>.md`, `cast/LINEUP.md`, `cast/CHANGELOG.md`, `cast/rounds/v*/`, `cast/LOCKED-v<n>/` (stills, specs, prompts, APPROVAL.md), plus a contact sheet for every round.
