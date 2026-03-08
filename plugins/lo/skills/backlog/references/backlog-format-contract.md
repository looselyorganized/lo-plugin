# BACKLOG.md Format Contract

> From the .lo/ Convention Spec v0.1.0

The project backlog lives at `.lo/BACKLOG.md`. It is the single registry for features and tasks.

## Frontmatter

| Field | Type | Description |
|-------|------|-------------|
| `updated` | date | Date of last modification (YYYY-MM-DD) |

## Feature Block Syntax

| Element | Format | Description |
|---------|--------|-------------|
| Heading | `### f{NNN} — Feature Name` | Feature ID + display name |
| Description | Free text below heading | 1-2 sentence summary |
| Status | `Status: backlog` / `Status: active -> .lo/work/f{NNN}-slug/` / `Status: done -> YYYY-MM-DD` | Current lifecycle state |

## Task Checkbox Syntax

| State | Format | Description |
|-------|--------|-------------|
| Open | `- [ ] t{NNN} description` | Pending task |
| Done | `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD` | Completed task with date |

## ID Convention

- Features: `f{NNN}` (e.g., `f001`, `f002`)
- Tasks: `t{NNN}` (e.g., `t001`, `t002`)
- IDs are sequential and never reused, even after deletion
- To find the next ID, scan BACKLOG.md for the highest existing `f{NNN}` or `t{NNN}` and increment

## Status Values

- **Features:** `backlog` | `active -> .lo/work/f{NNN}-slug/` | `done -> YYYY-MM-DD`
- `/lo:plan` sets status to `active` when creating a work directory
- `/lo:ship` sets status to `done` when shipping
- Features stay in BACKLOG.md through their full lifecycle
- **Tasks:** open (`- [ ]`) or done (`- [x]`)

## Validation Rules

- `updated` must be a valid YYYY-MM-DD date
- Every feature must have a heading matching `### f{NNN} — Name`
- Every feature must have a `Status:` line
- Every task must be a checkbox with a `t{NNN}` ID
- IDs must be unique within their type (no duplicate `f{NNN}` or `t{NNN}`)
- Completed tasks must include a strikethrough description and completion date
- All content is plain Markdown with YAML frontmatter — no MDX

## Default Template

```yaml
---
updated: YYYY-MM-DD
---

## Features

_No features in backlog. Use `/lo:backlog feature "description"` to add one._

## Tasks

_No tasks in backlog. Use `/lo:backlog task "description"` to add one._
```

Use today's date for the `updated` field when creating a new backlog.

## Example

```yaml
---
updated: 2026-03-01
---

## Features

### f001 — Dashboard Redesign
Rebuild the main dashboard with responsive layout and live data widgets.
Status: done -> 2026-02-28

### f002 — User Authentication
Add email/password login with session management.
Status: active -> .lo/work/f002-user-auth/

### f003 — API Rate Limiting
Add rate limiting to public API endpoints.
Status: backlog

## Tasks

- [ ] t003 Update dependency versions
- [x] t002 ~~Set up CI pipeline~~ -> 2026-02-20
- [x] t001 ~~Initialize project repository~~ -> 2026-02-15
```
