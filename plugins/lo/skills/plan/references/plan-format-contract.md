# Plan File Format Contract

> From the .lo/ Convention Spec v0.1.0

Plan files live in `.lo/work/f{NNN}-slug/` or `.lo/work/t{NNN}-slug/`. Filename convention: `001-<phase-slug>.md`, `002-<phase-slug>.md`, etc. Phase slug is kebab-case, derived from the phase objective.

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `status` | enum | `pending` \| `in_progress` \| `done` |
| `feature_id` | string | Backlog ID, e.g. `f003` or `t005` |
| `feature` | string | Human-readable name |
| `phase` | integer | Phase number (matches filename prefix) |

## Status Transitions

`pending` -> `in_progress` -> `done`

- `pending` — Not started. Default for newly created plans.
- `in_progress` — Currently being executed by `/lo:work`.
- `done` — All tasks in this phase are complete.

## Body Structure

Every plan file has two sections after the frontmatter:

- `## Objective` — What this phase accomplishes (1-3 sentences).
- `## Tasks` — Checkbox list of work items.

## Task Syntax

- `- [ ]` — Pending task.
- `- [x]` — Completed task.
- `[parallel]` after description — Can run simultaneously with other `[parallel]` tasks.
- `(depends on N, M)` after description — Wait for those numbered tasks to complete first.

## Multi-Phase Conventions

- One file per phase, stored in the same work directory.
- Execute phases in numeric order (`001-*` before `002-*`).
- Complete all tasks in the current phase before starting the next.

## Validation Rules

- Filename must match pattern `NNN-<kebab-slug>.md` where NNN is zero-padded
- `status` must be one of: `pending`, `in_progress`, `done`
- `feature_id` must match an entry in BACKLOG.md
- `phase` integer must match the filename prefix (e.g. `001` -> `1`)
- `## Objective` and `## Tasks` sections are required
- Tasks use standard Markdown checkbox syntax

## Examples

### Single-phase plan

```yaml
---
status: pending
feature_id: "f003"
feature: "User Authentication"
phase: 1
---

## Objective
Add email/password login with session handling and a protected route guard.

## Tasks
- [ ] 1. Create auth database schema and RLS policies
- [ ] 2. Build login form component [parallel]
- [ ] 3. Build signup form component [parallel]
- [ ] 4. Wire up session middleware (depends on 1)
```

### Multi-phase plan (first file of two)

```yaml
---
status: pending
feature_id: "f007"
feature: "Dashboard Redesign"
phase: 1
---

## Objective
Replace the existing layout with new grid system and responsive shell.

## Tasks
- [ ] 1. Scaffold new dashboard layout component
- [ ] 2. Migrate sidebar navigation [parallel]
- [ ] 3. Migrate header bar [parallel]
- [ ] 4. Add responsive breakpoints (depends on 1)
- [ ] 5. Smoke-test all routes render in new shell (depends on 2, 3, 4)
```

Phase 2 would be saved as `002-widget-migration.md` in the same directory.
