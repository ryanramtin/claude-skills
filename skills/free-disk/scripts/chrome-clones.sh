#!/bin/zsh
# Lists (default) or deletes (--delete) stale Chrome code_sign_clone copies in $TMPDIR/../X.
# Always keeps the NEWEST clone and any clone a running process has open.
T="${TMPDIR:-$(getconf DARWIN_USER_TEMP_DIR)}"; C="$(dirname "${T%/}")/X/com.google.Chrome.code_sign_clone"
[[ -d "$C" ]] || { echo "none"; exit 0; }
live=("${(@f)$(lsof 2>/dev/null | grep -o 'code_sign_clone/code_sign_clone\.[A-Za-z0-9]*' | sort -u | sed 's#.*/##')}")
all=("$C"/code_sign_clone.*(Nom))   # newest first
for d in $all; do
  b=${d:t}
  [[ "$d" == "${all[1]}" ]] && { echo "keep(newest) $b"; continue; }
  (( ${live[(Ie)$b]} )) && { echo "keep(live) $b"; continue; }
  if [[ "$1" == --delete ]]; then rm -rf -- "$d" && echo "deleted $b"; else echo "stale $b"; fi
done
