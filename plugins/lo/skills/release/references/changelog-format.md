# Changelog Format

> Based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions.

## File Location

`CHANGELOG.md` at the repo root.

## Structure

```markdown
# Changelog

All notable changes to this project are documented in this file.

## [0.4.0] — 2026-03-15

### Added
- Feature description (f003)

### Fixed
- Bug fix description (t005)

### Changed
- Refactor or improvement description

### Breaking
- Breaking change description

## [0.3.2] — 2026-03-07

### Added
- EARS requirements as optional contract in plan → work → ship chain
- /lo:release skill for versioned release management

### Changed
- Work skill reads EARS alongside plans
- Ship skill audits EARS coverage at Gate 1.5
```

## Rules

1. **Newest version at the top.** Each `/lo:release ship` prepends a new version block.
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

5. **Entry format:** One line per change. Start with what changed, not how. Include backlog IDs when applicable: `(f003)`, `(t005)`.
6. **Terse and factual.** No marketing copy, no filler. Same writing style as stream entries.
7. **Generated from commits.** `/lo:release ship` classifies commits by their prefix and groups them. The user reviews and edits before writing.

## Commit Classification

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
