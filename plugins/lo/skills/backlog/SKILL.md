---
name: backlog
description: Manages the LO project backlog in .lo/BACKLOG.md. Supports viewing, adding, updating, starting features, and picking up tasks. Use when user says "backlog", "add task", "add feature", "update backlog", "what should I work on", "what's next", "start a feature", "work on task", "view backlog", "/backlog", "/task", or "/feature".
metadata:
  version: 0.2.1
  author: LORF
---

# LO Backlog Manager

Manages the project backlog at `.lo/BACKLOG.md`. Features and tasks live here until they graduate into active work.

## ID Convention

All backlog items get sequential IDs scoped to the project:
- Features: `f001`, `f002`, etc.
- Tasks: `t001`, `t002`, etc.

IDs are permanent — never reuse an ID, even after deletion. To determine the next ID, scan BACKLOG.md for the highest existing `f{NNN}` or `t{NNN}` and increment.

## When to Use

- User invokes `/lo:backlog`
- User says "add task", "add feature", "what's next", "what should I work on"
- User wants to pick up a feature and start working on it

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- If `.lo/BACKLOG.md` doesn't exist, create it with the default template before proceeding.
- ALWAYS read the current backlog before making changes — never overwrite blindly.
- Update the `updated:` date in frontmatter whenever the file is modified.
- Feature status values: `backlog` | `active -> .lo/work/f{NNN}-slug/` | `done -> YYYY-MM-DD`
- Tasks are checkboxes: `- [ ] t{NNN} description` open, `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD` done.
- All files are plain Markdown with YAML frontmatter. No MDX.
- Every feature and task MUST have an ID. Never create items without one.

## Modes

Detect mode from arguments. `/lo:backlog` with no args → view. `/lo:backlog view` → view. `/lo:backlog task "fix X"` → add task. `/lo:backlog feature "auth"` → add feature. `/lo:backlog start "auth"` → start feature. `/lo:backlog work "t001"` → execute a task. `/lo:backlog update` → pick item to update. `/lo:backlog update "auth"` → update specific item.

### Mode 1: View Backlog

Arguments: none, or `view`

Read `.lo/BACKLOG.md` and display a summary:

    Backlog (updated YYYY-MM-DD):

    Features:
      f001 [backlog] Feature Name — short description
      f002 [active]  Feature Name -> .lo/work/f002-feature-name/
      f003 [done]    Feature Name -> completed YYYY-MM-DD

    Tasks:
      [ ] t001 Task description
      [x] t002 Completed task -> YYYY-MM-DD

If backlog is empty, suggest adding items.

### Mode 2: Add Task

Arguments: `task "description"`

1. Read current BACKLOG.md
2. Determine next task ID: scan for highest `t{NNN}`, increment
3. Append a new checkbox under `## Tasks`: `- [ ] t{NNN} description`
4. Update `updated:` date
5. Confirm: `t{NNN}: "description"`

If no description provided, prompt for one.

### Mode 3: Add Feature

Arguments: `feature "name"`

1. Read current BACKLOG.md
2. Determine next feature ID: scan for highest `f{NNN}`, increment
3. Ask for a 1-2 sentence description if not provided
4. Append under `## Features`:

        ### f{NNN} — Feature Name
        Description of the feature.
        Status: backlog

5. Update `updated:` date
6. Confirm: `f{NNN}: "Feature Name" (status: backlog)`

### Mode 4: Start Feature

Arguments: `start "name"` or `start "f{NNN}"`

Graduates a feature from backlog to active work, creates a plan, then offers to execute it.

1. Read current BACKLOG.md
2. Find the matching feature (match by ID `f{NNN}` or fuzzy match on name)
3. If not found, show available backlog features and ask user to choose
4. Derive directory name: `f{NNN}-slug` (kebab-case from feature name, prefixed with ID)
5. Create `.lo/work/f{NNN}-slug/` directory
6. Update the feature's status line: `Status: active -> .lo/work/f{NNN}-slug/`
7. Update `updated:` date
8. Confirm:

        Feature started: f{NNN} "<name>"
        Work directory: .lo/work/f{NNN}-slug/

9. **Isolation:** Before any design or implementation work, ask the user about branch isolation. Check `git branch --show-current` and `git status` to assess current state, then present:

        You're on <current-branch>.

        1. New branch: feat/f{NNN}-slug (recommended)
        2. New worktree (recommended if you have uncommitted work on current branch)
        3. Stay on <current-branch>

    **When to recommend worktree over branch:**
    - Working tree is dirty (uncommitted changes on current branch)
    - User is mid-work on something else and context-switching
    - Feature is large/multi-phase and benefits from a separate directory

    **When to recommend branch:**
    - Working tree is clean
    - Simple feature, single phase
    - Default choice for most work

    If the user picks worktree, use the EnterWorktree tool. If they pick branch, create it with `git checkout -b feat/f{NNN}-slug`. If they stay, note this so `/lo:ship` knows there's no feature branch.

    **Do not proceed to step 10 until the user answers.**

10. **Brainstorm:** Invoke `superpowers:brainstorming` to explore the design with the user
11. **Plan:** Invoke `superpowers:writing-plans` (or enter plan mode) to create a structured implementation plan
12. **Save plan** to `.lo/work/f{NNN}-slug/001-<phase-slug>.md` using the plan file format from `/lo:work`
13. **Bridge to execution:**

        Plan saved: .lo/work/f{NNN}-slug/001-<phase-slug>.md

        Ready to start executing? Type /lo:work to begin.

### Mode 5: Work on Task

Arguments: `work "t{NNN}"` or `work "description"`

Picks up a task for execution with an isolation prompt. Tasks are smaller than features — they don't need brainstorming or plans, but they still deserve a branch decision.

1. Read current BACKLOG.md
2. Find the matching task (by ID `t{NNN}` or fuzzy match on description)
3. If not found, show open tasks and ask user to choose
4. Check `git branch --show-current` and `git status`, then ask:

        Working on: t{NNN} "<description>"
        You're on <current-branch>.

        1. New branch: fix/t{NNN}-slug (recommended for non-trivial changes)
        2. Stay on <current-branch> (fine for quick fixes)

    If the working tree is dirty, add option: `3. New worktree (you have uncommitted changes)`

    **Do not proceed until the user answers.**

5. If they chose a branch, create it: `git checkout -b fix/t{NNN}-slug`
6. If they chose worktree, use EnterWorktree tool
7. Tell the user to go ahead and work. When done:

        Ready to ship t{NNN}? You can:
          - /lo:ship (if on a branch — runs full quality pipeline + PR)
          - /lo:backlog done "t{NNN}" (if on main — just marks it complete)

**Ship path for tasks on branches:** `/lo:ship` handles commit, push, PR as normal. After merge, the task gets marked done.

**Ship path for tasks on main:** User commits directly, then marks done with `/lo:backlog done "t{NNN}"`.

### Mode 6: Update Item

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
- **Task:** description, or mark done/undone

Apply the edit, update `updated:` date, confirm:

    Updated: f001 "Auth system" — description changed

### Mode 7: Complete Task

When user says "done with X", "finished X", or checks off a task:

1. Find the matching task in BACKLOG.md (by ID or fuzzy name)
2. Update it: `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD`
3. Update `updated:` date

### Mode 8: Complete Feature

When a feature is shipped (typically triggered by lo:ship, not invoked directly):

1. Update the feature's status: `Status: done -> YYYY-MM-DD`
2. Update `updated:` date

## Default BACKLOG.md Template

If BACKLOG.md doesn't exist, create it:

    ---
    updated: YYYY-MM-DD
    ---

    ## Features

    _No features yet. Use `/lo:backlog feature "name"` to add one._

    ## Tasks

    - [ ] t001 Review PROJECT.md and fill any TODO placeholders

Use today's date for the `updated` field.
