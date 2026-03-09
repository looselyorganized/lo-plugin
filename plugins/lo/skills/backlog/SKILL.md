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

## ID Convention

Features get `f{NNN}` IDs, tasks get `t{NNN}` — sequential, never reused. See `references/backlog-format-contract.md` for full format specification.

## When to Use

- User invokes `/lo:backlog`
- User says "add task", "add feature", "view backlog", "update backlog"
## When NOT to Use — Redirect Instead

- User says "start feature", "plan this", "brainstorm" → redirect to `/lo:plan`
- User says "work on", "let's build", "execute" → redirect to `/lo:work`
- User says "ship it", "push and PR", "done with", "mark done" → redirect to `/lo:ship`

## Critical Rules

- The `.lo/` directory must exist — if it doesn't, tell the user to run `/lo:new` first.
- If `.lo/BACKLOG.md` doesn't exist, create it from the default template (see `references/backlog-format-contract.md`).
- ALWAYS re-read `.lo/BACKLOG.md` from disk on every invocation, even for view. Never rely on a previous read from conversation context — the file may have been modified by another session or skill.
- Update the `updated:` date in frontmatter on every modification.
- Every feature and task needs an ID. Format details are in `references/backlog-format-contract.md`.

## Modes

Detect mode from arguments. `/lo:backlog` with no args → view. `/lo:backlog view` → view. `/lo:backlog task "fix X"` → add task. `/lo:backlog feature "auth"` → add feature. `/lo:backlog update` → pick item to update. `/lo:backlog update "auth"` → update specific item.

### Mode 1: View Backlog

Arguments: none, or `view`

Read `.lo/BACKLOG.md` and display a summary:

    Backlog (updated YYYY-MM-DD):

    Features:
      f001 [backlog] Feature Name — short description
      f002 [active]  Feature Name -> .lo/work/f002-feature-name/
      f003 [done]    Feature Name -> 2026-03-01

    Tasks:
      [ ] t001 Task description
      [x] t002 Completed task -> YYYY-MM-DD

If backlog is empty, suggest adding items.

### Mode 2: Add Task

Arguments: `task "description"`

1. Read current BACKLOG.md
2. Determine next task ID: scan BACKLOG.md, `.lo/work/` dirs, and git log for highest `t{NNN}`, increment (IDs are never reused)
3. Append a new checkbox under `## Tasks`: `- [ ] t{NNN} description`
4. Update `updated:` date
5. Confirm: `t{NNN}: "description"`

If no description provided, prompt for one.

### Mode 3: Add Feature

Arguments: `feature "name"`

1. Read current BACKLOG.md
2. Determine next feature ID: scan BACKLOG.md, `.lo/work/` dirs, and git log for highest `f{NNN}`, increment (IDs are never reused)
3. Ask for a 1-2 sentence description if not provided
4. Append under `## Features`:

        ### f{NNN} — Feature Name
        Description of the feature.
        Status: backlog

5. Update `updated:` date
6. Confirm: `f{NNN}: "Feature Name" (status: backlog)`

### Mode 4: Update Item

Arguments: `update` or `update "name"` or `update "f{NNN}"` or `update "t{NNN}"`

Edit an existing feature or task in the backlog.

**With no name:** List all features and tasks, ask user to pick one:

    Which item do you want to update?

    Features:
      f001 [backlog] Auth system
      f002 [active]  Dashboard redesign

    Tasks:
      t001 [ ] Fix button color on settings page
      t002 [ ] Update dependency versions

    Enter an ID or number:

**With a name or ID:** Find the matching item (exact ID match or fuzzy name match).

Once an item is selected, ask what to change:
- **Feature:** name, description, or status
- **Task:** description

Apply the edit, update `updated:` date, confirm:

    Updated: f001 "Auth system" — description changed

## Default BACKLOG.md Template

See `references/backlog-format-contract.md` for the default template and full format specification.

## Examples

### Adding a feature

    User: /lo:backlog feature "user authentication"

    Agent reads BACKLOG.md, finds highest feature ID is f002, creates:

    ### f003 — User Authentication
    Description pending.
    Status: backlog

    Response: f003: "User Authentication" (status: backlog)

### Viewing the backlog

    User: /lo:backlog

    Backlog (updated 2026-03-01):

    Features:
      f001 [active]  Dashboard redesign -> .lo/work/f001-dashboard-redesign/
      f003 [backlog] User Authentication

    Tasks:
      [ ] t004 Update dependency versions
      [x] t003 Fix button color -> 2026-02-28
