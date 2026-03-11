---
updated: 2026-03-10
---

## Features

- [x] f001 Changing LORF to LO
  Rename `.lorf/` directory to `.lo/`, update all skill references, plugin naming, and documentation.
  [done] v0.3.0 2026-02-25

- [x] f002 LO Plugin Own Repo
  Move lo-plugin to standalone repo at `looselyorganized/lo-plugin` with stocktaper design system.
  [done] v0.3.0 2026-02-25

- [x] f003 GitHub Automation Sync
  Script-driven reconciliation of all GitHub automation based on PROJECT.md status.
  [done] v0.3.2 2026-03-07

- [x] f004 Emoji Visual Anchors in Token Streams
  Add strategic emoji markers to skill files at critical decision points.
  [done] v0.3.2 2026-03-07

- [x] f005 Optimize Stream for Large Milestones
  Refocus stream skill to capture significant milestones rather than granular commit groups.
  [done] v0.3.2 2026-03-07

- [x] f006 Plugin Redesign
  Redesign using Claude Code's latest capabilities — subagents, hooks, allowed-tools, simplified pipelines.
  [done] v0.4.0 2026-03-09

- [ ] f007 Project Refresh
  `/lo:refresh` skill that updates (not regenerates) README.md, CLAUDE.md, and other project files to reflect current state. Reads project.yml, BACKLOG.md, and codebase context to patch stale sections. Called by `/lo:ship` as a final step, or manually anytime.
  Status: backlog

## Tasks

- [x] t001 Audit /work
  [done] v0.3.2 2026-03-07
- [x] t002 Ship feature needs to delete /work directories once done
  [done] v0.3.2 2026-03-07
- [x] t003 Fix where /plan sends plans
  [done] v0.3.2 2026-03-07
- [x] t004 Add epic to backlog command
  [done] v0.4.1 2026-03-10
- [x] t005 Review /lo:new flow — validation redundancy, research dir scaffolding
  [done] v0.4.1 2026-03-10
- [x] t006 Fix PROJECT.md frontmatter key: generate `id: "proj_UUID"` not `proj_id: "proj_UUID"`
  [done] v0.4.1 2026-03-10
- [x] t007 Stream as single STREAM.md file in .lo/ root instead of individual files in .lo/stream/
  [done] v0.4.1 2026-03-10
- [x] t008 Audit files created on status change to Build — ensure proper CI/CD scaffolding
  [done] v0.4.1 2026-03-10
- [x] t009 Add private/public visibility toggle to /lo:status (or separate command)
  [done] v0.4.1 2026-03-10
- [x] t010 Remove "topics" from PROJECT.md generation and clean up topic tags across all .lo projects
  [done] v0.4.1 2026-03-10
- [x] t011 Update BACKLOG.md format — change `[done] v0.4.0` hyperlink style to plain `[done] v0.4.0` so version isn't linked to status
  [done] v0.4.1 2026-03-10
