---
name: artifact-to-pdf
description: Save a Claude Artifact (or any HTML file) as a PDF with faithful CSS/layout. Use when the user wants to export, download, convert, or "save as PDF" an artifact, an HTML page, or a claude.ai/code/artifact URL, or asks the cleanest way to turn HTML into a PDF.
---

# Artifact → PDF

Convert a Claude Artifact or standalone HTML file to a PDF that preserves the original CSS/layout, by rendering through Chrome's own engine.

## First: is the HTML already on disk?

The whole task hinges on getting the artifact's HTML onto the filesystem. Ask/check before doing anything else.

- **User has the .html file** (or pastes the HTML) → go straight to **Convert**.
- **Only a `claude.ai/code/artifact/…` URL** → the content is login-gated and loads client-side, so `curl` returns only the SPA shell and headless Chrome can't authenticate. Get the HTML first via **Get HTML from a login-gated artifact**.

## Quick start (recommend this to a person)

The cleanest path for a human needs no tools:

> Open the artifact → **Cmd+P** (Print) → Destination: **Save as PDF** → Save.

It uses the browser's own renderer, so layout is exact. Only reach for the scripted path below when the user wants it hands-free/automated, or when *you* must produce the PDF.

## Convert (HTML on disk → PDF)

One headless-Chrome command, no dialog. Use the bundled script:

```bash
~/.claude/skills/artifact-to-pdf/scripts/html2pdf.sh "/path/to/artifact.html" "/path/to/out.pdf"
```

Or inline:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="out.pdf" "file:///abs/path/to/artifact.html"
```

Notes:
- `file://` needs an **absolute** path; spaces in the path are fine when quoted.
- `--no-pdf-header-footer` removes the URL/date margins. Drop it if the user wants them.
- Verify success: first 8 bytes are `%PDF-1.4` and file size is non-trivial.

## Get HTML from a login-gated artifact

When you only have the artifact URL, drive the user's logged-in Chrome (browser tools), then convert. Steps:

1. `tabs_context_mcp{createIfEmpty:true}`, then `navigate` the tab to the artifact URL.
2. The artifact renders in a **cross-origin iframe** (`<uuid>.frame.claudeusercontent.com`) — you can't read it same-origin, and its `src` carries an auth token. Instead, navigate the tab itself to the frame URL so the artifact becomes the top document:
   ```js
   window.location.href = document.querySelector('iframe').src; 'navigating';
   ```
   (After this, `location.pathname` is `/code/frame/<uuid>` — still under `claude.ai`, now same-origin and readable.)
3. Trigger a **download of the rendered HTML from inside the page** (the base64/text channel back through the browser tool is blocked, so a Blob download is the reliable move):
   ```js
   const h = '<!doctype html>\n' + document.documentElement.outerHTML;
   const a = document.createElement('a');
   a.href = URL.createObjectURL(new Blob([h], {type:'text/html'}));
   a.download = 'artifact.html';
   document.body.appendChild(a); a.click(); a.remove();
   ```
4. The download may need the user's confirmation. Find the saved file (`~/Downloads` or `~/Desktop`), then run **Convert** on it.

Simplest alternative to steps 2–4: tell the user to use the artifact's own **⋯ menu → Download as HTML**, then hand you the file.

## Non-Mac / no Chrome

- Chrome/Chromium/Brave all accept the same `--headless --print-to-pdf` flags (swap the binary path).
- If none is installed, `weasyprint file.html out.pdf` or `wkhtmltopdf file.html out.pdf` work but render some modern CSS less faithfully than Chrome.
