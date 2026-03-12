---
status: pending
feature_id: "f008"
feature: "Plugin v0.6.0 — Flow-First Redesign"
phase: 2
---

# Plugin v0.6.0 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the LO plugin from 11 skills to 8, implementing the flow-first redesign.

**Architecture:** Pure markdown plugin. Each skill is a `SKILL.md` in `plugins/lo/skills/<skill-name>/` with optional `references/` subdirectory. No runtime code. Design spec at `001-design.md` is the authoritative content source for all skills.

**Tech Stack:** Markdown, YAML frontmatter, Claude Code plugin system

---

## File Structure

After implementation, the plugin should look like this:

```
plugins/lo/
├── .claude-plugin/
│   ├── plugin.json                          # version: 0.6.0
│   ├── hooks.json                           # SessionStart hook (unchanged)
│   └── agents/
│       ├── reviewer.md                      # sonnet, code review (unchanged)
│       └── scout.md                         # haiku, exploration (unchanged)
└── skills/
    ├── lo-setup/
    │   ├── SKILL.md
    │   └── references/
    │       └── project-yml-format.md        # carried from new/references/frontmatter-contracts.md
    ├── lo-park/
    │   ├── SKILL.md                         # NEW
    │   └── references/
    │       └── park-format.md               # NEW
    ├── lo-status/
    │   └── SKILL.md
    ├── lo-plan/
    │   ├── SKILL.md
    │   └── references/
    │       ├── ears-guide.md                # carried from plan/references/
    │       ├── plan-format.md               # carried from plan/references/plan-format-contract.md
    │       └── depth-scaling.md             # NEW
    ├── lo-work/
    │   ├── SKILL.md
    │   └── references/
    │       └── execution-patterns.md        # carried from work/references/
    ├── lo-ship/
    │   ├── SKILL.md
    │   └── references/
    │       └── changelog-format.md          # carried from release/references/
    ├── lo-stream/
    │   ├── SKILL.md
    │   └── references/
    │       └── stream-format.md             # carried from stream/references/
    └── lo-solution/
        └── SKILL.md
```

**Removed entirely:** `backlog/`, `new/`, `plan/`, `work/`, `ship/`, `release/`, `status/`, `solution/`, `stream/`, `publish/`, `stocktaper-design-system/`

---

## Chunk 1: Infrastructure

### Task 1: Delete old skills, create new directory structure, migrate reference files

**Files:**
- Delete: `plugins/lo/skills/backlog/` (replaced by lo-park + lo-status dashboard)
- Delete: `plugins/lo/skills/new/` (replaced by lo-setup)
- Delete: `plugins/lo/skills/plan/` (replaced by lo-plan)
- Delete: `plugins/lo/skills/work/` (replaced by lo-work)
- Delete: `plugins/lo/skills/ship/` (replaced by lo-ship)
- Delete: `plugins/lo/skills/release/` (absorbed into lo-ship)
- Delete: `plugins/lo/skills/status/` (replaced by lo-status)
- Delete: `plugins/lo/skills/solution/` (replaced by lo-solution)
- Delete: `plugins/lo/skills/stream/` (replaced by lo-stream)
- Delete: `plugins/lo/skills/publish/` (removed from plugin)
- Delete: `plugins/lo/skills/stocktaper-design-system/` (removed from plugin)
- Create: all 8 new skill directories + references/ subdirs (see file structure above)
- Migrate: 5 reference files (see below)
- Create: `plugins/lo/skills/lo-park/references/park-format.md`
- Create: `plugins/lo/skills/lo-plan/references/depth-scaling.md`

**Important:** Save all reference files BEFORE deleting old directories. The migration is:

| Source (v0.5.0) | Destination (v0.6.0) |
|-----------------|---------------------|
| `plan/references/ears-guide.md` | `lo-plan/references/ears-guide.md` |
| `plan/references/plan-format-contract.md` | `lo-plan/references/plan-format.md` |
| `work/references/execution-patterns.md` | `lo-work/references/execution-patterns.md` |
| `release/references/changelog-format.md` | `lo-ship/references/changelog-format.md` |
| `stream/references/stream-format.md` | `lo-stream/references/stream-format.md` |

- [ ] 1. Save the current commit hash for later reference: `git rev-parse HEAD` — store this as `$V050_REF`. Tasks 4, 7, 8, 9 will need it to read v0.5.0 skill content after deletion.
- [ ] 2. Read all 6 reference files that carry forward (5 direct copies + 1 transformation) and hold in memory:
  - `plan/references/ears-guide.md` → copy as-is
  - `plan/references/plan-format-contract.md` → copy, rename to `plan-format.md`
  - `work/references/execution-patterns.md` → copy as-is
  - `release/references/changelog-format.md` → copy as-is
  - `stream/references/stream-format.md` → copy as-is
  - `new/references/frontmatter-contracts.md` → **extract project.yml section only** (lines 1-48), save as `project-yml-format.md`
- [ ] 3. Delete all 11 old skill directories: `rm -rf plugins/lo/skills/{backlog,new,plan,work,ship,release,status,solution,stream,publish,stocktaper-design-system}`
- [ ] 4. Create 8 new skill directories with references/ subdirs:
```bash
mkdir -p plugins/lo/skills/{lo-setup/references,lo-park/references,lo-status,lo-plan/references,lo-work/references,lo-ship/references,lo-stream/references,lo-solution}
```
- [ ] 5. Write the 5 directly-carried reference files to their new locations (content unchanged)
- [ ] 6. Write `lo-setup/references/project-yml-format.md` — extracted from `frontmatter-contracts.md`. Include ONLY the project.yml section (required fields table, validation rules, example). Drop the STREAM.md and research sections.
- [ ] 7. Write `lo-park/references/park-format.md` — new reference file:

```markdown
# Park File Format

Parked conversation captures live in `.lo/park/`. One file per parked item.

## File naming

`<id>-<slug>.md` — e.g., `f009-image-gen.md`, `t015-auth-refactor.md`

## Format

```
# <id> — <name>
parked: <YYYY-MM-DD>

<Rich narrative capture of the conversation. Multiple paragraphs.
Preserves the flow of thinking, not just the conclusions.>
```

## Content guidelines

The capture should read like meeting notes that preserve the actual flow of ideas:
- What was discussed and in what order
- Decisions made and WHY
- Approaches considered and WHY accepted/rejected
- Points of emphasis from the user
- Open questions that weren't resolved
- Technical details, code patterns, or architecture discussed

Err on too much context rather than too little. Future-you should be immediately
back in the headspace after reading this.
```

- [ ] 8. Write `lo-plan/references/depth-scaling.md` — new reference file:

```markdown
# Depth Scaling Guide

/lo:plan reads three signals to determine planning depth.

## Signal 1: Conversation Context

Has the user been discussing this topic in the current conversation?
- Rich context = skip brainstorming, go straight to structuring
- Look for: design decisions, approaches discussed, requirements explored

## Signal 2: Project Status (from .lo/project.yml)

- explore → lightweight (skip EARS, quick plan, no review gates)
- build → moderate (offer EARS if complex, plan mode available)
- open → full ceremony (recommend EARS, plan mode default)

## Signal 3: Feature Complexity

- Single subsystem, known pattern → lightweight
- Multiple subsystems, external APIs, state machines → full ceremony

## Depth Matrix

| Context | Status | Complexity | Depth |
|---------|--------|-----------|-------|
| Rich | any | any | Structure what was discussed. Skip brainstorming. |
| None | explore | low | Quick plan. No brainstorming needed. |
| None | explore | high | Brainstorm first, then quick plan. |
| None | build | low | Quick plan. Offer brainstorming. |
| None | build | high | Brainstorm, offer EARS, plan mode. |
| None | open | any | Brainstorm, recommend EARS, plan mode. |
```

- [ ] 9. Verify structure: `find plugins/lo/skills -type f | sort` — should show 8 skill dirs, reference files in correct locations
- [ ] 10. Commit: `feat(f008): scaffold v0.6.0 directory structure and migrate reference files`

---

## Chunk 2: Foundation Skills

### Task 2: Write lo-setup SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-setup/SKILL.md`

**Content source:** Design spec `001-design.md` section "1. `/lo:setup`" (lines 121-158)

This is an evolution of the v0.5.0 `new` skill. Key differences from v0.5.0:
- Creates `.lo/park/` directory (new)
- Removes `.lo/research/` from scaffold
- BACKLOG.md template includes `last_feature: 0` and `last_task: 0` in frontmatter
- `project.yml` unchanged (id, title, description, status, state)
- Rename: "new" → "lo-setup"

**Frontmatter (exact):**
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

- [ ] 1. Write `lo-setup/SKILL.md` with frontmatter above and body following design spec section 1
- [ ] 2. Body must include:
  - Scaffold flow (7 steps from design spec)
  - `.lo/park/` in directory creation
  - BACKLOG.md template with `last_feature: 0` / `last_task: 0` frontmatter
  - project.yml template with 5 fields (id, title, description, status, state)
  - Optional `lo-github-sync.sh` invocation
  - Error handling (`.lo/` already exists → warn and confirm)
- [ ] 3. Reference `references/project-yml-format.md` from body where appropriate
- [ ] 4. Target: ≤1200 words body (v0.5.0 was 1186, this is similar scope)
- [ ] 5. Validate: `claude plugin validate .` from repo root
- [ ] 6. Commit: `feat(f008): write lo-setup skill`

### Task 3: Write lo-park SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-park/SKILL.md`

**Content source:** Design spec `001-design.md` section "2. `/lo:park`" (lines 165-380)

This is a **brand new skill** — nothing like it in v0.5.0. It has two modes:
1. **Capture from conversation** (primary) — rich near-verbatim summary with review gate
2. **Quick park** — just a backlog entry, no capture file

**Frontmatter (exact):**
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

- [ ] 1. Write `lo-park/SKILL.md` with frontmatter above and body following design spec section 2
- [ ] 2. Body must include:
  - When to use / when NOT to use (redirect table)
  - Critical rules (`.lo/` must exist, review gate, read counters from frontmatter)
  - Mode detection from arguments
  - Mode 1: Full capture-flow XML block (Steps 1-4 from design spec)
  - Mode 2: Quick park flow
  - Error handling (no `.lo/`, missing BACKLOG.md, user rejects capture)
  - All 3 examples from design spec (rich capture, quick feature, quick task)
- [ ] 3. Reference `references/park-format.md` from body
- [ ] 4. Target: ≤1500 words body (new skill, needs full specification)
- [ ] 5. Validate: `claude plugin validate .` from repo root
- [ ] 6. Commit: `feat(f008): write lo-park skill (new)`

### Task 4: Write lo-status SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-status/SKILL.md`

**Content source:** Design spec `001-design.md` section "6. `/lo:status`" (lines 864-937)

Two modes: **dashboard** (new) and **transitions** (carried from v0.5.0).

The v0.5.0 status skill is 2439 words — the largest skill. The transition wizards are the core value and should be carried forward exactly. The new dashboard mode adds ~200 words.

**Frontmatter (exact):**
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

- [ ] 1. Read the v0.5.0 `status/SKILL.md` from git history: `git show $V050_REF:plugins/lo/skills/status/SKILL.md`
- [ ] 2. Write `lo-status/SKILL.md` with:
  - Frontmatter above
  - NEW: Dashboard mode (no-args) — reads project.yml, BACKLOG.md, scans .lo/work/ and .lo/park/, shows categorized view with suggested-next actions (from design spec)
  - CARRIED: All transition wizards from v0.5.0 (explore→build, build→open, open→closed, visibility toggle)
  - CHANGE: Transition wizards use `last_feature`/`last_task` counters when adding backlog items (not scanning)
  - Mode detection: no args → dashboard, status name → transition
- [ ] 3. Target: ≤2600 words body (v0.5.0 was 2439, adding ~200 for dashboard)
- [ ] 4. Validate: `claude plugin validate .` from repo root
- [ ] 5. Commit: `feat(f008): write lo-status skill with dashboard mode`

---

## Chunk 3: Core Workflow Skills

### Task 5: Write lo-plan SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-plan/SKILL.md`

**Content source:** Design spec `001-design.md` section "3. `/lo:plan`" (lines 383-579)

This is a **thin integration layer over superpowers**. It does NOT contain brainstorming or plan-writing logic. It:
1. Reads project state (status, solutions, parked captures)
2. Assesses depth using the depth-scaling decision tree
3. Hands off to superpowers:brainstorming and/or superpowers:writing-plans
4. Persists output to `.lo/work/`

**Frontmatter (exact):**
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

- [ ] 1. Write `lo-plan/SKILL.md` with frontmatter above and body following design spec section 3
- [ ] 2. Body must include:
  - Integration layer framing (delegates to superpowers, not a workflow engine)
  - Depth-scaling decision tree (XML block with 3 signals + matrix) — reference `references/depth-scaling.md`
  - Plan flow (XML block, Steps 1-5 from design spec):
    - Step 1: Identify or create item (ID lookup, fuzzy match, create new with counter)
    - Step 2: Set up context (project.yml, solutions, parked captures)
    - Step 3: Create work directory, update BACKLOG.md
    - Step 4: Design (LIGHTWEIGHT / MODERATE / FULL paths)
    - Step 5: Bridge to execution (suggest /lo:work, move parked capture)
  - Task planning section (lighter, no brainstorming/EARS)
  - Error handling
  - Reference `references/ears-guide.md` and `references/plan-format.md`
- [ ] 3. Target: ≤1500 words body (v0.5.0 was 1145 — this grows slightly with depth scaling)
- [ ] 4. Validate: `claude plugin validate .` from repo root
- [ ] 5. Commit: `feat(f008): write lo-plan skill as thin superpowers integration`

### Task 6: Write lo-work SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-work/SKILL.md`

**Content source:** Design spec `001-design.md` section "4. `/lo:work`" (lines 585-728)

Another **thin integration layer**. Sets up branch isolation and project context, then delegates to superpowers for execution.

**Frontmatter (exact):**
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

- [ ] 1. Write `lo-work/SKILL.md` with frontmatter above and body following design spec section 4
- [ ] 2. Body must include:
  - Critical rule: executes, does NOT ship (never push, create PRs, or mark done)
  - Work flow (XML block, Steps 1-5 from design spec):
    - Step 1: Find or create work item (ID lookup, fuzzy match, ad-hoc task creation with counter)
    - Step 2: Read plan and project context
    - Step 3: Branch isolation with status-aware defaults table (explore = stay, build/open = new branch)
    - Step 4: Execute (features with plans → superpowers, tasks without plans → direct, ad-hoc → direct)
    - Step 5: Completion (hard gate: do NOT auto-ship, suggest /lo:ship + /lo:stream + /lo:solution)
  - Error handling
  - Reference `references/execution-patterns.md`
- [ ] 3. Target: ≤1800 words body (v0.5.0 was 1953 — slightly trimmed as integration layer)
- [ ] 4. Validate: `claude plugin validate .` from repo root
- [ ] 5. Commit: `feat(f008): write lo-work skill as thin superpowers integration`

### Task 7: Write lo-ship SKILL.md (depends on 2, 3, 4, 5, 6, 8, 9)

**Files:**
- Create: `plugins/lo/skills/lo-ship/SKILL.md`

**Content source:** Design spec `001-design.md` section "5. `/lo:ship`" (lines 735-858)

The crown jewel. Largely carried from v0.5.0 with these additions:
1. **Backlog pruning** — fast/release modes remove `[done]` entries from BACKLOG.md
2. **Release mode absorbed** — `/lo:ship release <version>` starts a release (no separate /lo:release)
3. **Post-ship prompts** — suggests /lo:stream and /lo:solution after shipping
4. **Park cleanup** — removes `.lo/park/` files and `.lo/work/` dirs for shipped items

**Frontmatter (exact):**
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

- [ ] 1. Read the v0.5.0 `ship/SKILL.md` from git history: `git show $V050_REF:plugins/lo/skills/ship/SKILL.md`
- [ ] 2. Read the v0.5.0 `release/SKILL.md` from git history: `git show $V050_REF:plugins/lo/skills/release/SKILL.md`
- [ ] 3. Write `lo-ship/SKILL.md` with:
  - Frontmatter above
  - CARRIED: Mode detection table (explore/closed → fast, feature branch → feature, semver branch → release)
  - CARRIED: Gates 1-5 (pre-flight, EARS audit, tests, reviewer subagent, README staleness)
  - CARRIED: Gate 6-7 fast mode (commit, push to main) + NEW: prune done items, delete park/work files
  - CARRIED: Gate 6-7 feature mode (commit, push branch, create PR) + NEW: delete park files
  - CARRIED: Gate 6-7 release mode (changelog, commit, push, PR) + NEW: prune done items, delete park/work files
  - NEW: Start-release flow (absorbed from /lo:release — `/lo:ship release <version>`)
  - NEW: Post-ship prompt (suggest /lo:stream + /lo:solution)
  - NEW: Backlog pruning logic (remove `[done]` entries, keep frontmatter counters)
  - Reference `references/changelog-format.md`
- [ ] 4. Target: ≤2500 words body (v0.5.0 ship was 2089 + release was 553 — combined and trimmed)
- [ ] 5. Validate: `claude plugin validate .` from repo root
- [ ] 6. Commit: `feat(f008): write lo-ship skill with pruning and absorbed release`

---

## Chunk 4: Cleanup Skills & Finalize

### Task 8: Write lo-stream SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-stream/SKILL.md`

**Content source:** Design spec `001-design.md` section "7. `/lo:stream`" (lines 942-970)

Minimal changes from v0.5.0. The stream skill is already clean.

**Frontmatter (exact):**
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

- [ ] 1. Read v0.5.0 `stream/SKILL.md` from git history: `git show $V050_REF:plugins/lo/skills/stream/SKILL.md`
- [ ] 2. Write `lo-stream/SKILL.md` carrying forward v0.5.0 body with:
  - Updated frontmatter (add metadata block)
  - Milestones-only quality gate ("would you post this?")
  - XML entry format
  - Standalone + post-ship invocation paths
  - Reference `references/stream-format.md`
- [ ] 3. Target: ≤1200 words body (v0.5.0 was 1177)
- [ ] 4. Validate: `claude plugin validate .` from repo root
- [ ] 5. Commit: `feat(f008): write lo-stream skill`

### Task 9: Write lo-solution SKILL.md [parallel]

**Files:**
- Create: `plugins/lo/skills/lo-solution/SKILL.md`

**Content source:** Design spec `001-design.md` section "8. `/lo:solution`" (lines 976-1003)

Minimal changes from v0.5.0.

**Frontmatter (exact):**
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

- [ ] 1. Read v0.5.0 `solution/SKILL.md` from git history: `git show $V050_REF:plugins/lo/skills/solution/SKILL.md`
- [ ] 2. Write `lo-solution/SKILL.md` carrying forward v0.5.0 body with:
  - Updated frontmatter (add metadata block)
  - Prompts: "What was the problem?", "What did you learn?", "What's reusable?"
  - Sequential IDs (`s{NNN}`)
  - Standalone + post-ship invocation paths
  - Referenced by /lo:plan (prior art check)
- [ ] 3. Target: ≤650 words body (v0.5.0 was 629)
- [ ] 4. Validate: `claude plugin validate .` from repo root
- [ ] 5. Commit: `feat(f008): write lo-solution skill`

### Task 10: Finalize — plugin.json, CLAUDE.md, validation

**Files:**
- Modify: `plugins/lo/.claude-plugin/plugin.json` (bump version)
- Modify: `CLAUDE.md` (update skill list, directory layout, commands)

- [ ] 1. Update `plugin.json`: change `version` from `"0.5.0"` to `"0.6.0"`. Update `description` to: `"LO work system — park ideas, plan features, execute work, and ship with quality gates for Loosely Organized projects"`
- [ ] 2. Update `CLAUDE.md` "Project Layout" section to reflect new skill directory names (`lo-setup`, `lo-park`, etc.) and removal of `backlog/`, `publish/`, `release/`, `stocktaper-design-system/`
- [ ] 3. Update `CLAUDE.md` "Editing Skills" section if any patterns changed
- [ ] 4. Update `CLAUDE.md` skill cross-reference section (`/lo:plan`, `/lo:work`, etc.) to match v0.6.0 routing
- [ ] 5. Verify no stale references to `.lo/research/` remain in CLAUDE.md or other project docs. Remove any found.
- [ ] 6. Final validation: `claude plugin validate .` from repo root
- [ ] 7. Verify all 8 skills are discovered: check that `plugin validate` reports exactly 8 skills
- [ ] 8. Commit: `feat(f008): bump to v0.6.0, update CLAUDE.md`

---

## Execution Notes

### Parallelism

```
Task 1 (infrastructure) ──────────────────────────────┐
                                                       │
Task 2 (lo-setup)    ─────── [parallel] ───────┐       │
Task 3 (lo-park)     ─────── [parallel] ───────┤       │
Task 4 (lo-status)   ─────── [parallel] ───────┤       │
Task 5 (lo-plan)     ─────── [parallel] ───────┤       │
Task 6 (lo-work)     ─────── [parallel] ───────┤       │
Task 8 (lo-stream)   ─────── [parallel] ───────┤       │
Task 9 (lo-solution) ─────── [parallel] ───────┤       │
                                               │       │
Task 7 (lo-ship)     ─── (depends on all) ─────┤       │
                                               │       │
Task 10 (finalize)   ─── (depends on all) ─────┘       │
                                                       │
```

Tasks 2, 3, 4, 5, 6, 8, 9 can all run in parallel after Task 1 completes (each references the design spec directly, not each other's output). Task 7 (ship) and Task 10 (finalize) depend on all others.

### Validation

`claude plugin validate .` should be run after each skill is written. If validation fails, fix the issue before committing. Common issues:
- Missing required frontmatter fields
- SKILL.md not in correct directory
- `name` field doesn't match directory name pattern

### Content guidance

Each SKILL.md should follow the Anthropic Skills Guide principles:
- Progressive disclosure: frontmatter → body → references
- Description = WHAT + WHEN (triggers)
- Body ≤ 5,000 words (most should be ≤2,000)
- Be specific and actionable
- Include error handling for every decision point
- Include examples at the bottom

The design spec (`001-design.md`) is the authoritative source for all skill content. When the design spec specifies frontmatter, body structure, flow, error handling, or examples — follow it exactly. The plan specifies the ORDER and MECHANICS of creating files; the design spec specifies the CONTENT.
