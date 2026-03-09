---
name: plan
description: Designs and plans features or tasks before execution. Brainstorms requirements, creates structured implementation plans, and saves them to .lo/work/. Not for execution — use /lo:work to build. Use when user says "plan this", "start feature", "brainstorm", "design this", "let's plan", "/plan", or "/lo:plan".
---

# LO Plan

Turns backlog items into actionable implementation plans. Brainstorms design, writes structured plans, and saves them to `.lo/work/` for execution by `/lo:work`.

## When to Use

- User invokes `/lo:plan`
- User says "plan this", "start feature", "brainstorm", "design this"
- User wants to graduate a feature from backlog to active work with a plan

## Critical Rules

- The `.lo/` directory must exist — if it doesn't, tell the user to run `/lo:new` first.
- Brainstorm before planning features. Jumping straight to a plan skips design exploration, which leads to rework.
- This skill designs — it does not execute. Redirect to `/lo:work` when the user wants to start building.
- Plans always go in `.lo/work/f{NNN}-slug/` or `.lo/work/t{NNN}-slug/` — never `docs/plans/` or anywhere else. Use the format in `references/plan-format-contract.md`.
- Update the feature status to `active` in BACKLOG.md when creating a work directory. Features stay in the backlog through their full lifecycle (`backlog` → `active` → `done`).

## Modes

Detect from arguments:
- `/lo:plan f003` or `/lo:plan "auth system"` → plan a feature
- `/lo:plan t005` or `/lo:plan "fix button"` → plan a task
- `/lo:plan` with no args → show plannable items from backlog

## Feature Planning Flow

### Step 1: Identify the Feature

Arguments: `f{NNN}` or feature name (fuzzy match against BACKLOG.md)

1. Read `.lo/BACKLOG.md`
2. Find the matching feature by ID or name
3. If not found, show backlog features and ask user to choose
4. If feature status is already `active`, check if plans exist in `.lo/work/f{NNN}-slug/`:
   - Plans exist → ask if user wants to re-plan or proceed to `/lo:work`
   - No plans → continue to brainstorming

### Step 2: Create Work Directory

1. Derive directory name: `f{NNN}-slug` (kebab-case from feature name, prefixed with ID)
2. Create `.lo/work/f{NNN}-slug/` directory
3. Update feature status in BACKLOG.md: `Status: active -> .lo/work/f{NNN}-slug/`
4. Update `updated:` date in BACKLOG.md
5. Confirm:

        Feature activated: f{NNN} "<name>"
        Work directory: .lo/work/f{NNN}-slug/
        Backlog status: active

### Step 3: Check Solutions for Prior Art

Scan `.lo/solutions/` for relevant institutional knowledge before brainstorming.

1. List filenames in `.lo/solutions/` (cheap — just an `ls`)
2. Check if any slugs are relevant to the feature being planned (fuzzy match on topic)
3. If matches found, read only those files and surface a brief summary:

        Prior art found:
          2025-11-14-supabase-rls.md — Row-level security pattern for multi-tenant queries
          2025-12-03-streaming-sse.md — SSE setup with edge functions

        These will be fed into the brainstorming context.

4. If no matches → skip silently, no output needed

Surface the solution summaries in the conversation before invoking the brainstorming skill. The skill reads conversation context, so it will naturally pick up the summaries. Present them as prior art the user should consider during design.

### Step 4: Brainstorm

Invoke `superpowers:brainstorming` to explore the design with the user.

This is mandatory for features. The brainstorming skill will:
- Explore project context
- Ask clarifying questions (one at a time)
- Propose 2-3 approaches with trade-offs
- Present design for user approval

**Do not proceed to Step 5 until brainstorming is complete and the user has approved the design.**

### Step 5: Write EARS Requirements (Optional)

After brainstorming, evaluate whether the feature needs formal requirements before planning. Offer EARS if the feature involves:

- **Multiple subsystems** (e.g., GH Action + service + schema)
- **External interfaces or APIs**
- **State machines or lifecycle flows**
- **Multiple actors** (users, agents, services)

If any apply, ask:

    This feature has [multiple subsystems / external interfaces / state transitions].
    Write EARS requirements before planning? (Recommended for complex features, skip for simple ones)

    1. Write EARS requirements (recommended)
    2. Skip — go straight to planning

**Do not proceed until the user answers.**

If the user chooses EARS:

1. Read `references/ears-guide.md` for the full EARS pattern reference, template, and naming conventions
2. Explore the codebase to understand each subsystem's boundaries and interfaces
3. Write requirements to `.lo/work/f{NNN}-slug/ears-requirements.md` using the EARS template
4. Present the requirements to the user for review and approval
5. Once approved, update the EARS frontmatter `status:` from `draft` to `approved` and proceed to Step 6 — the implementation plan should reference EARS requirement IDs (e.g., `REQ-A01`) in task descriptions

If the user skips, proceed directly to Step 6.

### Step 6: Choose Planning Approach

After brainstorming, ask the user:

    Design approved. How do you want to plan the implementation?

    1. Plan mode (recommended for complex/unfamiliar features)
       Interactive — explores codebase, designs step-by-step approach, you approve before saving.

    2. Quick plan (good when you already know the shape)
       Generates plan directly from the brainstorming output. Faster, less codebase exploration.

**Do not proceed until the user answers.**

**Plan mode path:**
1. Use `EnterPlanMode` to enter plan mode
2. Explore the codebase — identify files to touch, patterns to follow, dependencies
3. Write the plan to `.lo/work/f{NNN}-slug/001-<phase-slug>.md` using the plan file format
4. Present via `ExitPlanMode` for user approval
5. If multi-phase, create additional plan files (`002-*.md`, `003-*.md`)

**Quick plan path:**
1. Invoke `superpowers:writing-plans` to generate a structured implementation plan
2. The writing-plans skill produces detailed, bite-sized tasks with file paths and code
3. Save output to `.lo/work/f{NNN}-slug/001-<phase-slug>.md` using the plan file format

### Step 7: Save Plan

Save the plan to `.lo/work/f{NNN}-slug/001-<phase-slug>.md` using the plan file format. For multi-phase features, create separate numbered files (`002-*.md`, `003-*.md`).

See `references/plan-format-contract.md` for the full format specification — required frontmatter fields, task syntax (`[parallel]`, `(depends on N, M)`), and status transitions.

### Step 8: Bridge to Execution

    Plan saved: .lo/work/f{NNN}-slug/001-<phase-slug>.md

    Ready to start building? Type /lo:work to begin.

## Task Planning Flow

Tasks are smaller — they don't always need brainstorming or formal plans.

### `/lo:plan t{NNN}`

1. Read BACKLOG.md, find the task
2. Ask the user:

        Planning: t{NNN} "<description>"

        1. Quick plan — jot down a few steps, save to .lo/work/t{NNN}-slug/
        2. Jump to /lo:work — skip planning, just start executing

3. **Quick plan chosen:**
   - Create `.lo/work/t{NNN}-slug/` directory
   - Ask the user to describe the approach or generate steps from the task description
   - Save a lightweight plan file to `.lo/work/t{NNN}-slug/001-task.md`
   - Bridge to `/lo:work`

4. **Jump to /lo:work chosen:**
   - Tell user to run `/lo:work t{NNN}` — work skill handles tasks without plans directly

## No-Args Mode

When invoked as `/lo:plan` with no arguments:

1. Read BACKLOG.md
2. Show items that could be planned:

        What would you like to plan?

        Features (backlog):
          f001 Auth system
          f003 Dashboard redesign

        Tasks (open):
          t002 Fix button color
          t005 Update dependencies

        Enter an ID:

3. Route to feature or task planning flow based on selection.

## Examples

### Planning a feature (full flow)

    User: /lo:plan f003

    Agent reads BACKLOG.md → finds f003 "User Authentication" (status: backlog)
    Creates .lo/work/f003-user-auth/
    Updates backlog: f003 status → active -> .lo/work/f003-user-auth/
    Checks .lo/solutions/ for relevant prior art
    Invokes brainstorming → explores design → user approves

    This feature has multiple subsystems (auth middleware, login endpoint, signup endpoint, session management).
    Write EARS requirements before planning? (Recommended for complex features, skip for simple ones)

    User picks EARS → writes ears-requirements.md with REQ-A01..REQ-A04
    Asks: Plan mode or quick plan?
    User picks quick plan → saves 001-auth-flow.md (tasks reference REQ-A01, REQ-A02, etc.)

    Plan saved: .lo/work/f003-user-auth/001-auth-flow.md
    EARS: .lo/work/f003-user-auth/ears-requirements.md
    Ready to start building? Type /lo:work to begin.

### Planning a task (quick)

    User: /lo:plan t005

    Planning: t005 "Update dependency versions"

    1. Quick plan — jot down steps, save to .lo/work/t005-update-deps/
    2. Jump to /lo:work — skip planning, just start executing

    User picks option 2 → "Run /lo:work t005 to start."
