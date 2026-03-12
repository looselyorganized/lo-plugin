---
status: draft
feature_id: "f008"
feature: "Plugin v0.6.0 — Flow-First Redesign"
phase: 1
---

# LO Plugin v0.6.0 — Flow-First Redesign

## Design Philosophy

The plugin is invisible when you're in flow, present when you need structure.

The creative workflow — brainstorming, planning, building — is Claude's native strength, enhanced by superpowers skills. This plugin doesn't duplicate that. It adds three things Claude can't do alone:

1. **Project lifecycle** — status-aware behavior that scales ceremony with maturity
2. **Ops automation** — CI/CD generation, quality gates, mode detection, branch strategy
3. **Persistence** — backlog, stream, solutions, parked ideas that survive across sessions

### Core Principles

- **Fluidity over ceremony.** The plugin meets you where you are. No prerequisite chains.
- **Context-aware depth.** Planning scales from "structure what we discussed" to full EARS + multi-phase plans. The signals: conversation context, project status, feature complexity.
- **Superpowers integration.** Plan and work delegate heavy lifting to superpowers skills. They're integration layers, not workflow engines.
- **Ship is the crown jewel.** Status-aware mode detection, scaled quality gates, changelog generation, backlog pruning. This is where the plugin earns its keep.
- **Done items disappear.** The backlog is a parking lot for future work, not an archive. Shipped items are pruned — changelog and git history serve as the record.

### Informed By

- **GSD** — Complexity hidden in the system. Quick escape hatch for small work. Wave-based parallel execution. Context preservation via state files.
- **BMAD** — Track selection based on complexity. Help/status command that inspects state and recommends next action. Implementation readiness gates.
- **Spec Kit** — Constitution concept (project principles gate everything). Explicit clarification markers. Separation of WHAT from HOW.
- **Anthropic Skills Guide** — Progressive disclosure (frontmatter → body → references). Description = WHAT + WHEN. Keep SKILL.md under 5,000 words. Be specific and actionable. Include error handling and examples.

---

## Artifact Structure

```
.lo/
  project.yml              # id, title, description, status, state — drives everything
  BACKLOG.md               # Parking lot — open items only, done items pruned
  STREAM.md                # Public milestones (XML entry format, newest first)
  park/                    # Rich conversation captures (created by /park)
    f009-image-gen.md
    t015-auth-refactor.md
  work/                    # Active plans and execution artifacts (created by /plan)
    f009-image-gen/
      001-image-service.md
      ears-requirements.md
  solutions/               # Reusable knowledge (created by /solution)
    s001-supabase-rls.md
```

### Changes from v0.5.0

- **Added `.lo/park/`** — new directory for parked conversation captures
- **Removed `.lo/research/`** — research happens in conversation, not files
- **BACKLOG.md gains frontmatter counters** — `last_feature` and `last_task` fields prevent ID collisions when done items are pruned
- **Done items pruned from BACKLOG.md** — ship pipeline removes `[done]` entries; changelog and git serve as archive

### BACKLOG.md Format (v0.6.0)

```markdown
---
updated: 2026-03-12
last_feature: 9
last_task: 15
---

## Features

- [ ] f009 Image Generation for MDX
  AI-powered image generation integrated into the article publishing pipeline.
  [parked](.lo/park/f009-image-gen.md)

- [ ] f010 Real-time Collab Editing
  Collaborative editing for field notes.

## Tasks

- [ ] t015 Fix button color on dark mode
```

Status lines:
- No status line = backlog (waiting)
- `[parked](.lo/park/<id>-slug.md)` = parked with rich context
- `[active](.lo/work/<id>-slug/)` = planned, in progress
- `[done]` entries are **removed** during ship (not marked, removed)

ID allocation reads from `last_feature` / `last_task` frontmatter counters, not by scanning entries. This makes pruning safe.

---

## Skill Catalog

8 skills. 4 unique to LO, 2 integration layers, 2 ops.

| # | Skill | Type | Role |
|---|-------|------|------|
| 1 | `lo-setup` | Unique | Scaffold project identity |
| 2 | `lo-park` | Unique | Capture ideas + rich conversation context |
| 3 | `lo-plan` | Integration | superpowers + .lo/ persistence |
| 4 | `lo-work` | Integration | superpowers + branch/status awareness |
| 5 | `lo-ship` | Ops | Status-aware gates, mode detection, cleanup |
| 6 | `lo-status` | Ops | Lifecycle transitions, CI/CD automation |
| 7 | `lo-stream` | Unique | Public milestone narrative |
| 8 | `lo-solution` | Unique | Reusable knowledge capture |

### Killed from v0.5.0

- `/lo:backlog` — split into `/lo:park` (capture) + `/lo:status` (dashboard view)
- `/lo:release` — absorbed into `/lo:ship` (release mode detection)
- `/lo:new` → renamed `/lo:setup` (avoids collision with `/init`)
- `stocktaper-design-system` — orthogonal to workflow, lives as a standalone skill outside the plugin

---

## Skill Designs

### 1. `/lo:setup`

**Folder:** `lo-setup/`

**Frontmatter:**
```yaml
---
name: lo-setup
description: Scaffolds the .lo/ directory for a new LO project. Creates project.yml, initializes BACKLOG.md, and optionally reconciles GitHub automation. Use when user says "setup lo", "new lo project", "scaffold lo", "add lo to this repo", or "/lo:setup".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---
```

**Behavior:**

Minimal changes from v0.5.0 `/lo:new`. Key differences:
- Creates `.lo/park/` directory alongside `.lo/work/` and `.lo/solutions/`
- Removes `.lo/research/` from scaffold
- BACKLOG.md template includes `last_feature: 0` and `last_task: 0` in frontmatter
- `project.yml` unchanged (id, title, description, status, state)

**Flow:**
1. Check if `.lo/` exists — if yes, warn and confirm overwrite
2. Prompt for: title, description, status (default: explore), state (default: private)
3. Generate `project.yml` with `proj_` prefixed UUID
4. Create directory structure with `.gitkeep` files
5. Optionally scan repo for TODOs → add to BACKLOG.md
6. Optionally run `lo-github-sync.sh` if available
7. Report what was created

**Reference files:**
- `references/project-yml-format.md` (carried from v0.5.0)

---

### 2. `/lo:park`

**Folder:** `lo-park/`

**Frontmatter:**
```yaml
---
name: lo-park
description: Captures ideas and rich conversation context for later. Creates a backlog entry linked to a detailed conversation summary in .lo/park/. Use when user says "park this", "save this for later", "park", "remember this idea", or "/lo:park". Not for planning or execution — use /lo:plan to design, /lo:work to build.
allowed-tools:
  - Read
  - Glob
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---
```

**This is a new skill.** Nothing like it exists in v0.5.0 or in the frameworks we studied.

**Body structure:**

```markdown
# LO Park

Captures ideas and conversation context for later. When you've been discussing
something with Claude and want to save the thinking without committing to
planning or building, park it.

## When to Use

- User invokes `/lo:park`
- User says "park this", "save this for later", "let's come back to this"
- A conversation has produced valuable thinking that isn't ready for /lo:plan

## When NOT to Use — Redirect Instead

- "Let's plan this" → /lo:plan (creates backlog entry + plans in one motion)
- "Let's build this" → /lo:work (creates backlog entry + executes)
- "Ship it" → /lo:ship

## Critical Rules

- The `.lo/` directory must exist. If missing, tell user to run `/lo:setup` first.
- ALWAYS present the capture for user review before writing. Nothing saves without approval.
- Re-read BACKLOG.md from disk on every invocation.
- Read `last_feature` and `last_task` from BACKLOG.md frontmatter for ID allocation.
- After writing, increment the relevant counter in frontmatter.
```

**Modes:**

Detect from arguments:
- `/lo:park` (no args) → **capture from conversation** (most common)
- `/lo:park feature "name"` → **quick park** (just a backlog entry, no rich capture)
- `/lo:park task "name"` → **quick park** (just a backlog entry, no rich capture)

**Mode 1: Capture from Conversation (primary mode)**

This is the distinctive mode. The user has been discussing something and wants to preserve the thinking.

```xml
<capture-flow>
Step 1: Determine what to capture.

Ask the user:

    What should I call this?

    1. [suggest a name based on conversation topic]
    2. Something else

Classify as feature (f{NNN}) or task (t{NNN}) based on scope. If unclear, ask:

    Is this a feature (bigger, needs design) or a task (smaller, just do it)?

Step 2: Generate the conversation capture.

Read the conversation context and produce a rich, near-verbatim summary that
preserves the thinking. This is NOT a structured extraction — it reads like
meeting notes that capture the actual flow of ideas.

Include:
- What was discussed and in what order
- Decisions that were made and WHY
- Approaches that were considered and WHY they were accepted or rejected
- Points of excitement or emphasis from the user
- Open questions that weren't resolved
- Any technical details, code patterns, or architecture discussed

The capture should be long enough that future-you can read it and be
immediately back in the headspace. Err on the side of too much context
rather than too little.

Format:

    # <id> — <name>
    parked: <YYYY-MM-DD>

    <Rich narrative capture of the conversation. Multiple paragraphs.
    Preserves the flow of thinking, not just the conclusions.>

Step 3: Present for review.

Show the complete capture to the user:

    Here's what I captured. Review and approve, or tell me what to change:

    ---
    [full capture content]
    ---

    Save this? (yes / edit / redo)

HARD GATE: Do not write any files until the user approves.

Step 4: Persist.

After approval:

1. Read BACKLOG.md, get next ID from `last_feature` or `last_task` counter
2. Write capture to `.lo/park/<id>-<slug>.md`
3. Add backlog entry with `[parked]` link:

For features:
    - [ ] f{NNN} Feature Name
      Brief description.
      [parked](.lo/park/f{NNN}-slug.md)

For tasks:
    - [ ] t{NNN} Task description
      [parked](.lo/park/t{NNN}-slug.md)

4. Increment `last_feature` or `last_task` in BACKLOG.md frontmatter
5. Update `updated:` date

6. Report:

    Parked: <id> "<name>"
    Capture: .lo/park/<id>-slug.md

    Pick this up later with /lo:plan <id> or /lo:work <id>
</capture-flow>
```

**Mode 2: Quick Park (just a backlog entry)**

Same as v0.5.0 backlog `add feature` / `add task`. No rich capture file.

1. Read BACKLOG.md, get next ID from frontmatter counter
2. If feature: ask for 1-2 sentence description if not provided
3. Add entry to BACKLOG.md (no `[parked]` link — just a plain backlog item)
4. Increment counter, update date
5. Report: `Parked: <id> "<name>"`

**Error handling:**
- `.lo/` doesn't exist → "Run /lo:setup first"
- BACKLOG.md doesn't exist → create from template
- User rejects capture → ask what to change, regenerate, re-present

**Examples:**

```xml
<example name="rich-capture-mid-conversation">
User has been discussing image generation for MDX articles for 20 minutes.

User: /lo:park

What should I call this?

1. "Image Generation for MDX Pipeline" (feature)
2. Something else

User: 1

[Generates rich capture preserving the full conversation thinking]

Here's what I captured. Review and approve:
---
# f009 — Image Generation for MDX Pipeline
parked: 2026-03-12

Started by exploring whether we could auto-generate hero images for field
notes. The initial idea was on-demand generation at request time, but we
quickly moved away from that...
[rich narrative continues]
---

Save this? (yes / edit / redo)

User: yes

Parked: f009 "Image Generation for MDX Pipeline"
Capture: .lo/park/f009-image-gen.md

Pick this up later with /lo:plan f009 or /lo:work f009
</example>

<example name="quick-park-feature">
User: /lo:park feature "real-time collab editing"

Parked: f010 "Real-time Collab Editing"
</example>

<example name="quick-park-task">
User: /lo:park task "fix dark mode toggle"

Parked: t016 "Fix dark mode toggle"
</example>
```

**Reference files:**
- `references/park-format.md` — format spec for capture files

---

### 3. `/lo:plan`

**Folder:** `lo-plan/`

**Frontmatter:**
```yaml
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
```

**This is a thin integration layer over superpowers.** It does NOT contain brainstorming logic, plan-writing logic, or execution logic. It:
1. Reads project state
2. Sets up context (solutions, parked captures, EARS)
3. Hands off to superpowers
4. Persists the output to `.lo/work/`

**Body structure:**

```markdown
# LO Plan

Turns ideas into structured implementation plans. Adapts depth based on
three signals: conversation context, project status, and feature complexity.

This skill is an integration layer. It delegates design thinking to
superpowers:brainstorming and plan writing to superpowers:writing-plans.
Its job is to set up project context and persist the output.
```

**Decision tree — depth scaling:**

```xml
<depth-scaling>
Read three signals before deciding what to do:

Signal 1: CONVERSATION CONTEXT
- Has the user been discussing this topic in the current conversation?
- Look for: design decisions made, approaches discussed, requirements explored
- Rich context = skip brainstorming, go straight to structuring

Signal 2: PROJECT STATUS (from .lo/project.yml)
- explore → lightweight (skip EARS, quick plan, no review gates)
- build → moderate (offer EARS if complex, plan mode available)
- open → full ceremony (recommend EARS for multi-subsystem, plan mode default)

Signal 3: FEATURE COMPLEXITY
- Single subsystem, known pattern → lightweight
- Multiple subsystems, external APIs, state machines → full ceremony
- Assess by: reading the description, checking what files/systems are involved

Depth matrix:

| Context | Status | Complexity | Depth |
|---------|--------|-----------|-------|
| Rich | any | any | Structure what was discussed. Skip brainstorming. |
| None | explore | low | Quick plan. No brainstorming needed. |
| None | explore | high | Brainstorm first, then quick plan. |
| None | build | low | Quick plan. Offer brainstorming. |
| None | build | high | Brainstorm, offer EARS, plan mode. |
| None | open | any | Brainstorm, recommend EARS, plan mode. |
</depth-scaling>
```

**Flow:**

```xml
<plan-flow>
Step 1: Identify or create the item.

If argument is an ID (f{NNN} or t{NNN}):
  - Look up in BACKLOG.md
  - Check for parked capture in .lo/park/ — if found, load as context
  - Check for existing work directory in .lo/work/
    - Plans exist → ask: re-plan or proceed to /lo:work?
    - No plans → continue

If argument is a description string:
  - Search BACKLOG.md for fuzzy match
  - Found → use existing entry
  - Not found → create new entry:
    - Read next ID from `last_feature` or `last_task` frontmatter counter
    - Add entry to BACKLOG.md
    - Increment counter

If no argument:
  - Show plannable items (open features/tasks in backlog)
  - Ask user to pick one

Step 2: Set up project context.

1. Read .lo/project.yml → extract status
2. Read .lo/solutions/ → check for relevant prior art
3. Read .lo/park/<id>-*.md → load parked conversation capture if exists
4. Assess depth using the depth-scaling decision tree above

Report context:

    Planning: <id> "<name>"
    Status: <project-status>
    Prior art: [solutions found | none]
    Parked context: [loaded | none]
    Depth: [lightweight | moderate | full]

Step 3: Create work directory.

    mkdir -p .lo/work/<id>-slug

Update BACKLOG.md: change status line to `[active](.lo/work/<id>-slug/)`
If parked capture exists, note it as context (don't move/delete it yet).

Step 4: Design.

Based on depth assessment:

LIGHTWEIGHT (rich context or explore/low complexity):
  - Invoke superpowers:writing-plans directly
  - Feed it: the conversation context, parked capture, solutions, feature description
  - Save output to .lo/work/<id>-slug/001-<phase>.md

MODERATE (build status, moderate complexity):
  - Ask: "We've been discussing this. Want me to structure what we have,
    or explore further first?"
  - If structure → invoke superpowers:writing-plans
  - If explore → invoke superpowers:brainstorming, then writing-plans

FULL (open status or high complexity, no context):
  - Invoke superpowers:brainstorming (mandatory)
  - After brainstorming completes, offer EARS:

      This feature involves [signal]. Write EARS requirements?
      1. Yes (recommended)
      2. Skip

  - If EARS: write to .lo/work/<id>-slug/ears-requirements.md
  - Invoke superpowers:writing-plans
  - Save plan to .lo/work/<id>-slug/001-<phase>.md

Step 5: Bridge to execution.

    Plan saved: .lo/work/<id>-slug/001-<phase>.md
    [EARS: .lo/work/<id>-slug/ears-requirements.md]

    Ready to start building? Type /lo:work to begin.

If parked capture was loaded, move it to the work directory for reference:

    mv .lo/park/<id>-slug.md .lo/work/<id>-slug/parked-context.md
</plan-flow>
```

**Task planning (t{NNN} items):**

Tasks are lighter. No brainstorming, no EARS.

```xml
<task-planning>
1. Find or create the task entry
2. Ask:

    Planning: t{NNN} "<description>"

    1. Quick plan — jot down steps, save to .lo/work/
    2. Jump to /lo:work — skip planning, start building

If quick plan:
  - Create .lo/work/t{NNN}-slug/
  - Generate lightweight plan or invoke superpowers:writing-plans
  - Save to 001-task.md
  - Bridge to /lo:work

If jump:
  - Tell user: "Run /lo:work t{NNN} to start"
</task-planning>
```

**Error handling:**
- `.lo/` doesn't exist → "Run /lo:setup first"
- Feature already has plans and is active → offer re-plan or redirect to /lo:work
- Brainstorming skill unavailable → fall back to inline brainstorming
- Writing-plans skill unavailable → fall back to inline plan writing

**Reference files:**
- `references/plan-format.md` — plan file format (frontmatter, task syntax, parallel markers)
- `references/ears-guide.md` — EARS requirements pattern (carried from v0.5.0)
- `references/depth-scaling.md` — detailed depth assessment guide

---

### 4. `/lo:work`

**Folder:** `lo-work/`

**Frontmatter:**
```yaml
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
```

**Another thin integration layer.** Sets up branch isolation and project context, then delegates to superpowers for execution.

**Body structure:**

```markdown
# LO Work

Executes features and tasks. Handles branch isolation, plan discovery, and
progress tracking. Delegates execution patterns to superpowers.

CRITICAL: This skill executes — it does NOT ship. Never push, create PRs,
or mark items done in the backlog. When work is complete, suggest /lo:ship.
```

**Flow:**

```xml
<work-flow>
Step 1: Find or create the work item.

If argument is an ID (f{NNN} or t{NNN}):
  - Look up in BACKLOG.md and .lo/work/

If argument is a description string (not an ID):
  - Search BACKLOG.md for fuzzy match
  - Not found → classify as task, create backlog entry:
    - Read next task ID from `last_task` frontmatter counter
    - Add entry to BACKLOG.md
    - Increment counter
  - Mark as ad-hoc task (no plan, direct execution)

If no argument:
  - Scan .lo/work/ for directories with plan files
  - Also show open items from BACKLOG.md
  - Present combined view:

      Active work:
        f009 Image Generation — .lo/work/f009-image-gen/ (phase 1 of 2)

      Open in backlog:
        f010 Real-time Collab Editing
        t015 Fix button color

      Pick up active work, or start something new?

Step 2: Read plan and project context.

1. Read .lo/project.yml → extract status for test expectations and branch strategy
2. Check .lo/work/<id>-slug/ for plan files (001-*.md, 002-*.md)
3. Check for ears-requirements.md
4. Check for parked-context.md (moved by /lo:plan)

If feature with plans:
  - Parse tasks, dependencies, parallel markers
  - Determine execution strategy
  - Present summary and wait for confirmation

If task without plan:
  - Direct execution — skip to Step 4

Step 3: Set up branch isolation.

Read project status and current branch, then apply defaults:

| Status | Current Branch | Default Action |
|--------|---------------|----------------|
| explore | any | Stay on current branch (no prompt) |
| build/open | main | New branch: feat/f{NNN}-slug or fix/t{NNN}-slug |
| build/open | release branch | Branch off release |
| build/open | already on feature branch | Stay |
| any | dirty working tree | Warn, offer stash or worktree |

For explore: skip the prompt entirely. Just stay where you are.
For build/open: present the recommendation but allow override:

    You're on main. Recommendation: feat/f009-image-gen

    1. New branch (recommended)
    2. Stay on main
    3. Something else

Step 4: Execute.

For features with plans:
  - Invoke superpowers:executing-plans or superpowers:subagent-driven-development
  - based on plan task structure (sequential vs parallel markers)
  - Feed: plan files, EARS contract, project context

For tasks without plans:
  - Execute directly — no subagents, no formal plan
  - Read project status for test expectations:
    - explore → no tests mentioned
    - build → write tests alongside if testable logic
    - open → tests expected for all testable code

For ad-hoc tasks (description string, just created):
  - Execute directly, commit as you go

Step 5: Completion.

    Work complete: <id> "<name>"
    Branch: <branch-name>

    Ready to ship? Run /lo:ship

    [Worth a milestone? Run /lo:stream]
    [Anything reusable? Run /lo:solution]

HARD GATE: Do NOT automatically proceed to shipping.
</work-flow>
```

**Error handling:**
- No .lo/ directory → "Run /lo:setup first"
- No plans for a feature → "Run /lo:plan <id> first, or work on it directly?"
- Merge conflicts during parallel work → stop, report, ask user
- Tests fail → stop, report, fix before continuing
- Superpowers execution skill unavailable → fall back to inline execution

**Reference files:**
- `references/execution-patterns.md` — subagent dispatch, worktree setup, merge protocols (carried from v0.5.0)

---

### 5. `/lo:ship`

**Folder:** `lo-ship/`

**Frontmatter:**
```yaml
---
name: lo-ship
description: Quality pipeline for shipping completed work. Detects mode automatically from project status and branch name — fast mode pushes to main, feature mode opens a PR, release mode generates changelog and finalizes the release. Prunes done items from backlog. Use when user says "ship it", "done", "ready to merge", "push this", or "/lo:ship".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
metadata:
  author: looselyorganized
  version: 0.6.0
---
```

**The crown jewel. Largely carried from v0.5.0 with these changes:**

1. **Backlog pruning** — fast mode and release mode remove `[done]` entries
2. **Release mode absorbed** — no separate `/lo:release` skill; `/lo:ship` handles semver branches
3. **Post-ship prompts** — suggests /lo:stream and /lo:solution
4. **Park cleanup** — removes .lo/park/ files for shipped items

**Mode detection (unchanged):**

| Status | Branch | Mode |
|--------|--------|------|
| explore or closed | any | **fast** |
| build or open | feature branch | **feature** |
| build or open | semver branch | **release** |

**Key changes to gates:**

```xml
<gate-changes>
Gate 1: Pre-flight — UNCHANGED from v0.5.0

Gate 2: EARS audit — UNCHANGED

Gate 3: Tests — UNCHANGED

Gate 4: Reviewer — UNCHANGED

Gate 5: README staleness — UNCHANGED

Gate 6+7: Ship (mode-specific) — CHANGES BELOW:

FAST MODE changes:
  - After marking current item done, PRUNE all previously-done items:
    1. Remove all entries with `[done]` from Features and Tasks sections
    2. Keep the frontmatter counters intact (last_feature, last_task)
    3. Clean up any empty epic headers left behind
  - Delete .lo/park/<id>-*.md if it exists for the shipped item
  - Delete .lo/work/<id>-slug/ if it exists

FEATURE MODE changes:
  - UNCHANGED — leave backlog alone (release ship needs the entries)
  - Delete .lo/park/<id>-*.md if it exists (park was consumed by plan)

RELEASE MODE changes:
  - After generating changelog and before pushing:
    1. Mark current release items as done
    2. PRUNE all done items from backlog (same logic as fast mode)
    3. Delete all .lo/park/ files for shipped items
    4. Delete all .lo/work/ directories for shipped items
  - Absorbs /lo:release: to START a release, run:
    `/lo:ship release <version>` or be on a semver branch
</gate-changes>
```

**Starting a release (absorbed from /lo:release):**

```xml
<start-release>
When user says "/lo:ship release 0.6.0" or "/lo:ship release bump minor":

1. Determine version:
   - Explicit: use the version provided
   - Bump: read current version from plugin.json or package.json, apply bump

2. Create release branch:
   git checkout -b <version>

3. Bump version in source file (plugin.json, package.json, etc.)
4. Commit: "chore: bump version to <version>"
5. Push branch: git push -u origin <version>

6. Report:
   Release started: v<version>
   Branch: <version>

   Work on this branch, then run /lo:ship to finalize.
</start-release>
```

**Post-ship prompt (new):**

```xml
<post-ship>
After reporting, prompt:

FAST MODE and FEATURE MODE:
    Shipped: <id> "<name>"

    Worth a milestone? → /lo:stream
    Anything reusable? → /lo:solution
    ("no" to skip)

RELEASE MODE:
    Shipped: v<version>

    Stream milestone was captured during the pipeline.
    Anything reusable? → /lo:solution
    ("no" to skip)
</post-ship>
```

**Reference files:**
- `references/changelog-format.md` (carried from v0.5.0)

---

### 6. `/lo:status`

**Folder:** `lo-status/`

**Frontmatter:**
```yaml
---
name: lo-status
description: Project dashboard and lifecycle management. Shows project status, open work, and recommends next actions. Handles transitions between explore, build, open, and closed with automation wizards (CI/CD setup, test scaffolding, branch protection). Use when user says "status", "what's next", "where am I", "move to build", "go to open", or "/lo:status".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---
```

**Two major modes: dashboard (new) and transitions (carried from v0.5.0).**

**Dashboard mode (no args) — NEW:**

```xml
<dashboard>
When invoked with no arguments, show a project dashboard:

1. Read .lo/project.yml → status, state
2. Read .lo/BACKLOG.md → open items (features and tasks without [done])
3. Scan .lo/work/ → active work directories with plans
4. Scan .lo/park/ → parked ideas with captures

Display:

    Project: <title>
    Status: <status> | State: <state>

    Active:                                              ← items with .lo/work/ dirs
      f009 Image Generation — phase 2 of 3

    Parked:                                              ← items with .lo/park/ files
      f010 Real-time Collab — .lo/park/f010-collab.md

    Backlog:                                             ← items with no status line
      t015 Fix button color

    Suggested next:
      Continue f009? → /lo:work f009
      Pick up f010? → /lo:plan f010

If everything is empty:
    Project: <title>
    Status: <status> | State: <state>

    Nothing in the backlog. Add ideas with /lo:park or start planning with /lo:plan.
</dashboard>
```

**Transition modes — carried from v0.5.0:**

The build and open transition wizards are carried forward exactly as designed in v0.5.0. These are the CI/CD backbone and should not change.

Key transitions:
- `/lo:status build` — test coverage scan, GitHub automation sync, README creation, database/health checks
- `/lo:status open` — GitHub automation sync, Railway PR deploys, error tracking, uptime, rate limiting
- `/lo:status explore` or `closed` — simple transition + sync script
- `/lo:status public` or `private` — visibility toggle

Only change: transition wizards use `last_feature` / `last_task` counters when adding backlog items (instead of scanning).

**Reference files:**
- Transition wizard details stay in SKILL.md body (they're the core value)

---

### 7. `/lo:stream`

**Folder:** `lo-stream/`

**Frontmatter:**
```yaml
---
name: lo-stream
description: Creates public milestone entries in .lo/STREAM.md — the editorial narrative of a project. Each entry marks a significant event worth posting to socials or showing on a project page. Not a git log. Use when user says "stream", "add milestone", "log progress", "update stream", or "/lo:stream". Also prompted after /lo:ship.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---
```

**Minimal changes from v0.5.0.** The stream skill is already clean and focused.

**Key behavior:**
- Milestones only quality gate: "Would you post this?" If no, it's not a milestone.
- XML entry format in STREAM.md (newest first)
- Prompted post-ship but also invocable standalone
- Reads .lo/work/ and recent git history for context

**Reference files:**
- `references/stream-format.md` (carried from v0.5.0)

---

### 8. `/lo:solution`

**Folder:** `lo-solution/`

**Frontmatter:**
```yaml
---
name: lo-solution
description: Captures reusable knowledge in .lo/solutions/ after completing work. Documents patterns, decisions, and techniques that could help in future projects. Use when user says "capture solution", "what did I learn", "save knowledge", "document pattern", or "/lo:solution". Also prompted after /lo:ship.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---
```

**Minimal changes from v0.5.0.** Solutions skill is already focused.

**Key behavior:**
- Prompts: "What was the problem?", "What did you learn?", "What's reusable?"
- Saves to .lo/solutions/s{NNN}-slug.md
- Prompted post-ship but also invocable standalone
- Referenced by /lo:plan Step 3 (prior art check)

---

## Subagents

Carried from v0.5.0:

| Agent | Model | Role | Used By |
|-------|-------|------|---------|
| `reviewer.md` | sonnet | Code review (secrets, security, dead code, bugs) | /lo:ship Gate 4 |
| `scout.md` | haiku | Fast codebase exploration | /lo:plan (optional) |

---

## Hooks

**SessionStart hook** (carried from v0.5.0):
- Reads `.lo/project.yml` and injects into conversation context
- Ensures Claude always knows the project status and identity

---

## Migration from v0.5.0

| v0.5.0 | v0.6.0 | Action |
|--------|--------|--------|
| `backlog/` skill | `lo-park/` + `lo-status/` dashboard | Rewrite. Park is new. Status gains dashboard. |
| `new/` skill | `lo-setup/` skill | Rename + minor updates (park dir, counters) |
| `plan/` skill | `lo-plan/` skill | Major rewrite. Thin integration layer. Depth scaling. |
| `work/` skill | `lo-work/` skill | Major rewrite. Thin integration layer. Status defaults. |
| `ship/` skill | `lo-ship/` skill | Moderate update. Add pruning, absorb release, post-ship. |
| `release/` skill | Absorbed into `lo-ship/` | Delete. |
| `status/` skill | `lo-status/` skill | Add dashboard mode. Transitions unchanged. |
| `stream/` skill | `lo-stream/` skill | Minimal changes. |
| `solution/` skill | `lo-solution/` skill | Minimal changes. |
| `stocktaper-design-system/` | Removed from plugin | Move to standalone skill outside plugin. |
| `publish/` skill | Removed from plugin | Move to standalone skill outside plugin. |
| `.lo/research/` | Removed | Research happens in conversation. |
| — | `.lo/park/` | New directory for conversation captures. |
| BACKLOG.md (no counters) | BACKLOG.md (with counters) | Add last_feature/last_task to frontmatter. |
| Done items persist | Done items pruned | Ship pipeline removes [done] entries. |

---

## Build Order

When executing on the 0.6.0 branch:

1. **lo-setup** — Foundation. Creates the artifact structure everything else depends on.
2. **lo-park** — New skill, no dependencies. Can be tested standalone.
3. **lo-status** — Needs BACKLOG.md format. Add dashboard mode, carry transitions.
4. **lo-plan** — Needs park, backlog format, superpowers integration.
5. **lo-work** — Needs plan format, superpowers integration.
6. **lo-ship** — Needs everything. Build last. Add pruning, absorb release.
7. **lo-stream** — Minimal changes, independent.
8. **lo-solution** — Minimal changes, independent.

Skills 7-8 can parallel with 4-6.

---

## Success Criteria

Quantitative:
- 8 skills trigger correctly on their documented phrases
- Ship pipeline passes all gates for each mode (fast/feature/release)
- Backlog pruning leaves no done items after fast/release ship
- ID counters prevent collisions after pruning

Qualitative:
- A feature can go from conversation → shipped in 3 commands or fewer
- A task can go from "fix the button" → shipped in 2 commands
- /lo:park captures conversation context that is useful weeks later
- /lo:plan invoked mid-conversation skips brainstorming and goes straight to structuring
- No mandatory prompts that don't add value for the current project status
