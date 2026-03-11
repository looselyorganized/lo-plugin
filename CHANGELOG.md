# Changelog

All notable changes to this project are documented in this file.

## [0.5.0] — 2026-03-10

### Added
- Open transition wizard in /lo:status — Railway PR deploy verification, error tracking, uptime monitoring, and rate limiting prompts with automatic backlog task creation for gaps
- Conditional infrastructure steps in Build transition — database backup/migration verification (if DB detected) and health check endpoint detection (if API framework detected)
- Dependency audit (`npm audit --audit-level=critical`) in ship Gate 3 for Open-status projects
- `has-audit` flag in CI workflow generation for Open-status projects via lo-github-sync.sh
- .gitignore verification step in /lo:new — generates stack-appropriate defaults if missing, warns if .env not excluded

### Changed
- Ship gates are now stage-aware — Explore/Closed skips Gates 2 (EARS), 3 (tests), and 4 (reviewer) entirely; Build runs all gates; Open adds dependency audit to Gate 3
- Stream quality gate broadened from "would you post this?" to "would this be interesting to someone following the project?" — decisions, pivots, and lessons learned now qualify alongside milestones
- Open transition promoted from simple status change to full wizard with 5 automation steps (matching Build's treatment)

## [0.4.1] — 2026-03-10

### Added
- Epic support in /lo:backlog — group related features under named epics (t004)
- Private/public visibility toggle in /lo:status (t009)
- Stream milestone creation integrated into release ship pipeline — entries created with full context before work artifact cleanup
- Progress checklists in ship, stream, and work skills

### Changed
- Stream consolidated from .lo/stream/*.md files to single .lo/STREAM.md with XML entry format (t007)
- Stream entries restricted to milestones only — "would you post this?" quality gate replaces update/note types
- Stream XML format adopted across all 10 LO repos
- Backlog done format simplified from `[done](v0.4.0)` hyperlink to plain `[done] v0.4.0` (t011)
- PROJECT.md frontmatter key renamed from `proj_id` to `id` (t006)
- /lo:new scaffolding updated — creates STREAM.md file instead of stream/ directory (t005)
- All skills rewritten with Anthropic prompt engineering best practices — XML-isolated mode paths, critical blocks, scripted git commands
- README updated to reflect current .lo/ convention

### Removed
- `topics` field from PROJECT.md frontmatter and /lo:new generation (t010)
- `commits` and `feature_id` fields from stream entries
- Stream `type` field (milestone/update/note) — all entries are milestones now
- Individual stream entry files (.lo/stream/*.md)

## [0.4.0] — 2026-03-09

### Added
- Custom subagents: `reviewer` (sonnet, code review for secrets/security/dead code) and `scout` (haiku, fast read-only codebase exploration) with model aliases, disallowedTools, and proactive descriptions (f006)
- SessionStart hook injecting PROJECT.md into every session automatically (f006)
- `allowed-tools` frontmatter on all skills for reduced permission prompting (f006)

### Changed
- `/lo:ship` is now the universal ship command — detects context automatically: fast mode (Explore/Closed → push to main), feature mode (Build/Open → push branch), release mode (semver branch → changelog, cleanup, PR to main, tag) (f006)
- `/lo:release` slimmed to release starter only — creates branch, bumps version. Finalization moved to `/lo:ship` (f006)
- Ship pipeline simplified from 9 gates to 6 — reviewer subagent replaces inline code simplification and security review gates (f006)
- Explore/Closed ship mode pushes directly to main instead of creating branch + PR (f006)
- Backlog format unified: features and tasks both use checkbox list items with `[active](path)` / `[done](version) date` status lines (f006)

### Removed
- Per-skill version metadata from SKILL.md frontmatter (f006)
- Release polling loop, cleanup PR, TaskCreate progress tracking (f006)
- Separate `/lo:release ship` command — absorbed into `/lo:ship` (f006)

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
