---
updated: 2026-03-07
---

## Features

### f001 — Changing LORF to LO
Rename `.lorf/` directory to `.lo/`, update all skill references, plugin naming, and documentation to use "lo" instead of "lorf" throughout all projects in `projects/looselyorganized/*`.
Status: done -> 2026-02-25

### f002 — LO Plugin Own Repo
Move lo-plugin to standalone repo at `looselyorganized/lo-plugin` with stocktaper design system, updated lo-spec, and clean install URL.
Status: done -> 2026-02-25

### f003 — GitHub Automation Sync
Script-driven reconciliation of all GitHub automation (CodeRabbit, CodeQL, CI, auto-merge, branch protection) based on PROJECT.md status. Zero manual steps on `/lo:new` or `/lo:status` transitions.
Status: active -> .lo/work/f003-github-automation-sync/

## Tasks

- [ ] t001 Audit /work
- [x] t002 ~~Ship feature needs to delete /work directories once done and remove from BACKLOG.md~~ -> 2026-03-07
- [x] t003 ~~Fix where /plan sends plans — must follow .lo convention~~ -> 2026-03-07
- [ ] t004 Add epic to backlog command
