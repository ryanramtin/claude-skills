---
name: deploy-and-verify
description: Use after a site or app deploy, or when asked to "deploy and verify", "check live vs local", "is the live site up to date", "deploy drift", or "did my changes go live". Fetches the public page with cache-busting, checks critical assets return 200, diffs live output against the local source of truth, and reports exactly where they diverge, including newer drafts that never made it into the deployed tree.
license: MIT
---
# Deploy and verify

It watches your deploys. After you push something live, it pulls the public page and diffs it against your local files, then tells you exactly where they don't match.

## License

MIT. See [LICENSE](../../LICENSE).

## Why this exists
The common failure isn't a broken deploy. It's a successful deploy of the wrong tree. A polished draft sat in a cloud-synced folder while the git repo and the production site stayed on an older version. The deploy went green, the site loaded, and nobody noticed the new work wasn't there. So always confirm **which tree was actually deployed**, compare the public output to **that** tree, and **call out any newer draft that wasn't included**.

## 1. Identify the local source of truth
1. Find the repo that the host deploys from (`git remote -v`, the hosting config, or the deploy log's commit SHA). That repo at the deployed commit is what *should* be live.
2. List the files meant to go live: usually `index.html` plus the CSS, JS, images, GIFs, and icons it references.
3. Look for competing copies of the same site: cloud-synced folders (iCloud, Dropbox, Google Drive, OneDrive), `Downloads`, `~/Documents`, or a second clone on the Desktop. Compare modification times and content.
   ```bash
   # example: find other index.html copies near the project
   find ~ -maxdepth 6 -name index.html -path '*<site-name>*' -not -path '*/node_modules/*' 2>/dev/null
   ```
4. **Warn** if the copy being treated as the source is a non-repo folder (cloud draft, export, scratch dir) while a repo copy also exists, or if a non-repo copy is newer than the repo. State both paths and which one was deployed.
5. Check the repo is clean and pushed: `git status`, `git log -1`, `git log origin/<branch>..HEAD`. Uncommitted or unpushed changes are not live.

## 2. Identify the live URLs
- List every public URL that should serve this deploy: production domain, `www` and apex, and any platform default domain (e.g. `*.vercel.app`, `*.netlify.app`, `*.pages.dev`, `*.github.io`).
- If the host exposes the deployed commit SHA, note it and confirm it matches `git rev-parse HEAD` of the intended branch.

## 3. Fetch live output
Bust caches on every request. Check each URL separately, because www and apex can serve different things.
```bash
TS=$(date +%s)
for u in https://example.com https://www.example.com; do
  echo "== $u"
  curl -sSL -o /dev/null -w '%{http_code} %{url_effective}\n' "$u/?cb=$TS"
  curl -sSL -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' "$u/?cb=$TS" > "/tmp/live-$(echo "$u" | sed 's#^https*://##; s#/#_#g').html"
done
curl -sSI "https://example.com/?cb=$TS" | grep -iE '^(age|cache-control|x-cache|cf-cache-status|x-vercel-cache|etag|last-modified):'
```
- Then check every critical asset the page references returns 200 with the right content type:
  ```bash
  grep -oE '(src|href)="[^"#]+\.(png|jpe?g|gif|webp|svg|ico|css|js|mp4|webm)"' index.html \
    | sed -E 's/^(src|href)="//; s/"$//' | sort -u | while read -r p; do
      case "$p" in http*) url="$p";; /*) url="https://example.com$p";; *) url="https://example.com/$p";; esac
      printf '%s %s\n' "$(curl -s -o /dev/null -w '%{http_code} %{content_type}' "$url?cb=$TS")" "$url"
    done
  ```
- Anything not 200 is a finding. A 200 that returns `text/html` for an image or script usually means a fallback page, not the asset.
- If a CDN header shows a cache HIT with a large `age`, the edge may be stale. Note it before blaming the code.

## 4. Diff live against intent
Compare the live HTML to the deployed tree's files, and separately to any newer draft found in step 1.
```bash
diff <(sed 's/[[:space:]]\+/ /g' index.html) <(sed 's/[[:space:]]\+/ /g' /tmp/live-example.com.html) | head -200
```
Minified or build-transformed output won't diff cleanly. Compare structure and content instead: section IDs, headings, card titles, link targets, image sources, and visible text. Flag:
- **Missing or extra sections and cards** (count them on both sides).
- **Wrong copy:** headings, prices, dates, CTAs, contact details that differ.
- **Missing icons, images, or animations:** absent `<img>`/`<svg>`, GIFs or videos that 404, missing CSS/JS that drives motion.
- **Dead nav:** menu or anchor links pointing at sections or pages that no longer exist (`href="#id"` with no matching `id`).
- **Draft-only content:** anything in a newer draft or non-repo copy that isn't in the deployed repo at all. This is the drift that's easiest to miss.

## 5. Report and don't claim done early
Report plainly, one block per mismatch:
```
Deployed tree: <repo path> @ <sha>   Newer draft found: <path or "none">
Live URLs checked: <list with status codes>

1. <section/element>
   Intended: <what local/draft has>
   Live:     <what the public page shows>
   Cause:    <not committed | not pushed | wrong tree deployed | cache | asset 404 | build step dropped it>
```
- End with a verdict: **live matches intent**, or **N mismatches**, with the fix for each (commit and push the draft, purge cache, fix the asset path, redeploy).
- Do not say "deployed" or "done" until the live site matches intent, or the user explicitly accepts the remaining drift.
- After a fix and redeploy, run steps 3 to 5 again. One clean pass is the proof.
