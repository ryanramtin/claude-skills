#!/bin/sh
# Installer for claude-statusline (part of github.com/ryanramtin/claude-skills).
# Downloads the script to ~/.claude/statusline.sh and wires it into settings.json.

set -e

RAW="https://raw.githubusercontent.com/ryanramtin/claude-skills/main/skills/claude-statusline/statusline.sh"
DEST="$HOME/.claude/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"

mkdir -p "$HOME/.claude"

echo "Downloading statusline.sh..."
curl -fsSL "$RAW" -o "$DEST"
chmod +x "$DEST"
echo "Installed to $DEST"

if ! command -v jq >/dev/null 2>&1; then
  echo
  echo "jq not found, so settings.json was left untouched."
  echo "Add this to $SETTINGS yourself:"
  echo
  echo '  "statusLine": { "type": "command", "command": "sh ~/.claude/statusline.sh" }'
  exit 0
fi

if [ -f "$SETTINGS" ]; then
  if ! jq empty "$SETTINGS" >/dev/null 2>&1; then
    echo
    echo "$SETTINGS is not valid JSON. Leaving it alone."
    echo 'Add: "statusLine": { "type": "command", "command": "sh ~/.claude/statusline.sh" }'
    exit 1
  fi
  cp "$SETTINGS" "$SETTINGS.bak"
  echo "Backed up existing settings to $SETTINGS.bak"
else
  echo '{}' > "$SETTINGS"
fi

tmp=$(mktemp)
jq '.statusLine = {"type":"command","command":"sh ~/.claude/statusline.sh"}' \
  "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"

echo "Wired statusLine into $SETTINGS"
echo
echo "Restart Claude Code to see it."
