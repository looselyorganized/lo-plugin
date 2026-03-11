# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Claude Code plugin (pure markdown, no runtime) providing the LO work system — 11 skills covering backlog management, plan execution, shipping pipelines, and a design system. Installed via the LO plugin marketplace.

## Project Layout

```
plugins/lo/
  .claude-plugin/
    plugin.json          # Version source (canonical)
    hooks.json           # SessionStart hook injects .lo/PROJECT.md
    agents/
      reviewer.md        # Code review subagent (sonnet, read-only)
      scout.md           # Fast codebase explorer (haiku, read-only)
  skills/
    <skill-name>/
      SKILL.md           # Skill definition (YAML frontmatter + markdown body)
      references/        # Format contracts, guides (skill-specific)

scripts/
  lo-github-sync.sh      # Reconciles GitHub automation to match PROJECT.md status

.lo/                     # LO convention: project metadata for this repo
```

## Key Conventions

- **Source files live in `plugins/lo/skills/`**. Never edit files in `~/.claude/plugins/cache/` — those are read-only copies.
- **Version source** is `plugins/lo/.claude-plugin/plugin.json`. Bump it during `/lo:release`.
- **Skills are markdown with YAML frontmatter** declaring `name`, `description`, `allowed-tools`. The body is the prompt.
- **Subagents** are markdown files in `.claude-plugin/agents/` with frontmatter for `model`, `tools`, `disallowedTools`, `maxTurns`.
- **`lo-github-sync.sh`** generates `.coderabbit.yaml`, `.github/workflows/ci.yml`, `.github/workflows/auto-merge.yml`, and configures GitHub branch protection via API. All generated files are marked "do not edit manually."

## Stage-Aware Behavior (v0.5.0)

Skills behave differently based on `status` in `.lo/PROJECT.md`:

| Stage | Ship gates | Tests | Code review | CI |
|-------|-----------|-------|-------------|-----|
| **Explore** | Skip Gates 2-4 | None | None | Dormant |
| **Build** | All gates | Run if exist | Reviewer subagent | lint + test + build |
| **Open** | All gates + `npm audit` | Required (hard stop if missing) | Reviewer subagent | lint + test + build + audit |
| **Closed** | Skip Gates 2-4 | None | None | Dormant |

The sync script passes `has-audit: true` to CI for Open-status projects.

## How Skills Reference Each Other

```
/lo:new → scaffolds .lo/, runs lo-github-sync.sh
/lo:backlog → manages BACKLOG.md
/lo:plan → creates .lo/work/f{NNN}-slug/ with plan files
/lo:work → executes plans, branches, parallel agents
/lo:ship → quality gates → commit → push/PR (mode: fast/feature/release)
/lo:release → creates semver branch, bumps version
/lo:ship tag → post-merge: tag + cleanup
/lo:stream → editorial milestone entries in STREAM.md
/lo:solution → reusable knowledge in .lo/solutions/
/lo:status → lifecycle transitions with automation wizards
```

## Editing Skills

When modifying a SKILL.md:
- Preserve XML conditional blocks (`<fast-mode>`, `<test-gate-build>`, etc.) — agents follow "read only your block" instructions.
- Keep `allowed-tools` in frontmatter accurate — it controls what the skill can access.
- Reference files go in `references/` subdirectory, not inline.
- Examples go at the bottom in `<example name="...">` blocks.

## Testing Changes

No automated tests — this is a pure markdown plugin. To validate:

```bash
# Test locally
claude --plugin-dir ./plugins/lo

# Validate plugin structure
claude plugin validate .

# Dry-run the sync script
./scripts/lo-github-sync.sh
```

## Release Process

```bash
/lo:release bump minor    # Creates branch, bumps plugin.json
# ... work on branch ...
/lo:ship                  # Changelog, stream, cleanup, PR to main
# ... PR merges via auto-merge ...
/lo:ship tag              # Tag, delete branch
```
