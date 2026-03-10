---
name: work
description: Executes features (from plans) and tasks (directly) in .lo/work/. Handles branch isolation, worktree-based parallelization, and progress tracking. Not for planning — use /lo:plan to design first. Stops when complete — does not ship. Use when user says "start working", "let's build", "execute the plan", "work on", or "/work".
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
---

# LO Work Executor

Executes features (from plans) and tasks (directly from backlog). Handles isolation, parallelization, and progress tracking. Stops when complete — shipping is `/lo:ship`.

<critical>
This skill executes — it does NOT ship. Never push, create PRs, or mark items done in the backlog.
Task execution NEVER uses subagents or agent teams unless the task has a plan with explicit parallel markers.
</critical>

## When to Use

- User invokes `/lo:work`
- User says "start working", "let's build", "execute the plan", "work on"
- A feature has plans in `.lo/work/` ready for execution
- A task from the backlog is ready to be picked up

## Modes

Detect from arguments:
- `/lo:work` with no args → find active work
- `/lo:work f003` → execute feature f003's plan
- `/lo:work t005` → pick up task t005

**If the argument starts with `f` → follow Feature Execution below.**
**If the argument starts with `t` → follow Task Execution below.**
**If no args → scan `.lo/work/` for feature directories with plans. If none found, show open tasks.**

## Progress Checklist

Copy and update as you proceed:

```
Work Progress:
  Type: [feature | task]
  Item: [pending detection]
  Strategy: [pending detection]
  - [ ] Step 1: Find work
  - [ ] Step 2: Read plan + EARS
  - [ ] Step 3: Set up isolation
  - [ ] Step 4: Check test expectations
  - [ ] Step 5: Execute
  - [ ] Step 6: Track progress
  - [ ] Step 7: Phase boundary
```

---

<feature-execution>
## Feature Execution

You are executing a **feature**. Features have plans in `.lo/work/f{NNN}-slug/`.

### Step 1: Find the Feature

**With argument (`f{NNN}`):** Look up `.lo/work/f{NNN}-slug/` directly.

**No argument:** Scan `.lo/work/` for feature directories containing plan files (numbered: `001-*.md`, `002-*.md`).

- No work directories → tell user to run `/lo:backlog feature "name"` then `/lo:plan f{NNN}`
- Directories exist but no plan files → redirect to `/lo:plan f{NNN}`
- Multiple features have plans → list them and ask:

```
Active features with plans:
  f003 auth-system — 2 phases
  f005 dashboard-redesign — 1 phase

Which feature?
```

### Step 2: Read the Plan and EARS Contract

Read the current plan file (lowest-numbered incomplete plan). Use the `scout` subagent for codebase exploration if needed.

1. Parse the plan's tasks, dependencies, and parallelization markers
2. **Check for EARS contract:** Look for `ears-requirements.md` in the work directory
   - If it exists, read its `status:` field. Only use as ground truth if `status: approved`
   - If `draft` or `updated`, warn user and ask whether to proceed or skip EARS
   - Parse all `REQ-*` requirement IDs
3. Determine execution strategy based on task structure
4. Present summary:

```
Working on: f003 auth-system
Plan: 001-auth-flow.md
EARS: ears-requirements.md (22 requirements across 4 subsystems)

Tasks:
  1. [description] (REQ-T01, REQ-T02) — sequential
  2. [description] (REQ-A01, REQ-A02) — can parallel with 3
  3. [description] (REQ-S01, REQ-S02) — can parallel with 2
  4. [description] (REQ-X01, REQ-X02) — depends on 2, 3

Strategy: [sequential | subagents | agent teams]
```

If no EARS file exists, omit the EARS line.

**Wait for user confirmation before executing.**

After confirmation, create a task list using `TaskCreate` — one per plan task. Mark `in_progress` when starting, `completed` when done.

**EARS during execution:** When tasks reference `REQ-*` IDs, use the EARS document as the spec. If a requirement is ambiguous or conflicts with the codebase, stop and ask.

### Step 3: Set Up Isolation

The feature branch is the integration point. All work merges into it.

```bash
git branch --show-current
git status
```

Determine the recommendation:

| Current state | Recommendation |
|--------------|----------------|
| Already on `feat/f{NNN}-*` | Stay on current branch |
| On a semver branch (e.g. `0.4.1`) | Branch off it — feature work lands on the release |
| On main, clean tree | New branch from main |
| On main, dirty tree | Stash or commit first, then new branch |

Present options and **do not proceed until the user answers:**

```
You're on <current-branch>.

1. New branch: feat/f{NNN}-slug (recommended)
2. Stay on <current-branch>
3. Something else
```

If new branch from a release branch:

```bash
git checkout -b feat/f{NNN}-slug
```

If new branch from main:

```bash
git checkout -b feat/f{NNN}-slug
```

If staying: note this so `/lo:ship` knows there's no feature branch.

### Step 4: Check Test Expectations

Read `.lo/PROJECT.md` status field and follow ONLY the matching block:

<test-explore>
**Explore** — Do not mention tests. Speed is the priority.
</test-explore>

<test-build>
**Build** — When writing implementation code with testable logic, write tests alongside it. If `.github/workflows/ci.yml` exists, ensure new test files are covered. If the workflow doesn't exist yet, suggest `/lo:status Build` to generate it.

Scan plan tasks for test-related work. If the plan has testable logic but no test tasks, flag it:

```
This plan has no test tasks but the project is in Build status.
Add tests to the plan, or proceed without?
```

Do not block — let the user decide.
</test-build>

<test-open>
**Open** — Tests are expected for all testable code. Flag any testable logic without tests.

Scan plan tasks for test-related work. If the plan has testable logic but no test tasks, flag it:

```
This plan has no test tasks but the project is in Open status.
Add tests to the plan, or proceed without?
```

Do not block — let the user decide.
</test-open>

**What counts as testable logic:** Functions with business logic, parsers, validators, data transformations, state machines, API handlers. **Not testable:** Config, types, UI layout, markdown, thin wrappers.

### Step 5: Execute

Choose the execution level based on the plan's task structure. Follow ONLY the matching level section.

<sequential>
#### Sequential (Level 1)

All tasks depend on each other, or tasks touch overlapping files. Work directly on the feature branch.

```
feat/f003-auth (feature branch)
  → task 1 → commit → task 2 → commit → task 3 → commit
```

Execute tasks in order. Commit after each task completes:

```bash
git add <changed-files>
git commit -m "<type>: <description>"
```
</sequential>

<subagents>
#### Subagents (Level 2)

2-4 independent tasks that touch separate files. Each subagent gets an isolated worktree.

```
feat/f003-auth (feature branch) ← you coordinate here
  ├── subagent A (worktree) → task 2 → returns branch
  ├── subagent B (worktree) → task 3 → returns branch
  └── you merge A, then B into feat/f003-auth
      then execute task 4 (depends on 2 + 3)
```

**Dispatch:** Use the Agent tool with `isolation: "worktree"` for each independent task. Each subagent receives: task description, relevant file paths, plan context.

**Merge after all subagents complete:**

```bash
git merge <subagent-branch-A> --no-ff
git merge <subagent-branch-B> --no-ff
```

If merge conflict → stop and ask the user.

Run tests after merge to catch integration issues.

**Transparency:** Always tell the user how many parallel tracks are running, what each is doing, and when they complete.
</subagents>

<agent-teams>
#### Agent Teams (Level 3)

5+ independent tasks or multi-day workstreams. Each team member gets their own worktree.

```
feat/f003-auth (feature branch) ← team lead coordinates
  ├── teammate "api" (worktree) → builds endpoints → returns branch
  ├── teammate "ui" (worktree) → builds components → returns branch
  └── team lead merges both into feat/f003-auth
```

For dispatch protocols, merge procedures, and cleanup details, see `references/execution-patterns.md`.

Merge protocol is the same as subagents — sequential merge with `--no-ff`, conflict handling, post-merge tests.
</agent-teams>

**Level selection:**

| Signal | Level |
|--------|-------|
| All tasks depend on each other | Sequential |
| 2-4 independent tasks in a phase | Subagents |
| 5+ independent tasks or multi-day workstreams | Agent Teams |
| Tasks touch overlapping files | Sequential (safest) |
| Tasks touch completely separate areas | Subagents or Teams |

### Step 6: Track Progress

As tasks complete:
1. Mark done in the plan file: `- [x] Task description`
2. Update TaskCreate tasks: mark `completed`
3. Report progress after each task

When all tasks in a phase complete:

```
Phase complete: 001-<phase-name>
  [N] tasks completed
  Feature: f003 auth-system
  Branch: feat/f003-auth-system

Next phase: 002-<phase-name> (if exists)
Continue? Or ship with /lo:ship?
```

### Step 7: Phase Boundary

- Another phase exists → ask whether to continue
- No more phases → report completion, suggest `/lo:ship`

**EARS checkpoint (final phase only):** If `ears-requirements.md` exists and all phases are complete, list any `REQ-*` IDs that weren't referenced by any plan task. This is informational, not blocking.

Do NOT automatically proceed to shipping.

</feature-execution>

---

<task-execution>
## Task Execution

You are executing a **task**. Tasks are smaller — they don't need formal plans unless one exists.

### Step 1: Find the Task

1. Read `.lo/BACKLOG.md`
2. Find the matching task by ID `t{NNN}` or fuzzy match on description
3. If not found, show open tasks and ask user to choose

### Step 2: Check for a Plan

Check if `.lo/work/t{NNN}-slug/` exists with plan files:

- **Plan exists:** Follow the Feature Execution flow (Steps 2-7 above) using the task's plan
- **No plan:** Continue to Step 3 below

### Step 3: Set Up Isolation

```bash
git branch --show-current
git status
```

Present options and **do not proceed until the user answers:**

```
Working on: t{NNN} "<description>"
You're on <current-branch>.

1. New branch: fix/t{NNN}-slug (recommended for non-trivial changes)
2. Stay on <current-branch> (fine for quick fixes)
```

If dirty working tree, add: `3. New worktree (you have uncommitted changes)`

If new branch:

```bash
git checkout -b fix/t{NNN}-slug
```

If worktree: use the EnterWorktree tool.

### Step 4: Execute

Execute the task directly. If scope is unclear, ask the user before proceeding. Tasks are typically sequential — no subagents needed.

### Step 5: Completion

```
Task complete: t{NNN} "<description>"
Branch: fix/t{NNN}-slug

Ready to ship? Run /lo:ship to commit, push, and create a PR.
```

Do NOT automatically proceed to shipping.

</task-execution>

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

<example name="feature-with-subagents">
User: /lo:work f003

Step 1: Found .lo/work/f003-user-auth/ with 001-auth-flow.md
Step 2: Plan has 4 tasks, tasks 2+3 are parallel → Strategy: Subagents
Step 3: On main → created feat/f003-user-auth
Step 4: Project is Build → test tasks checked, plan includes tests ✓
Step 5: Executed task 1 sequentially, dispatched subagents for tasks 2+3, merged, executed task 4
Step 6: All 4 tasks complete

Phase complete: 001-auth-flow
  4 tasks completed
  Branch: feat/f003-user-auth

Ready to ship? Run /lo:ship.
</example>

<example name="task-direct">
User: /lo:work t005

Step 1: Found t005 "Update dependency versions" in BACKLOG.md
Step 2: No plan exists → direct execution
Step 3: On main → user picks "stay on main"
Step 4: Updated package.json, ran tests

Task complete: t005 "Update dependency versions"
Ready to ship? Run /lo:ship.
</example>
