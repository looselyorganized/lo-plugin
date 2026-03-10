# BACKLOG.md Format Contract

> From the .lo/ Convention Spec v0.1.0

The project backlog lives at `.lo/BACKLOG.md`. It is the single registry for features and tasks.

## Frontmatter

| Field | Type | Description |
|-------|------|-------------|
| `updated` | date | Date of last modification (YYYY-MM-DD) |

## Feature Format

```markdown
- [ ] f{NNN} Feature Name
  Description of the feature.
  status-line (optional; omit for backlog items)
```

### Feature Elements

| Element | Format | Description |
|---------|--------|-------------|
| Checkbox | `- [ ]` / `- [x]` | Open or completed |
| ID | `f{NNN}` | Feature identifier |
| Name | Free text after ID | Short display name |
| Description | Indented line below | 1-2 sentence summary (optional) |
| Status | Indented line below description | Lifecycle state (see below) |

## Task Format

```markdown
- [ ] t{NNN} Task description
  status-line (optional)

- [x] t{NNN} Task description
  [done] v0.4.0 2026-03-09
```

Tasks use a simplified pattern where the first-line description after the ID serves as the task name; there is no separate Name field.

### Task Elements

| Element | Format | Description |
|---------|--------|-------------|
| Checkbox | `- [ ]` / `- [x]` | Open or completed |
| ID | `t{NNN}` | Task identifier |
| Description | Free text after ID | Acts as the task name |
| Status | Indented line below | Lifecycle state (optional; absence = backlog) |

## Status Lines

| State | Checkbox | Format | Example |
|-------|----------|--------|---------|
| Backlog | `- [ ]` | (no status line) | Just the checkbox + ID + name |
| Active | `- [ ]` | `[active](.lo/work/<id>-slug/)` | Link to work directory (`f{NNN}` for features, `t{NNN}` for tasks) |
| Done (no version) | `- [x]` | `[done] YYYY-MM-DD` | Explore/Closed projects |
| Done (versioned) | `- [x]` | `[done] vX.Y.Z YYYY-MM-DD` | Build/Open projects |

The `[active]` tag uses Markdown link syntax for navigation. The `[done]` tag uses plain text with an optional version prefix.

## ID Convention

- Features: `f{NNN}` (e.g., `f001`, `f002`)
- Tasks: `t{NNN}` (e.g., `t001`, `t002`)
- IDs are sequential and never reused, even after deletion
- To find the next ID, scan BACKLOG.md for the highest existing `f{NNN}` or `t{NNN}` and increment

## Status Transitions

- **Backlog → Active:** `/lo:plan` adds `[active](.lo/work/<id>-slug/)` when creating a work directory (`f{NNN}` for features, `t{NNN}` for tasks)
- **Active → Done:** `/lo:ship` updates the status line; the format is determined by project type — Build/Open projects use the versioned form `[done] vX.Y.Z YYYY-MM-DD`, while Explore/Closed projects use `[done] YYYY-MM-DD` (see Status Lines table above)
- Features and tasks stay in BACKLOG.md through their full lifecycle — never deleted

## Epic Grouping

Epics are optional `### Epic Name` sub-headers under `## Features` or `## Tasks`. Items listed under an epic belong to it. Items not under any epic are ungrouped and appear before any epic sections.

```markdown
## Features

- [ ] f007 Auth System
  User authentication with OAuth.

### Platform Expansion

- [ ] f008 Mobile App
  Native iOS and Android apps.

- [ ] f009 API Gateway
  Public REST API for third-party integrations.

## Tasks

- [ ] t004 Add epic to backlog command

### Tech Debt

- [ ] t005 Migrate to new ORM
```

### Epic Rules

- Epic headers use `###` (h3) level — one level below the section header (`##`)
- Epic names are free text (no ID required)
- An epic with no items underneath is valid (empty epic, waiting for items)
- Items before the first `###` in a section are ungrouped
- Epics cannot be nested (no `####` sub-epics)

## Validation Rules

- `updated` must be a valid YYYY-MM-DD date
- Every feature/task must have a checkbox with an `f{NNN}` or `t{NNN}` ID
- IDs must be unique within their type (no duplicate `f{NNN}` or `t{NNN}`)
- All content is plain Markdown with YAML frontmatter — no MDX

## Default Template

```yaml
---
updated: YYYY-MM-DD
---

## Features

_No features yet. Use `/lo:backlog feature "name"` to add one._

## Tasks

_No tasks yet. Use `/lo:backlog task "description"` to add one._
```

Use today's date for the `updated` field when creating a new backlog.

## Example

```yaml
---
updated: 2026-03-09
---

## Features

- [x] f001 Changing LORF to LO
  Rename `.lorf/` directory to `.lo/`, update all references.
  [done] v0.3.0 2026-02-25

- [ ] f006 Plugin Redesign
  Redesign using Claude Code's latest capabilities.
  [active](.lo/work/f006-plugin-redesign/)

- [ ] f007 Auth System
  User authentication with OAuth.

### Platform Expansion

- [ ] f008 Mobile App
  Native iOS and Android apps.

## Tasks

- [x] t001 Audit /work
  [done] v0.3.2 2026-03-07
- [ ] t004 Add epic to backlog command

### Tech Debt

- [ ] t005 Migrate to new ORM
```
