#!/bin/zsh
# usage: gate.sh <dir>  -> PASS | PASS(worktree of X) | SKIP: <reasons>
# Checks every git repo/worktree under <dir>. Read-only.
top="${1%/}/"; reasons=(); notes=()
repos=("${(@f)$(find "$top" -name .git -not -path '*/node_modules/*' 2>/dev/null)}")
[[ -z "${repos[1]}" ]] && reasons+=("no-git(check by hand)")
for g in $repos; do
  [[ -z "$g" ]] && continue
  r=${g%/.git}; n=${r#$top}; n=${n:-.}
  [[ -n "$(git -C "$r" status --porcelain 2>/dev/null)" ]] && reasons+=("${n}:dirty")
  if [[ -f "$g" ]]; then
    c=$(git -C "$r" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); c=${c%/.git}
    notes+=("${n}:worktree-of:${c:t}")
    [[ -n "$(git -C "$r" log HEAD --not --remotes --oneline 2>/dev/null | head -1)" ]] && reasons+=("${n}:unpushed")
    continue
  fi
  [[ -n "$(git -C "$r" stash list 2>/dev/null)" ]] && reasons+=("${n}:stash")
  [[ -n "$(git -C "$r" log --branches --tags --not --remotes --oneline 2>/dev/null | head -1)" ]] && reasons+=("${n}:unpushed")
  git -C "$r" for-each-ref --format='%(upstream)' refs/heads | grep -q '^$' && reasons+=("${n}:branch-no-upstream")
  [[ -s "$r/.gitmodules" ]] && reasons+=("${n}:submodules")
  wt=$(git -C "$r" worktree list --porcelain 2>/dev/null | grep -c '^worktree ')
  (( wt > 1 )) && reasons+=("${n}:has-${wt}-worktrees")
  ign=$(git -C "$r" status --ignored --porcelain 2>/dev/null | grep '^!!' | grep -vE 'node_modules|\.next|Pods|DerivedData|\.venv|dist/|build/|\.expo|\.turbo|\.DS_Store|coverage|\.cache' | grep -E '\.(db|sqlite|p8|p12|key|pem)|\.env' | head -3 | tr '\n' ' ')
  [[ -n "$ign" ]] && reasons+=("${n}:ignored-data[$ign]")
done
if (( ${#reasons} )); then echo "SKIP: ${(j:; :)reasons}"; else echo "PASS ${notes:+(${(j:, :)notes})}"; fi
