---
name: backlog
description: Manages the LO project backlog in .lo/BACKLOG.md. Registry for features and tasks — view, add, update. Not for planning or execution — use /lo:plan to design, /lo:work to build. Use when user says "backlog", "add task", "add feature", "update backlog", "view backlog", "/backlog", "/task", or "/feature". For starting features use /lo:plan. For executing work use /lo:work. For completing/shipping use /lo:ship.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
---

# LO Backlog Manager

Manages the project backlog at `.lo/BACKLOG.md`. Features and tasks live here as a registry. Planning and execution are handled by `/lo:plan` and `/lo:work`.

## Format

Features and tasks use the same list-item pattern. See `references/backlog-format-contract.md` for the full spec.

```markdown
- [ ] f{NNN} Feature Name
  Description of the feature.
  [active](.lo/work/f{NNN}-slug/)

- [x] f001 Changing LORF to LO
  Rename .lorf/ directory to .lo/.
  [done] v0.3.0 2026-02-25

- [ ] t004 Add epic to backlog command
```

Status lines: no line = backlog, `[active](path)` = in progress, `[done] version YYYY-MM-DD` = shipped (Build/Open projects), `[done] YYYY-MM-DD` = shipped (Explore/Closed projects).

### Epic Grouping

Epics are `### Epic Name` sub-headers under `## Features` or `## Tasks`. Items listed under an epic belong to it. Items not under any epic are ungrouped.

```markdown
## Features

- [ ] f007 Auth System
  User authentication with OAuth.

### Platform Expansion

- [ ] f008 Mobile App
  Native iOS and Android apps.

- [ ] f009 API Gateway
  Public REST API for third-party integrations.
```

## When to Use

- User invokes `/lo:backlog`
- User says "add task", "add feature", "view backlog", "update backlog"

## When NOT to Use — Redirect Instead

- "start feature", "plan this", "brainstorm" → `/lo:plan`
- "work on", "let's build", "execute" → `/lo:work`
- "ship it", "done with", "mark done" → `/lo:ship`

## Critical Rules

- The `.lo/` directory must exist — if it doesn't, tell the user to run `/lo:new` first.
- If `.lo/BACKLOG.md` doesn't exist, create it from the default template (see `references/backlog-format-contract.md`).
- ALWAYS re-read `.lo/BACKLOG.md` from disk on every invocation. Never rely on a previous read.
- Update the `updated:` date in frontmatter on every modification.
- Every feature and task needs an ID. IDs are sequential and never reused.

## Modes

Detect from arguments: no args → view, `view` → view, `task "desc"` → add task, `feature "name"` → add feature, `epic "name"` → add epic, `update` → pick item to update.

### Mode 1: View Backlog

Read `.lo/BACKLOG.md` and display a summary. If epics exist (any `### Epic Name` sub-headers under Features or Tasks), group items under their epic headings. Ungrouped items appear first.

    Backlog (updated YYYY-MM-DD):

    Features:
      [ ] f006 Plugin Redesign — active -> .lo/work/f006-plugin-redesign/
      [x] f001 Changing LORF to LO — v0.3.0, 2026-02-25

      Platform Expansion:
        [ ] f008 Mobile App
        [ ] f009 API Gateway

    Tasks:
      [ ] t004 Add epic to backlog command
      [x] t001 Audit /work — v0.3.2, 2026-03-07

### Mode 2: Add Task

Arguments: `task "description"` or `task "description" --epic "Epic Name"`

1. Read current BACKLOG.md
2. Determine next task ID: scan for highest `t{NNN}`, increment
3. If `--epic` is provided:
   - Find the `### Epic Name` sub-header under `## Tasks`
   - If the epic doesn't exist, create the `### Epic Name` header at the end of `## Tasks` first
   - Append the task under that epic's section
4. Otherwise, append under `## Tasks` (before any epic sub-headers, so ungrouped items stay at the top):

       - [ ] t{NNN} description

5. Update `updated:` date
6. Confirm: `Added: t{NNN} "description"` (include `(Epic Name)` if placed under an epic)

### Mode 3: Add Feature

Arguments: `feature "name"` or `feature "name" --epic "Epic Name"`

1. Read current BACKLOG.md
2. Determine next feature ID: scan for highest `f{NNN}`, increment
3. Ask for a 1-2 sentence description if not provided
4. If `--epic` is provided:
   - Find the `### Epic Name` sub-header under `## Features`
   - If the epic doesn't exist, create the `### Epic Name` header at the end of `## Features` first
   - Append the feature under that epic's section
5. Otherwise, append under `## Features` (before any epic sub-headers, so ungrouped items stay at the top):

       - [ ] f{NNN} Feature Name
         Description of the feature.

6. Update `updated:` date
7. Confirm: `Added: f{NNN} "Feature Name"` (include `(Epic Name)` if placed under an epic)

### Mode 4: Update Item

Arguments: `update` or `update "name"` or `update "f{NNN}"` or `update "t{NNN}"`

**With no name:** List all items, ask user to pick one.

**With a name or ID:** Find the matching item (exact ID or fuzzy name match).

Once selected, ask what to change:
- Name, description, or status

Apply the edit, update `updated:` date, confirm.

### Mode 5: Add Epic

Arguments: `epic "name"` or `epic "name" --section features|tasks`

1. Read current BACKLOG.md
2. Determine placement:
   - If `--section tasks` is specified, add under `## Tasks`
   - Otherwise, add under `## Features` (default)
3. Append a `### Epic Name` header at the end of the target section (after all existing items and epics)
4. Update `updated:` date
5. Confirm: `Added epic: "Epic Name" under Features` (or Tasks)

The epic header is just a `### Name` line — items are added under it later via `feature --epic` or `task --epic`.

## Examples

<example name="adding-a-feature">
User: /lo:backlog feature "user authentication"

Added: f003 "User Authentication"
</example>

<example name="viewing-the-backlog">
User: /lo:backlog

Backlog (updated 2026-03-01):

Features:
  [ ] f003 User Authentication
  [ ] f001 Dashboard Redesign — active -> .lo/work/f001-dashboard-redesign/

Tasks:
  [ ] t004 Update dependency versions
  [x] t003 Fix button color — 2026-02-28
</example>

<example name="adding-an-epic">
User: /lo:backlog epic "Platform Expansion"

Added epic: "Platform Expansion" under Features
</example>

<example name="adding-feature-to-epic">
User: /lo:backlog feature "Mobile App" --epic "Platform Expansion"

Added: f008 "Mobile App" (Platform Expansion)
</example>

<example name="viewing-backlog-with-epics">
User: /lo:backlog

Backlog (updated 2026-03-10):

Features:
  [ ] f003 User Authentication
  [ ] f001 Dashboard Redesign — active -> .lo/work/f001-dashboard-redesign/

  Platform Expansion:
    [ ] f008 Mobile App
    [ ] f009 API Gateway

Tasks:
  [ ] t004 Update dependency versions
</example>
