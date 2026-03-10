---
name: plan
description: Designs and plans features or tasks before execution. Brainstorms requirements, creates structured implementation plans, and saves them to .lo/work/. Not for execution — use /lo:work to build. Use when user says "plan this", "start feature", "brainstorm", "design this", "let's plan", "/plan", or "/lo:plan".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
  - Skill
---

# LO Plan

Turns backlog items into actionable implementation plans. Brainstorms design, writes structured plans, and saves them to `.lo/work/` for execution by `/lo:work`.

<critical>
This skill designs — it does NOT execute. Never write implementation code. Redirect to /lo:work when the user wants to start building.
</critical>

## When to Use

- User invokes `/lo:plan`
- User says "plan this", "start feature", "brainstorm", "design this"
- User wants to graduate a feature from backlog to active work

## Modes

Detect from arguments:
- `/lo:plan f003` or `/lo:plan "auth system"` → **feature planning**
- `/lo:plan t005` or `/lo:plan "fix button"` → **task planning**
- `/lo:plan` with no args → **show plannable items**

**If the argument matches a feature → follow Feature Planning below.**
**If the argument matches a task → follow Task Planning below.**
**If no args → show plannable items from backlog, then route based on selection.**

---

<feature-planning>
## Feature Planning

You are planning a **feature**. Features get brainstorming, optional EARS requirements, and structured plans.

### Progress Checklist

```
Plan Progress:
  Feature: [pending]
  - [ ] Step 1: Identify feature
  - [ ] Step 2: Create work directory
  - [ ] Step 3: Check solutions for prior art
  - [ ] Step 4: Brainstorm
  - [ ] Step 5: EARS requirements (optional)
  - [ ] Step 6: Choose planning approach
  - [ ] Step 7: Save plan
  - [ ] Step 8: Bridge to execution
```

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

```bash
mkdir -p .lo/work/f{NNN}-slug
```

2. Update feature status in BACKLOG.md: add `[active](.lo/work/f{NNN}-slug/)` line under the feature
3. Update `updated:` date in BACKLOG.md
4. Confirm:

```
Feature activated: f{NNN} "<name>"
Work directory: .lo/work/f{NNN}-slug/
Backlog status: active
```

### Step 3: Check Solutions for Prior Art

Scan `.lo/solutions/` for relevant institutional knowledge before brainstorming.

1. List filenames in `.lo/solutions/`
2. Check if any slugs are relevant (fuzzy match on topic)
3. If matches found, surface a brief summary:

```
Prior art found:
  s003-supabase-rls.md — Row-level security pattern for multi-tenant queries
  s007-streaming-sse.md — SSE setup with edge functions

These will be fed into the brainstorming context.
```

4. If no matches → skip silently

### Step 4: Brainstorm

Invoke `superpowers:brainstorming` to explore the design with the user.

This is mandatory for features. The brainstorming skill will:
- Explore project context
- Ask clarifying questions (one at a time)
- Propose 2-3 approaches with trade-offs
- Present design for user approval

**Do not proceed to Step 5 until brainstorming is complete and the user has approved the design.**

### Step 5: Write EARS Requirements (Optional)

Evaluate whether the feature needs formal requirements. Offer EARS if it involves:
- Multiple subsystems
- External interfaces or APIs
- State machines or lifecycle flows
- Multiple actors (users, agents, services)

If any apply, ask:

```
This feature has [multiple subsystems / external interfaces / state transitions].
Write EARS requirements before planning?

1. Write EARS requirements (recommended)
2. Skip — go straight to planning
```

**Do not proceed until the user answers.**

<ears-yes>
If the user chooses EARS:

1. Read `references/ears-guide.md` for the full pattern reference
2. Explore the codebase to understand subsystem boundaries
3. Write requirements to `.lo/work/f{NNN}-slug/ears-requirements.md`
4. Present for user review and approval
5. Once approved, update EARS frontmatter `status:` from `draft` to `approved`
6. Proceed to Step 6 — plan tasks should reference EARS IDs (e.g., `REQ-A01`)
</ears-yes>

<ears-no>
If the user skips, proceed directly to Step 6.
</ears-no>

### Step 6: Choose Planning Approach

```
Design approved. How do you want to plan the implementation?

1. Plan mode (recommended for complex/unfamiliar features)
   Interactive — explores codebase, designs step-by-step, you approve before saving.

2. Quick plan (good when you already know the shape)
   Generates plan directly from brainstorming output. Faster, less exploration.
```

**Do not proceed until the user answers.**

<plan-mode>
**Plan mode:**

1. Use `EnterPlanMode` to enter plan mode
2. Explore the codebase using the `scout` subagent — identify files, patterns, dependencies
3. Write the plan to `.lo/work/f{NNN}-slug/001-<phase-slug>.md` using the plan file format
4. Present via `ExitPlanMode` for user approval
5. If multi-phase, create additional plan files (`002-*.md`, `003-*.md`)
</plan-mode>

<quick-plan>
**Quick plan:**

1. Invoke `superpowers:writing-plans` to generate a structured implementation plan
2. The writing-plans skill produces detailed, bite-sized tasks with file paths and code
3. Save output to `.lo/work/f{NNN}-slug/001-<phase-slug>.md` using the plan file format
</quick-plan>

### Step 7: Save Plan

Save to `.lo/work/f{NNN}-slug/001-<phase-slug>.md`. For multi-phase features, create separate numbered files.

See `references/plan-format-contract.md` for required frontmatter, task syntax (`[parallel]`, `(depends on N, M)`), and status transitions.

### Step 8: Bridge to Execution

```
Plan saved: .lo/work/f{NNN}-slug/001-<phase-slug>.md

Ready to start building? Type /lo:work to begin.
```

</feature-planning>

---

<task-planning>
## Task Planning

You are planning a **task**. Tasks are smaller — they don't always need brainstorming or formal plans.

1. Read BACKLOG.md, find the task
2. Ask the user:

```
Planning: t{NNN} "<description>"

1. Quick plan — jot down a few steps, save to .lo/work/t{NNN}-slug/
2. Jump to /lo:work — skip planning, just start executing
```

<task-quick-plan>
**Quick plan chosen:**

1. Create work directory:

```bash
mkdir -p .lo/work/t{NNN}-slug
```

2. Ask the user to describe the approach or generate steps from the task description
3. Save a lightweight plan file to `.lo/work/t{NNN}-slug/001-task.md`
4. Update BACKLOG.md: add `[active](.lo/work/t{NNN}-slug/)` status line
5. Bridge to `/lo:work`
</task-quick-plan>

<task-jump>
**Jump to /lo:work chosen:**

Tell user to run `/lo:work t{NNN}` — work skill handles tasks without plans directly.
</task-jump>

</task-planning>

---

## No-Args Mode

When invoked as `/lo:plan` with no arguments:

1. Read BACKLOG.md
2. Show items that could be planned:

```
What would you like to plan?

Features (backlog):
  f001 Auth system
  f003 Dashboard redesign

Tasks (open):
  t002 Fix button color
  t005 Update dependencies

Enter an ID:
```

3. Route to Feature Planning or Task Planning based on selection.

## Examples

<example name="feature-full-flow">
User: /lo:plan f003

Step 1: Found f003 "User Authentication" (status: backlog)
Step 2: Created .lo/work/f003-user-auth/, backlog updated
Step 3: Found s003-supabase-rls.md as prior art
Step 4: Brainstorming → user approves session-based auth design
Step 5: Feature has multiple subsystems → user chooses EARS → wrote ears-requirements.md
Step 6: User picks quick plan
Step 7: Saved 001-auth-flow.md (tasks reference REQ-A01..REQ-A04)

Plan saved: .lo/work/f003-user-auth/001-auth-flow.md
EARS: .lo/work/f003-user-auth/ears-requirements.md
Ready to start building? Type /lo:work to begin.
</example>

<example name="task-quick">
User: /lo:plan t005

Planning: t005 "Update dependency versions"

1. Quick plan
2. Jump to /lo:work

User picks 2 → "Run /lo:work t005 to start."
</example>
