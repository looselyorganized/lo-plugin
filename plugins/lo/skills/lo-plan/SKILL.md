---
name: lo-plan
description: Turns ideas into structured implementation plans. Context-aware — adapts depth based on conversation history, project status, and feature complexity. Creates backlog entries on the fly if needed. Delegates design thinking to superpowers:brainstorming and superpowers:writing-plans. Use when user says "plan this", "let's design this", "let's plan", or "/lo:plan". Not for execution — use /lo:work to build.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
  - Skill
metadata:
  author: looselyorganized
  version: 0.6.0
---

# LO Plan

Turns ideas into structured implementation plans. Adapts depth based on
three signals: conversation context, project status, and feature complexity.

This skill is an integration layer. It delegates design thinking to
superpowers:brainstorming and plan writing to superpowers:writing-plans.
Its job is to set up project context and persist the output.

## Critical Rules

- This skill designs — it does NOT execute. Never write implementation code. Redirect to /lo:work when the user wants to start building.
- The `.lo/` directory must exist. If missing, tell user to run `/lo:setup` first.
- Re-read BACKLOG.md from disk on every invocation.
- Read `last_feature` and `last_task` from BACKLOG.md frontmatter for ID allocation.
- After creating a new entry, increment the relevant counter in frontmatter.
- Consult `references/plan-format.md` for plan file format, `references/ears-guide.md` for EARS pattern, `references/depth-scaling.md` for depth assessment.

<depth-scaling>
## Depth-Scaling Decision Tree

Read three signals before deciding depth:

**Signal 1: CONVERSATION CONTEXT**
Has the user been discussing this topic in the current conversation?
Look for: design decisions made, approaches discussed, requirements explored.
Rich context = skip brainstorming, go straight to structuring.

**Signal 2: PROJECT STATUS** (from .lo/project.yml)
- explore — lightweight (skip EARS, quick plan, no review gates)
- build — moderate (offer EARS if complex, plan mode available)
- open — full ceremony (recommend EARS for multi-subsystem, plan mode default)

**Signal 3: FEATURE COMPLEXITY**
- Single subsystem, known pattern — lightweight
- Multiple subsystems, external APIs, state machines — full ceremony
- Assess by: reading the description, checking what files/systems are involved

**Depth matrix:**

| Context | Status | Complexity | Depth |
|---------|--------|-----------|-------|
| Rich | any | any | Structure what was discussed. Skip brainstorming. |
| None | explore | low | Quick plan. No brainstorming needed. |
| None | explore | high | Brainstorm first, then quick plan. |
| None | build | low | Quick plan. Offer brainstorming. |
| None | build | high | Brainstorm, offer EARS, plan mode. |
| None | open | any | Brainstorm, recommend EARS, plan mode. |

Reference `references/depth-scaling.md` for the full guide.
</depth-scaling>

<plan-flow>
## Plan Flow

### Step 1: Identify or create the item.

If argument is an ID (f{NNN} or t{NNN}):
  - Look up in BACKLOG.md
  - Check for parked capture in .lo/park/ — if found, load as context
  - Check for existing work directory in .lo/work/
    - Plans exist — ask: re-plan from scratch, or proceed to /lo:work?
    - No plans — continue

If argument is a description string:
  - Search BACKLOG.md for fuzzy match
  - Found — use existing entry
  - Not found — create new entry:
    1. Read next ID from `last_feature` or `last_task` frontmatter counter
    2. Add entry to BACKLOG.md under the appropriate section
    3. Increment counter and update `updated:` date

If no argument:
  - Show plannable items (open features and tasks in backlog, parked items)
  - Ask user to pick one, or describe something new

### Step 2: Set up project context.

1. Read .lo/project.yml — extract status
2. Read .lo/solutions/ — check for relevant prior art
3. Read .lo/park/<id>-*.md — load parked conversation capture if exists
4. Assess depth using the depth-scaling decision tree above

Report context to the user:

```
Planning: <id> "<name>"
Status: <project-status>
Prior art: [solutions found | none]
Parked context: [loaded | none]
Depth: [lightweight | moderate | full]
```

### Step 3: Create work directory.

```bash
mkdir -p .lo/work/<id>-slug
```

Update BACKLOG.md: change the item's status line to `[active](.lo/work/<id>-slug/)`.
If parked capture exists, note it as context (don't move it yet — Step 5 handles that).

### Step 4: Design.

Based on depth assessment:

**LIGHTWEIGHT** (rich context, or explore/low complexity):
  - Invoke superpowers:writing-plans directly
  - Feed it: conversation context, parked capture, solutions, feature description
  - Save output to `.lo/work/<id>-slug/001-<phase>.md`

**MODERATE** (build status, moderate complexity):
  - Ask: "Structure what we have, or explore further first?"
  - If structure — invoke superpowers:writing-plans
  - If explore — invoke superpowers:brainstorming, then superpowers:writing-plans
  - Save output to `.lo/work/<id>-slug/001-<phase>.md`

**FULL** (open status or high complexity, no context):
  - Invoke superpowers:brainstorming (mandatory)
  - After brainstorming completes, offer EARS:

    ```
    This feature involves [multiple subsystems | external APIs | state transitions].
    Write EARS requirements?
    1. Yes (recommended)
    2. Skip
    ```

  - If EARS chosen: write to `.lo/work/<id>-slug/ears-requirements.md`
    Reference `references/ears-guide.md` for format.
  - Invoke superpowers:writing-plans
  - Save plan to `.lo/work/<id>-slug/001-<phase>.md`
    Reference `references/plan-format.md` for format.

### Step 5: Bridge to execution.

```
Plan saved: .lo/work/<id>-slug/001-<phase>.md
[EARS: .lo/work/<id>-slug/ears-requirements.md]

Ready to start building? Type /lo:work to begin.
```

If parked capture was loaded, move it into the work directory:

```bash
mv .lo/park/<id>-slug.md .lo/work/<id>-slug/parked-context.md
```
</plan-flow>

<task-planning>
## Task Planning (t{NNN} items)

Tasks are lighter. No brainstorming, no EARS.

1. Find or create the task entry in BACKLOG.md
2. Present the choice:

```
Planning: t{NNN} "<description>"

1. Quick plan — jot down steps, save to .lo/work/
2. Jump to /lo:work — skip planning, start building
```

If quick plan:
  - Create `.lo/work/t{NNN}-slug/`
  - Update BACKLOG.md status to `[active](.lo/work/t{NNN}-slug/)`
  - Generate lightweight plan (invoke superpowers:writing-plans or write inline)
  - Save to `001-task.md`
  - Bridge to /lo:work

If jump:
  - Tell user: "Run `/lo:work t{NNN}` to start."
</task-planning>

## Error Handling

- `.lo/` directory doesn't exist — "Run `/lo:setup` first."
- Feature already active with plans — offer re-plan or redirect to /lo:work
- superpowers:brainstorming skill unavailable — fall back to inline brainstorming (explore the problem space conversationally, then hand off to writing-plans)
- superpowers:writing-plans skill unavailable — fall back to inline plan writing (generate plan directly following `references/plan-format.md`)

<example name="feature-with-rich-context">
User has been discussing image generation architecture for 15 minutes.

User: /lo:plan f009

Planning: f009 "Image Generation for MDX Pipeline"
Status: build
Prior art: none
Parked context: loaded (.lo/park/f009-image-gen.md)
Depth: lightweight (rich conversation context)

[Invokes superpowers:writing-plans with conversation context + parked capture]

Plan saved: .lo/work/f009-image-gen/001-image-service.md

Ready to start building? Type /lo:work to begin.
</example>

<example name="feature-cold-start">
No prior discussion. Open-status project.

User: /lo:plan "real-time collaborative editing"

No match in backlog. Creating: f010 "Real-time Collaborative Editing"

Planning: f010 "Real-time Collaborative Editing"
Status: open
Prior art: s003-supabase-realtime.md
Parked context: none
Depth: full (open status, no prior context)

[Invokes superpowers:brainstorming — explores approaches, tradeoffs, architecture]

This feature involves multiple subsystems and external APIs.
Write EARS requirements?
1. Yes (recommended)
2. Skip

User: 1

[Writes ears-requirements.md, then invokes superpowers:writing-plans]

Plan saved: .lo/work/f010-realtime-collab/001-sync-engine.md
EARS: .lo/work/f010-realtime-collab/ears-requirements.md

Ready to start building? Type /lo:work to begin.
</example>

<example name="task-quick-plan">
User: /lo:plan t015

Planning: t015 "Fix button color on dark mode"

1. Quick plan — jot down steps, save to .lo/work/
2. Jump to /lo:work — skip planning, start building

User: 1

Plan saved: .lo/work/t015-fix-button-dark/001-task.md

Ready to start building? Type /lo:work to begin.
</example>
