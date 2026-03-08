---
type: "milestone"
date: "2026-03-07"
title: "f003: GitHub automation sync"
feature_id: "f003"
commits: 8
---

`lo-github-sync.sh` — one script to reconcile CodeRabbit, CI, auto-merge, and branch protection across every repo, driven entirely by PROJECT.md status. Replaced ~160 lines of inline automation in `/lo:status` and `/lo:new`. Audited all 9 repos, dropped lint and CodeQL from CI (redundant with CodeRabbit), standardized `pipeline` as the job name. Rolled out and verified green across the org.
