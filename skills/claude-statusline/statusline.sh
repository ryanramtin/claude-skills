#!/bin/sh
# Claude Code status line — model · dir · git · week bar · 5hr bar · context bar · claude-mem
# Reads the session JSON Claude Code pipes to stdin.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  model=$(printf '%s' "$input"  | jq -r '.model.display_name // .model.id // "Claude"')
  cwd=$(printf '%s' "$input"    | jq -r '.workspace.current_dir // .cwd // empty')
  five=$(printf '%s' "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
  week=$(printf '%s' "$input"   | jq -r '.rate_limits.seven_day.used_percentage // empty')
  tr=$(printf '%s' "$input"     | jq -r '.transcript_path // empty')
else
  model=$(printf '%s' "$input" | python3 -c "import json,sys;d=json.load(sys.stdin);m=d.get('model',{});print(m.get('display_name') or m.get('id') or 'Claude')" 2>/dev/null)
  cwd=$(printf '%s' "$input"   | python3 -c "import json,sys;d=json.load(sys.stdin);w=d.get('workspace',{});print(w.get('current_dir') or d.get('cwd') or '')" 2>/dev/null)
  five=$(printf '%s' "$input"  | python3 -c "import json,sys;d=json.load(sys.stdin);v=d.get('rate_limits',{}).get('five_hour',{}).get('used_percentage');print('' if v is None else v)" 2>/dev/null)
  week=$(printf '%s' "$input"  | python3 -c "import json,sys;d=json.load(sys.stdin);v=d.get('rate_limits',{}).get('seven_day',{}).get('used_percentage');print('' if v is None else v)" 2>/dev/null)
  tr=$(printf '%s' "$input"    | python3 -c "import json,sys;d=json.load(sys.stdin);print(d.get('transcript_path') or '')" 2>/dev/null)
fi

[ -z "$cwd" ] && cwd="$PWD"
dir=$(basename "$cwd")

# --- context %: last assistant usage in transcript vs 200k window ---
ctx=""
if [ -n "$tr" ] && [ -f "$tr" ]; then
  ctx=$(python3 - "$tr" <<'PY' 2>/dev/null
import json,sys
tot=None
try:
    with open(sys.argv[1]) as f:
        for line in f:
            try: o=json.loads(line)
            except: continue
            u=(o.get("message",{}) or {}).get("usage") or o.get("usage")
            if u:
                tot=(u.get("input_tokens",0)+u.get("output_tokens",0)
                     +u.get("cache_read_input_tokens",0)+u.get("cache_creation_input_tokens",0))
    if tot is not None:
        print(min(100,round(tot*100/200000)))
except: pass
PY
)
fi

# --- git ---
git_part=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && dirty="*" || dirty=""
  [ -n "$branch" ] && git_part=" \033[33m🌿 ${branch}${dirty}\033[0m"
fi

# --- bar renderer. bar <pct> <show_number:0|1> ---
bar() {
  p=$(printf '%.0f' "$1" 2>/dev/null); [ -z "$p" ] && return
# bar <pct> <color-code> <show_number:0|1>
  [ "$p" -gt 100 ] && p=100; [ "$p" -lt 0 ] && p=0
  filled=$(( (p + 6) / 13 )); [ "$filled" -gt 8 ] && filled=8
  c="$2"
  i=0; b=""
  while [ "$i" -lt 8 ]; do
    [ "$i" -lt "$filled" ] && b="${b}█" || b="${b}░"
    i=$(( i + 1 ))
  done
  if [ "$3" = "1" ]; then printf "\033[%sm%s %s%%\033[0m" "$c" "$b" "$p"
  else printf "\033[%sm%s\033[0m" "$c" "$b"; fi
}

# distinct color per bar: week=magenta 35 · 5hr=cyan 36 · ctx=green 32
week_part="";  [ -n "$week" ] && week_part=" \033[90mweek\033[0m $(bar "$week" 35 1)"
five_part="";  [ -n "$five" ] && five_part=" \033[90m5hr\033[0m $(bar "$five" 36 1)"
ctx_part="";   [ -n "$ctx"  ] && ctx_part=" \033[90mctx\033[0m $(bar "$ctx" 32 0)"

printf "\033[1;34m🤖 %s\033[0m \033[90m📁 %s\033[0m%b%b%b%b" \
  "$model" "$dir" "$git_part" "$week_part" "$five_part" "$ctx_part"
