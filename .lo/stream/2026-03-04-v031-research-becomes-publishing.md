---
type: "milestone"
date: "2026-03-04"
title: "v0.3.1: research becomes publishing"
commits: 30
---

Killed `/lo:research` as a standalone skill. Research files stay as raw materials in `.lo/research/`; publishing is now `/lo:publish` — a cross-repo pipeline that dispatches articles to the platform. Removed `.lo/notes/`, simplified frontmatter contracts, enforced worktree-only workflow in `/lo:work`, added `proj_id` for stable project identity. Bumped all skills to 0.3.1.
