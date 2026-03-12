---
name: lo-work
description: Executes features and tasks. Reads plans from .lo/work/, handles branch isolation and parallel agent dispatch. Creates backlog entries on the fly for ad-hoc tasks. Delegates execution to superpowers. Use when user says "let's build", "work on this", "start working", "execute", or "/lo:work". Stops when complete — does not ship.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
  - Skill
  - TaskCreate
  - EnterWorktree
metadata:
  author: looselyorganized
  version: 0.6.0
---

# LO Work

Executes features and tasks. Handles branch isolation, plan discovery, and
progress tracking. Delegates execution patterns to superpowers.

## Critical Rules

- This skill executes — it does NOT ship. Never push, create PRs, or mark items done in the backlog. When work is complete, suggest `/lo:ship`.
- Task execution NEVER uses subagents or agent teams unless the task has a plan with explicit parallel markers.
- Re-read BACKLOG.md from disk on every invocation. Never rely on cached content.
- The `.lo/` directory must exist. If missing, tell user to run `/lo:setup` first.

---

<work-flow>
## Step 1: Find or Create the Work Item

Determine what to work on from the argument provided.

**If argument is an ID** (f{NNN} or t{NNN}):
  - Look up the item in BACKLOG.md
  - Check for a matching directory in `.lo/work/`

**If argument is a description string** (not an ID):
  - Search BACKLOG.md for a fuzzy match on the description
  - If a match is found, use that existing entry
  - If no match is found, classify it as a task and create a new backlog entry:
    1. Read `last_task` from BACKLOG.md frontmatter
    2. Add a new entry under `## Tasks`:

           - [ ] t{NNN} Task description

    3. Increment `last_task` in frontmatter
    4. Update the `updated:` date to today
  - Mark this as an ad-hoc task (no plan, direct execution)

**If no argument:**
  - Scan `.lo/work/` for directories containing plan files
  - Read open items from BACKLOG.md
  - Present a combined view:

        Active work:
          f009 Image Generation — .lo/work/f009-image-gen/ (phase 1 of 2)

        Open in backlog:
          f010 Real-time Collab Editing
          t015 Fix button color

        Pick up active work, or start something new?

  - Wait for the user to choose before continuing.

---

## Step 2: Read Plan and Project Context

Gather everything needed before execution begins.

1. Read `.lo/project.yml` — extract `status` for test expectations and branch strategy.
2. Check `.lo/work/<id>-slug/` for plan files (`001-*.md`, `002-*.md`, etc.).
3. Check for `ears-requirements.md` in the work directory.
4. Check for `parked-context.md` (moved there by `/lo:plan`).

**If feature with plans:**
  - Parse tasks from plan files. Identify dependencies and parallel markers.
  - Determine execution strategy (sequential vs parallel). Consult `references/execution-patterns.md` for dispatch details.
  - Present the plan summary to the user and wait for confirmation before executing.

**If task without plan:**
  - Direct execution. Skip to Step 4.

---

## Step 3: Set Up Branch Isolation

Read the project status from `.lo/project.yml` and the current git branch, then apply these defaults:

| Status | Current Branch | Default Action |
|--------|---------------|----------------|
| explore | any | Stay on current branch (no prompt) |
| build/open | main | New branch: `feat/f{NNN}-slug` or `fix/t{NNN}-slug` |
| build/open | release branch | Branch off the release branch |
| build/open | already on feature branch | Stay on current branch |
| any | dirty working tree | Warn, offer stash or worktree |

**For explore status:** skip the branch prompt entirely. Stay where you are.

**For build/open status:** present the recommendation but allow override:

    You're on main. Recommendation: feat/f009-image-gen

    1. New branch (recommended)
    2. Stay on main
    3. Something else

Create the branch if chosen:

```bash
git checkout -b feat/f{NNN}-slug
```

---

## Step 4: Execute

Choose the execution path based on the work item type.

**Features with plans:**
  - Check the plan task structure for parallel markers.
  - Sequential tasks (no parallel markers) → invoke `superpowers:executing-plans`. Feed it the plan files, EARS contract if present, and project context.
  - Parallel markers present → invoke `superpowers:subagent-driven-development`. Feed the same context. Let the superpower handle agent dispatch and merge.

**Tasks without plans:**
  - Execute directly. No subagents, no formal plan.
  - Read project status for test expectations:
    - `explore` → no tests mentioned
    - `build` → write tests alongside if the work involves testable logic
    - `open` → tests expected for all testable code

**Ad-hoc tasks** (created from a description string in Step 1):
  - Execute directly, commit as you go.
  - Follow the same test expectations as tasks without plans.

---

## Step 5: Completion

When all work is done, report and stop.

    Work complete: <id> "<name>"
    Branch: <branch-name>

    Ready to ship? Run /lo:ship

    [Worth a milestone? Run /lo:stream]
    [Anything reusable? Run /lo:solution]

HARD GATE: Do NOT automatically proceed to shipping. Do not push, create a PR, or mark the item done. The user decides when to ship.
</work-flow>

---

## Error Handling

- **No `.lo/` directory** → Stop. Tell the user: "Run `/lo:setup` first to initialize the project."
- **No plans for a feature** → Ask: "No plans found for <id>. Run `/lo:plan <id>` first, or work on it directly?" If the user chooses direct execution, treat it as a task without plans.
- **Merge conflicts** → Stop immediately. Report the conflicting files and ask the user how to proceed. Do not attempt automatic resolution.
- **Tests fail** → Stop. Report the failures. Fix before continuing execution.
- **Superpowers unavailable** → Fall back to inline execution. Execute plan tasks sequentially without subagent dispatch.

---

<example name="feature-with-subagents">
User: /lo:work f009

Reading BACKLOG.md... found f009 "Image Generation"
Reading .lo/work/f009-image-gen/001-image-service.md...
Reading .lo/work/f009-image-gen/ears-requirements.md...
Reading .lo/project.yml... status: build

Plan summary:
  Phase 1 — Image Service (3 tasks, 2 parallel)
    Task 1: Create image generation service [parallel]
    Task 2: Add storage adapter [parallel]
    Task 3: Wire into MDX pipeline [depends on 1, 2]

  Proceed? (yes / adjust)

User: yes

You're on main. Recommendation: feat/f009-image-gen

1. New branch (recommended)
2. Stay on main
3. Something else

User: 1

Created branch: feat/f009-image-gen
Dispatching parallel tasks via superpowers...

[execution proceeds]

Work complete: f009 "Image Generation"
Branch: feat/f009-image-gen

Ready to ship? Run /lo:ship

[Worth a milestone? Run /lo:stream]
[Anything reusable? Run /lo:solution]
</example>

<example name="ad-hoc-task">
User: /lo:work fix the dark mode toggle on the settings page

Searching BACKLOG.md... no match found.
Creating ad-hoc task: t016 "Fix dark mode toggle on settings page"
Reading .lo/project.yml... status: explore

Staying on current branch (explore status).
Executing directly...

[fixes the toggle, commits]

Work complete: t016 "Fix dark mode toggle on settings page"
Branch: main

Ready to ship? Run /lo:ship
</example>

<example name="task-direct-execution">
User: /lo:work t015

Reading BACKLOG.md... found t015 "Fix button color"
No plan files in .lo/work/. Direct execution.
Reading .lo/project.yml... status: build

You're on main. Recommendation: fix/t015-button-color

1. New branch (recommended)
2. Stay on main
3. Something else

User: 1

Created branch: fix/t015-button-color

[fixes button color, writes test, commits]

Work complete: t015 "Fix button color"
Branch: fix/t015-button-color

Ready to ship? Run /lo:ship
</example>
