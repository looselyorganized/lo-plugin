# Changelog Format

> Based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.

## File Location

`CHANGELOG.md` at the repo root.

## Sources

The changelog is **synthesized from three inputs**, not just commit messages:

| Source | What it provides |
|--------|-----------------|
| **Work directories** (`.lo/work/*/`) | Plan files, EARS requirements — what was designed and why |
| **BACKLOG.md** | Feature names, task descriptions — the human-readable intent |
| **Git commits** (`git log main..<version>`) | Implementation details, commit classification |

Commits tell you *how*. Work artifacts and backlog tell you *what* and *why*. The changelog should read like the backlog and work artifacts, not like a list of commit messages.

**Bad** (commit message parrot):
```
- feat(f004): add emoji markers to ship skill
- feat(f004): add emoji markers to work skill
- feat(f004): add emoji markers to plan skill
- chore: bump version to 0.3.2
```

**Good** (synthesized from all three sources):
```
- Emoji visual anchors across all skills — strategic 🛑/⚠️/🔒 markers at stop gates,
  warnings, and hard constraints to improve agent instruction-following (f004)
```

One entry per feature/task, not one entry per commit. Group related commits into a single line that describes the outcome.

## Structure

```markdown
# Changelog

All notable changes to this project are documented in this file.

## [0.3.2] — 2026-03-07

### Added
- Emoji visual anchors across all skills — 🛑/⚠️/🔒 markers at critical decision
  points to improve agent instruction-following (f004)
- Feature lifecycle tracking in backlog — features now transition through
  backlog → active → done instead of being removed at plan time (t002)
- TaskCreate progress tracking in ship, release ship, and work pipelines
- Explicit release branching model — work branches off release branch,
  ship merges back, main untouched until release ship

### Changed
- Sequential work execution runs directly on feature branch instead of worktrees
- Ship pipeline merges feature branches into release branch in Build/Open mode
- Plan and work skills renumbered to integer steps (no more Step 4.5)
- Stream skill refocused on significant milestones over granular commit groups (f005)

### Fixed
- Status skill now accepts /lo:status Explore as a valid transition
- Backlog view now shows all lifecycle states including done

### Removed
- Hypothesis skill and all references (deleted, no SKILL.md)
- "push and PR" trigger phrase from ship (skill never creates PRs)

## [0.3.1] — 2026-03-04

### Added
- EARS requirements as optional contract in plan → work → ship chain
- /lo:release skill for versioned release management
- README staleness check in ship Gate 4

### Changed
- Ship defers cleanup to /lo:ship in Build/Open mode
- Work skill reads EARS alongside plans
- Ship skill audits EARS coverage at Gate 2
```

## Rules

1. **Newest version at the top.** Each `/lo:ship` prepends a new version block.
2. **Date format:** `YYYY-MM-DD`
3. **Version format:** `[MAJOR.MINOR.PATCH]` in brackets
4. **Categories** (only include categories that have entries):

    | Category | What goes here |
    |----------|---------------|
    | Added | New features, new skills, new capabilities |
    | Fixed | Bug fixes |
    | Changed | Refactors, improvements, dependency updates, config changes |
    | Removed | Deleted features, removed files |
    | Breaking | Changes that break backward compatibility |
    | Documentation | Doc-only changes (use sparingly — most doc changes accompany code) |

5. **Entry format:** One line per change (wrap long lines). Start with what changed, not how. Include backlog IDs when applicable: `(f003)`, `(t005)`.
6. **One entry per feature/task.** Multiple commits implementing the same feature become a single changelog line. The changelog describes outcomes, not implementation steps.
7. **Terse and factual.** No marketing copy, no filler. Same writing style as stream entries.
8. **Generated, then edited.** `/lo:ship` synthesizes from all three sources and presents a draft. The user reviews and edits before writing.

## Commit Classification

Used as a starting point for categorization, but the final category should reflect the *nature of the change*, not just the commit prefix.

| Commit prefix | Category |
|--------------|----------|
| `feat:`, `feat(*):` | Added |
| `fix:`, `fix(*):` | Fixed |
| `chore:`, `refactor:`, `cleanup:` | Changed |
| `docs:` | Documentation |
| `BREAKING CHANGE:`, `!:` | Breaking |
| No prefix / other | Changed |

## First Changelog

If `CHANGELOG.md` doesn't exist, create it with the header:

```markdown
# Changelog

All notable changes to this project are documented in this file.

## [<version>] — <date>

<entries>
```

## Editing

The changelog is **append-only during releases**. Each release adds a new version block at the top. Never modify entries for previous versions unless correcting a factual error.
