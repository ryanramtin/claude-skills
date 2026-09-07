#!/usr/bin/env bash
# Convert an HTML file to PDF via headless Chrome (faithful CSS/layout).
# Usage: html2pdf.sh <input.html> [output.pdf]
set -euo pipefail

IN="${1:?usage: html2pdf.sh <input.html> [output.pdf]}"
OUT="${2:-${IN%.*}.pdf}"

# Resolve to an absolute path for the file:// URL.
case "$IN" in
  /*) ABS="$IN" ;;
  *)  ABS="$PWD/$IN" ;;
esac
[ -f "$ABS" ] || { echo "error: no such file: $ABS" >&2; exit 1; }

# Find a Chromium-family browser.
CHROME=""
for c in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" \
  "$(command -v google-chrome 2>/dev/null || true)" \
  "$(command -v chromium 2>/dev/null || true)" \
  "$(command -v chromium-browser 2>/dev/null || true)"; do
  [ -n "$c" ] && [ -x "$c" ] && { CHROME="$c"; break; }
done
[ -n "$CHROME" ] || { echo "error: no Chrome/Chromium/Brave found" >&2; exit 1; }

"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$OUT" "file://$ABS" 2>/dev/null

# Verify it's a real PDF.
if [ -s "$OUT" ] && [ "$(head -c 5 "$OUT")" = "%PDF-" ]; then
  echo "wrote $OUT ($(wc -c < "$OUT" | tr -d ' ') bytes)"
else
  echo "error: PDF not produced or invalid" >&2
  exit 1
fi
