---
name: backlog
description: Manages the LO project backlog in .lo/BACKLOG.md. Supports viewing, adding, updating, and starting features and tasks. Use when user says "backlog", "add task", "add feature", "update backlog", "what should I work on", "what's next", "start a feature", "view backlog", "/backlog", "/task", or "/feature".
metadata:
  version: 0.2.0
  author: LORF
  category: work-management
  tags: [lo, backlog, tasks, features]
---

# LO Backlog Manager

Manages the project backlog at `.lo/BACKLOG.md`. Features and tasks live here until they graduate into active work.

## When to Use

- User invokes `/lo:backlog`
- User says "add task", "add feature", "what's next", "what should I work on"
- User wants to pick up a feature and start working on it

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- If `.lo/BACKLOG.md` doesn't exist, create it with the default template before proceeding.
- ALWAYS read the current backlog before making changes — never overwrite blindly.
- Update the `updated:` date in frontmatter whenever the file is modified.
- Feature status values: `backlog` | `active -> .lo/work/<name>/` | `done -> YYYY-MM-DD`
- Tasks are checkboxes: `- [ ]` open, `- [x] ~~text~~ -> YYYY-MM-DD` done.
- All files are plain Markdown with YAML frontmatter. No MDX.

## Modes

Detect mode from arguments. `/lo:backlog` with no args → view. `/lo:backlog view` → view. `/lo:backlog task "fix X"` → add task. `/lo:backlog feature "auth"` → add feature. `/lo:backlog start "auth"` → start feature. `/lo:backlog update` → pick item to update. `/lo:backlog update "auth"` → update specific item.

### Mode 1: View Backlog

Arguments: none, or `view`

Read `.lo/BACKLOG.md` and display a summary:

    Backlog (updated YYYY-MM-DD):

    Features:
      [backlog] Feature Name — short description
      [active]  Feature Name -> .lo/work/feature-name/
      [done]    Feature Name -> completed YYYY-MM-DD

    Tasks:
      [ ] Task description
      [x] Completed task -> YYYY-MM-DD

If backlog is empty, suggest adding items.

### Mode 2: Add Task

Arguments: `task "description"`

1. Read current BACKLOG.md
2. Append a new checkbox under `## Tasks`: `- [ ] description`
3. Update `updated:` date
4. Confirm: `Task added: "description"`

If no description provided, prompt for one.

### Mode 3: Add Feature

Arguments: `feature "name"`

1. Read current BACKLOG.md
2. Ask for a 1-2 sentence description if not provided
3. Append under `## Features`:

        ### Feature Name
        Description of the feature.
        Status: backlog

4. Update `updated:` date
5. Confirm: `Feature added: "Feature Name" (status: backlog)`

### Mode 4: Start Feature

Arguments: `start "name"`

Graduates a feature from backlog to active work, creates a plan, then offers to execute it.

1. Read current BACKLOG.md
2. Find the matching feature (fuzzy match on name)
3. If not found, show available backlog features and ask user to choose
4. Derive directory name: kebab-case from feature name
5. Create `.lo/work/<feature-name>/` directory
6. Update the feature's status line: `Status: active -> .lo/work/<feature-name>/`
7. Update `updated:` date
8. Confirm:

        Feature started: "<name>"
        Work directory: .lo/work/<feature-name>/

9. **Brainstorm:** Invoke `superpowers:brainstorming` to explore the design with the user
10. **Plan:** Invoke `superpowers:writing-plans` (or enter plan mode) to create a structured implementation plan
11. **Save plan** to `.lo/work/<feature-name>/001-<phase-slug>.md` using the plan file format from `/lo:work`
12. **Bridge to execution:**

        Plan saved: .lo/work/<feature-name>/001-<phase-slug>.md

        Ready to start executing? Type /lo:work to begin.

### Mode 5: Update Item

Arguments: `update` or `update "name"`

Edit an existing feature or task in the backlog.

**With no name:** List all features and tasks with numbers, ask user to pick one:

    Which item do you want to update?

    Features:
      1. [backlog] Auth system
      2. [active]  Dashboard redesign

    Tasks:
      3. [ ] Fix button color on settings page
      4. [ ] Update dependency versions

    Enter a number:

**With a name:** Find the matching item (fuzzy match).

Once an item is selected, ask what to change:
- **Feature:** name, description, or status
- **Task:** description, or mark done/undone

Apply the edit, update `updated:` date, confirm:

    Updated: "Auth system" — description changed

### Mode 6: Complete Task

When user says "done with X", "finished X", or checks off a task:

1. Find the matching task in BACKLOG.md
2. Update it: `- [x] ~~description~~ -> YYYY-MM-DD`
3. Update `updated:` date

### Mode 7: Complete Feature

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

    - [ ] Review PROJECT.md and fill any TODO placeholders

Use today's date for the `updated` field.
