---
type: "milestone"
date: "2026-03-09"
title: "v0.4.0: unified ship and plugin redesign"
feature_id: "f006"
commits: 15
---

Unified `/lo:ship` into a single command that detects context — Explore/Closed pushes to main, Build/Open on a feature branch pushes the branch, Build/Open on a semver branch runs the full release pipeline (changelog, cleanup, PR, tag). Slimmed `/lo:release` to a starter that creates the branch and bumps the version. Rewrote backlog format so features and tasks share the same checkbox pattern with link-style status lines (`[active](path)`, `[done](v0.4.0) date`). Added reviewer and scout subagents, SessionStart hook for PROJECT.md injection, and `allowed-tools` frontmatter across all skills. Four rounds of CodeRabbit fixes hardened the release before merge.
