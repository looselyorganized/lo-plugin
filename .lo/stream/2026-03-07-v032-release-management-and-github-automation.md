---
type: "milestone"
date: "2026-03-07"
title: "v0.3.2: release management and GitHub automation"
commits: 26
---

Built `/lo:release` for versioned release lifecycle — release branches, changelog generation, merge-to-main with tags. `lo-github-sync.sh` replaces 200+ lines of inline CI/branch-protection code in status and new skills with a single reconciliation script (f003). Ship skill now routes by project status: Explore pushes direct to main, Build/Open commits to feature branch for release coordination. Added EARS requirements as an optional formal contract through the plan → work → ship chain. Killed hypothesis skill. First release to ship with its own CHANGELOG.md.
