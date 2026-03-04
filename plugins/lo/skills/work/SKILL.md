---
name: work
description: Executes features (from plans) and tasks (directly) in .lo/work/. Handles branch isolation, worktree-based parallelization, and progress tracking. Not for planning — use /lo:plan to design first. Stops when complete — does not ship. Use when user says "start working", "let's build", "execute the plan", "work on", or "/work".
metadata:
  version: 0.3.0
  author: LORF
---

# LO Work Executor

Executes work for both features (from plans in `.lo/work/`) and tasks (directly from backlog). Handles isolation, parallelization with worktrees, and progress tracking. Stops when complete — shipping is a separate step (`/lo:ship`).

## When to Use

- User invokes `/lo:work`
- User says "start working", "let's build", "execute the plan", "work on"
- A feature has plans in `.lo/work/` ready for execution
- A task from the backlog is ready to be picked up

## Critical Rules

- The `.lo/work/` directory must exist — if it doesn't, tell the user to run `/lo:new` first.
- Do not ship code from this skill. Execution and quality are separate concerns — `/lo:ship` handles the quality pipeline.
- Set up branch isolation before executing. Working directly on main risks polluting the shared branch with incomplete work.
- Be transparent about what's running in parallel and why.
- Stop and report when a plan phase is complete. Ask before proceeding to the next phase.
- Work directories are named `f{NNN}-slug/` for features and `t{NNN}-slug/` for tasks.

## Modes

Detect from arguments:
- `/lo:work` with no args → find active work
- `/lo:work f003` → execute feature f003's plan
- `/lo:work t005` → pick up task t005 for execution

---

## Feature Execution

### Step 1: Find Active Work

**With argument (`f{NNN}`):** Look up `.lo/work/f{NNN}-slug/` directly.

**No argument:** Scan `.lo/work/` for feature directories containing plan files (numbered: `001-*.md`, `002-*.md`).

**If no work directories exist:**
Tell user to use `/lo:backlog feature "name"` then `/lo:plan f{NNN}` to create plans.

**If directories exist but no plan files:**
Tell user the feature directory exists but needs plans. Redirect to `/lo:plan f{NNN}`.

**If multiple features have plans:** List them with IDs and ask which to work on:

    Active features with plans:
      f003 auth-system — 2 phases
      f005 dashboard-redesign — 1 phase

    Which feature?

### Step 2: Read the Plan

Read the current plan file (lowest-numbered incomplete plan):

1. Parse the plan's tasks, dependencies, and parallelization markers
2. Determine execution strategy based on task structure
3. Present a summary:

        Working on: f003 auth-system
        Plan: 001-<phase-name>.md

        Tasks:
          1. [description] — sequential
          2. [description] — can parallel with 3
          3. [description] — can parallel with 2
          4. [description] — depends on 2, 3

        Strategy: [sequential | subagents | agent teams]

Wait for user confirmation before executing.

### Step 3: Set Up Isolation

**The feature branch is the integration point.** All work — sequential, subagent, or team — merges into it.

Check `git branch --show-current` and `git status`, then recommend:

- Already on a feature branch (e.g., `feat/f003-*`) → recommend staying
- On main, clean working tree → recommend new branch
- On main, dirty working tree → recommend new branch (stash or commit first)

Present:

    You're on <current-branch>.

    1. New branch: feat/f{NNN}-slug (recommended)
    2. Stay on <current-branch>
    3. Something else

**Do not proceed until the user answers.**

If they pick a new branch: `git checkout -b feat/f{NNN}-slug`
If they stay: note this so `/lo:ship` knows there's no feature branch.

### Step 3.5: Check Project Status for Test Expectations

Read `.lo/PROJECT.md` status field:

- **`Explore`** — Do not mention tests. Speed is the priority.
- **`Build`** — When writing implementation code with testable logic, write tests alongside it. If `.github/workflows/ci.yml` exists, ensure new test files are covered by the workflow. If the workflow doesn't exist yet, suggest running `/lo:status Build` to generate it.
- **`Open`** — Tests are expected for all testable code. Flag any testable logic without tests.

**What counts as testable logic:** Functions with business logic, parsers, validators, data transformations, state machines, API handlers. **Not testable:** Config, types, UI layout, markdown, thin wrappers.

**Test gap check:** Before executing, scan the plan tasks for test-related work. If status is `Build` or `Open` and the plan contains testable logic but no test tasks, flag this to the user: "This plan has no test tasks but the project is in [Build/Open] status. Add tests to the plan, or proceed without?" Do not block — let the user decide.

This check informs execution behavior — it does not block work.

### Step 4: Execute

**All execution uses worktrees.** Every level creates a worktree for isolation — this keeps the user's working directory clean and prevents partial work from polluting the feature branch.

Choose parallelization level based on the plan's task structure:

#### Level 1 — Sequential

Simple tasks or tasks with dependencies between all steps. Execute one at a time in a worktree, merge to feature branch after each task completes.

```
feat/f003-auth (feature branch) ← merge target
  └── worktree → task 1 → merge → task 2 → merge → task 3 → merge → task 4 → merge
```

#### Level 2 — Subagents

Independent tasks within a phase. Each subagent gets its own worktree. The main agent coordinates merges on the feature branch.

```
feat/f003-auth (feature branch) ← main agent coordinates here
  ├── subagent A (worktree) → task 2 → returns branch
  ├── subagent B (worktree) → task 3 → returns branch
  └── main agent merges A, then B into feat/f003-auth
      then executes task 4 (depends on 2 + 3)
```

#### Level 3 — Agent Teams

Large features with substantial independent workstreams. Each team member gets their own worktree.

```
feat/f003-auth (feature branch) ← team lead coordinates
  ├── teammate "api" (worktree) → builds endpoints → returns branch
  ├── teammate "ui" (worktree) → builds components → returns branch
  └── team lead merges both into feat/f003-auth
```

For dispatch protocols, merge procedures, error handling, and worktree cleanup details, see `references/execution-patterns.md`.

**Choosing between levels:**

| Signal | Level |
|--------|-------|
| All tasks depend on each other | Sequential |
| 2-4 independent tasks in a phase | Subagents |
| 5+ independent tasks or multi-day workstreams | Agent Teams |
| Tasks touch overlapping files | Sequential (safest) |
| Tasks touch completely separate areas | Subagents or Teams |

**Transparency requirement:** Always tell the user how many parallel tracks are running, what each is doing, when they complete, and if any fail.

### Step 5: Track Progress

As tasks complete:
1. Mark done in the plan file: `- [x] Task description`
2. Report progress
3. When all tasks in a phase complete:

        Phase complete: 001-<phase-name>
          [N] tasks completed
          Feature: f003 auth-system
          Branch: feat/f003-auth-system

        Next phase: 002-<phase-name> (if exists)
        Continue? Or ship with /lo:ship?

### Step 6: Phase Boundary

When a plan phase completes:
- If another phase exists → ask whether to continue
- If no more phases → report completion, suggest `/lo:ship`

Do NOT automatically proceed to shipping.

---

## Task Execution

Tasks are smaller than features — they don't need formal plans. `/lo:work t{NNN}` picks up a task and executes it directly.

### Step 1: Find the Task

1. Read `.lo/BACKLOG.md`
2. Find the matching task by ID `t{NNN}` or fuzzy match on description
3. If not found, show open tasks and ask user to choose

### Step 2: Check for a Plan

Check if `.lo/work/t{NNN}-slug/` exists with plan files:
- **Plan exists:** Follow the feature execution flow (Steps 2-6 above) using the task's plan
- **No plan:** Continue to direct execution below

### Step 3: Set Up Isolation

Check `git branch --show-current` and `git status`, then ask:

    Working on: t{NNN} "<description>"
    You're on <current-branch>.

    1. New branch: fix/t{NNN}-slug (recommended for non-trivial changes)
    2. Stay on <current-branch> (fine for quick fixes)

If the working tree is dirty, add option: `3. New worktree (you have uncommitted changes)`

**Do not proceed until the user answers.**

If they chose a branch: `git checkout -b fix/t{NNN}-slug`
If they chose worktree: use the EnterWorktree tool

### Step 4: Execute

Execute the task directly. If the task description provides enough context, implement it. If the scope is unclear or the task requires decisions, ask the user before proceeding. Tasks are typically small enough for sequential execution — no subagents needed.

### Step 5: Completion

When the task is done:

    Task complete: t{NNN} "<description>"
    Branch: fix/t{NNN}-slug

    Ready to ship? Run /lo:ship to commit, push, and create a PR.

---

## How Work Reads Plans

Plan files are created by `/lo:plan`. Execute numbered files (`001-*.md`, `002-*.md`) in order, lowest-numbered incomplete plan first. Parse frontmatter for `status` (skip `done`), task checkboxes for progress, `[parallel]` for concurrency, and `(depends on N, M)` for ordering.

See `/lo:plan`'s `references/plan-format-contract.md` for the full format specification.

## Error Handling

- Task fails → stop and report. Do not continue to dependent tasks.
- Subagent fails → report which agent and what went wrong.
- Merge conflicts → stop and ask the user.
- Tests fail during execution → stop and fix before continuing.
- Worktree cleanup fails → warn user, suggest manual cleanup.

## Examples

### Executing a feature plan

    User: /lo:work f003

    Agent finds .lo/work/f003-user-auth/, reads 001-auth-flow.md

    Working on: f003 user-auth
    Plan: 001-auth-flow.md

    Tasks:
      1. Set up auth middleware — sequential
      2. Create login endpoint [parallel]
      3. Create signup endpoint [parallel]
      4. Add session management (depends on 2, 3)

    Strategy: Subagents (tasks 2 and 3 are independent)

    User confirms → agent sets up feat/f003-user-auth branch
    Dispatches subagents for tasks 2 and 3
    Merges results, executes task 4

    Phase complete: 001-auth-flow
      4 tasks completed
      Branch: feat/f003-user-auth

### Picking up a task

    User: /lo:work t005

    Working on: t005 "Update dependency versions"
    You're on main.

    1. New branch: fix/t005-update-deps (recommended)
    2. Stay on main

    User picks option 2 → executes directly → reports completion
