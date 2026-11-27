---
name: free-disk
description: Free disk space on a Mac safely. Purges regenerable caches, removes stale Chrome code_sign_clone copies, strips stale node_modules, and offloads idle dev folders to an external drive with a git safety gate, copy, verify, then delete only after the user approves. Use PROACTIVELY whenever disk is low or full, such as ENOSPC / "No space left on device" errors, `df` showing under 15 GB free, or npm/pnpm/xcodebuild failing on space. Also use when the user says "free space", "free up disk", "disk is full", "clean up my Mac", "out of space", or /free-disk.
---

# free-disk

Free space without losing anything. The rules are simple: regenerable data goes first, then anything else gets copied, verified and only deleted with the user's say-so.

Scripts live next to this file in `scripts/`. They are zsh, read-only unless noted.

## 0. Measure

```bash
df -h /System/Volumes/Data | tail -1
```

- Under 1 GB free: do the small deletes in step 1 first. Big `du` runs fail with ENOSPC.
- Use `du -x`. `~/Library/GroupContainersAlias` and some `~/Library/Containers/*/Data/*` entries are symlinks back into your home folder, and a naive `du` counts them twice.

## 1. Free without asking (regenerable only)

- `scripts/caches.sh` clears CocoaPods, Google, node-gyp and uv archive caches, plus Xcode DerivedData, then runs `pnpm store prune` and `npm cache clean`.
- Run `scripts/chrome-clones.sh` to list, then `--delete`. Chrome leaves a ~1.4 GB copy of itself in `$TMPDIR/../X/com.google.Chrome.code_sign_clone` on many relaunches and never cleans them up. `du` can show 70+ GB. They're APFS clones that share blocks, so the real gain is smaller (10–15% of what du shows). The script always keeps the newest copy and any copy a process has open.
- `node_modules` inside checkouts or worktrees with no file changes in 14+ days. Code and `.git` stay.
- `~/.Trash`.

## 2. Ask first (state the size and why)

- iOS simulator runtimes (`xcrun simctl runtime list`), often ~8 GB each, and they reinstall with Xcode updates.
- Big app data: Claude Desktop VM bundles, Voice Memos (iCloud-synced, so a local delete deletes everywhere), old AI model caches, unused apps.
- Leave `com.apple.os.update-*` APFS snapshots alone. macOS manages them.

## 3. Offload idle dev folders to an external drive

Destination: `<external>/offload/<YYYY-MM-DD>/<same relative path>` plus a `MANIFEST.md`.

1. **Candidates.** Folders in your projects directory idle 30+ days: size, last commit date. Skip anything with files touched in the last 14 days.
2. **Gate each one** with `scripts/gate.sh <dir>`. Only `PASS` moves. SKIP reasons are dirty tree, stash, unpushed commits, branch with no upstream, repo with other worktrees, ignored `.env`/`.db`/key files, and submodules. List those for the user. Don't move them. Never move a repo whose worktrees live somewhere else.
3. **Show the user the list** (path · size · last activity · PASS/SKIP reason) with a recommendation. Wait for a yes.
4. **Copy and verify.** `cd` to the source root, write the relative paths to a list file, then run `scripts/offload.sh "<dest>" <list>`. Every line must read `0 <path>`. macOS ships openrsync, which has no `-X`. exFAT drives create `._*` sidecar files. The script handles both.
5. **Write `MANIFEST.md`** in the dated folder with path, repo or worktree-of, branch and sha.
6. **Delete local copies only after the user explicitly says so.** For worktrees, run `git -C <parent repo> worktree remove <abs path>` without `--force`. It refuses if dirty, so leave those. For repos, `rm -rf` the literal path, one at a time.

## Hard rules

- Never delete a source before its copy verifies with 0 diffs.
- Never remove a worktree another session or agent may be using (files touched in the last 24 h).
- Never touch credentials, license files, live service folders, or anything the gate SKIPs without asking.

## Report

- `df -h` before and after.
- What was freed, what was moved (with the destination path), and what's still owed, with sizes.
