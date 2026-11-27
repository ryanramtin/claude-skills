#!/bin/zsh
# Regenerable caches only. Safe to run anytime. Prints sizes first.
cd "$HOME" || exit 1
for p in Library/Caches/CocoaPods Library/Caches/Google Library/Caches/node-gyp .cache/uv/archive-v0; do
  [[ -e "$p" ]] && { print -n "$(du -sh "$p" 2>/dev/null | cut -f1)\t$p ... "; rm -rf -- "$HOME/$p" 2>/dev/null && echo ok || echo "partial(locked)"; }
done
dd="$HOME/Library/Developer/Xcode/DerivedData"
[[ -d "$dd" ]] && find "$dd" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null && echo "DerivedData cleared"
command -v pnpm >/dev/null && pnpm store prune 2>&1 | tail -1
npm cache clean --force >/dev/null 2>&1 && echo "npm cache cleaned"
