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
  [done](v0.3.0) 2026-02-25

- [ ] t004 Add epic to backlog command
```

Status lines: no line = backlog, `[active](path)` = in progress, `[done](version) date` = shipped (Build/Open projects), `[done] YYYY-MM-DD` = shipped (Explore/Closed projects).

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

Detect from arguments: no args → view, `view` → view, `task "desc"` → add task, `feature "name"` → add feature, `update` → pick item to update.

### Mode 1: View Backlog

Read `.lo/BACKLOG.md` and display a summary:

    Backlog (updated YYYY-MM-DD):

    Features:
      [ ] f006 Plugin Redesign — active -> .lo/work/f006-plugin-redesign/
      [x] f001 Changing LORF to LO — v0.3.0, 2026-02-25
      [ ] f007 Auth System

    Tasks:
      [ ] t004 Add epic to backlog command
      [x] t001 Audit /work — v0.3.2, 2026-03-07

### Mode 2: Add Task

Arguments: `task "description"`

1. Read current BACKLOG.md
2. Determine next task ID: scan for highest `t{NNN}`, increment
3. Append under `## Tasks`:

       - [ ] t{NNN} description

4. Update `updated:` date
5. Confirm: `Added: t{NNN} "description"`

### Mode 3: Add Feature

Arguments: `feature "name"`

1. Read current BACKLOG.md
2. Determine next feature ID: scan for highest `f{NNN}`, increment
3. Ask for a 1-2 sentence description if not provided
4. Append under `## Features`:

       - [ ] f{NNN} Feature Name
         Description of the feature.

5. Update `updated:` date
6. Confirm: `Added: f{NNN} "Feature Name"`

### Mode 4: Update Item

Arguments: `update` or `update "name"` or `update "f{NNN}"` or `update "t{NNN}"`

**With no name:** List all items, ask user to pick one.

**With a name or ID:** Find the matching item (exact ID or fuzzy name match).

Once selected, ask what to change:
- Name, description, or status

Apply the edit, update `updated:` date, confirm.

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
