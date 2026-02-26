---
name: work
description: Executes plans from .lo/work/ directories. Creates branches or worktrees for isolation, identifies parallelizable tasks, and dispatches work using direct execution, subagents, or Agent Teams (preview feature). Stops when plan is complete — does not ship. Use when user says "start working", "let's build", "execute the plan", "work on", or "/work".
metadata:
  version: 0.2.0
  author: LORF
---

# LO Work Executor

Executes plans from `.lo/work/` feature directories. Handles branching, parallelization, and progress tracking. Stops when the plan is complete — shipping is a separate step (`/lo:ship`).

## When to Use

- User invokes `/lo:work`
- User says "start working", "let's build", "execute the plan"
- A feature has been picked from the backlog and plans exist in `.lo/work/`

## Critical Rules

- `.lo/work/` MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- NEVER ship code. This skill executes plans. `/lo:ship` handles the quality pipeline.
- ALWAYS ask the user about branch isolation before executing. Do not skip this step.
- Be transparent about what's running in parallel and why.
- Stop and report when a plan phase is complete. Ask before proceeding to the next phase.
- If no plans exist in the work directory, bridge to brainstorming and plan-writing first.
- Work directories are named `f{NNN}-slug/` matching the feature ID from the backlog.

## Workflow

### Step 1: Find Active Work

Scan `.lo/work/` for feature directories (named `f{NNN}-slug/`) containing plan files (numbered: `001-*.md`, `002-*.md`).

**If no work directories exist:**
Tell user to use `/lo:backlog start "feature"` to graduate a feature.

**If directories exist but no plan files:**
Tell user the feature directory exists but needs plans. Bridge to brainstorming → writing-plans.

**If multiple features have plans:** List them with IDs and ask which to work on:

    Active features with plans:
      f003 auth-system — 2 phases
      f005 dashboard-redesign — 1 phase

    Which feature?

### Step 2: Read the Plan

Read the current plan file (lowest-numbered incomplete plan):

1. Parse the plan's tasks, dependencies, and parallelization markers
2. Present a summary:

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

**Before executing anything, recommend an isolation strategy and ask the user.**

Pick the best default based on scope:
- Multiple phases or large feature → recommend worktree
- Single phase or small scope → recommend branch
- Already on a feature branch → recommend staying

Present it as:

    You're on <current-branch>.

    1. <recommended option> (recommended)
    2. Stay on <current-branch>
    3. Something else

Examples:
- `1. New branch: feature/f003-auth-system (recommended)`
- `1. New worktree: ../<repo-name>-f003-auth-system (recommended)`

**Do not proceed to Step 4 until the user answers.**

If they pick option 3, ask what they'd prefer (different branch name, worktree, etc.).

If they choose to stay on the current branch, proceed — but note this in the plan summary so `/lo:ship` knows there's no feature branch to PR from.

### Step 4: Execute

Choose parallelization level based on the plan's task structure:

**Level 1 — Sequential:** Simple tasks or tasks with dependencies between all steps. Execute one at a time, report progress after each.

**Level 2 — Subagents:** Independent tasks within a phase. Dispatch to subagents, wait for all to complete before moving to dependent tasks.

**Level 3 — Agent Teams:** Large features with substantial independent workstreams. Use Agent Teams (preview feature enabled) to coordinate parallel work.

**Transparency requirement:** Always tell the user:
- How many parallel tracks are running
- What each track is doing
- When tracks complete
- If any track fails

### Step 5: Track Progress

As tasks complete:
1. Mark done in the plan file if it uses checkboxes
2. Report progress
3. When all tasks in a phase complete:

        Phase complete: 001-<phase-name>
          [N] tasks completed
          Feature: f003 auth-system
          Branch: feature/f003-auth-system

        Next phase: 002-<phase-name> (if exists)
        Continue? Or ship with /lo:ship?

### Step 6: Phase Boundary

When a plan phase completes:
- If another phase exists → ask whether to continue
- If no more phases → report completion, suggest `/lo:ship`

Do NOT automatically proceed to shipping.

## Plan File Format

Plans in `.lo/work/f{NNN}-slug/` follow the executing-plans skill format:

    ---
    status: pending
    feature_id: "f{NNN}"
    feature: <feature-name>
    phase: 1
    ---

    ## Objective
    What this phase accomplishes.

    ## Tasks
    - [ ] Task 1 description
    - [ ] Task 2 description [parallel]
    - [ ] Task 3 description [parallel]
    - [ ] Task 4 description (depends on 2, 3)

The `[parallel]` marker indicates tasks that can run simultaneously.

## Error Handling

- Task fails → stop and report. Do not continue to dependent tasks.
- Subagent fails → report which agent and what went wrong.
- Merge conflicts → stop and ask the user.
- Tests fail during execution → stop and fix before continuing.
