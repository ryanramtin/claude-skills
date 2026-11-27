#!/bin/zsh
# usage: offload.sh <dest-root> <list-file>   (paths in list are relative to $PWD)
# Copies each path to <dest-root>/<path> without regenerable dirs, then verifies with diff -rq.
# Prints "0 <path>" when verified. NEVER deletes anything.
dest="$1"; list="$2"
EX=(--exclude=node_modules --exclude=.next --exclude=Pods --exclude=DerivedData --exclude=.venv --exclude=.expo --exclude=.turbo)
DX=(-x '._*' -x node_modules -x .next -x Pods -x DerivedData -x .venv -x .expo -x .turbo)
while read -r p; do
  [[ -z "$p" ]] && continue
  mkdir -p "$dest/$p"
  rsync -aH $EX "$p/" "$dest/$p/" >/dev/null 2>&1 || { echo "COPYFAIL $p"; continue; }
  n=$(diff -rq $DX "$p" "$dest/$p" 2>&1 | grep -v 'No such file or directory' | wc -l | tr -d ' ')
  echo "$n $p"
done < "$list"
