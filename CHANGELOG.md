# Changelog

All notable changes to this project are documented in this file.

## [0.3.2] — 2026-03-07

### Added
- `/lo:release` skill — versioned release management with release branches, changelog generation, and git tags
- EARS requirements as optional contract in plan → work → ship chain — formal requirements for complex features with `REQ-*` IDs referenced through planning and execution
- `lo-github-sync.sh` — script-driven reconciliation of all GitHub automation (CodeRabbit, CI, auto-merge, branch protection) based on PROJECT.md status (f003)
- CI verification gate in `/lo:release ship` — ensures integrated branch passes CI before merging
- README staleness check in ship pipeline
- `TaskCreate` progress tracking across ship, release ship, and work pipelines — live task dashboards during gate execution
- Changelog format reference (`references/changelog-format.md`) — synthesized from commits, work artifacts, and backlog rather than raw commit messages
- EARS guide reference (`references/ears-guide.md`) for writing structured requirements
- Stream entry: v0.3.2 milestone

### Changed
- Ship skill now **status-aware** — Explore/Closed ships via PR to main; Build/Open commits to feature branch for release coordination via `/lo:release ship` (major architectural change)
- Plan skill tracks feature lifecycle in backlog (`backlog` → `active` → `done`) instead of removing features at plan time
- Work skill reads EARS contract alongside plans, surfaces `REQ-*` IDs in task summaries, and branches off release branches when detected
- Status skill replaced inline CI/branch-protection generation with `lo-github-sync.sh` calls — dramatically simplified
- New skill replaced inline CI generation with `lo-github-sync.sh`, removed `hypotheses/` from scaffold
- Sequential work execution runs directly on feature branch instead of worktrees
- Gates renumbered to integers across ship and release skills (no more Step 4.5)
- README updated to reflect removed hypothesis system and simplified directory structure

### Fixed
- Backlog skill forces fresh file read on every invocation, preventing stale cache data
- GitHub sync handles 404 on branch protection check for unprotected repos (f003)
- Status skill strips inline YAML comments and uses correct pipeline job name (f003)
- Robust `gh` API error handling and check name comparison in sync script (f003)

### Removed
- Hypothesis skill (`plugins/lo/skills/hypothesis/SKILL.md`) and all references — hypotheses, hypothesis directory, README sections, frontmatter contracts
- `frontmatter-contracts.md` reference from new skill (consolidated elsewhere)
- "push and PR" trigger phrase from ship (skill never creates PRs in Build/Open mode)
