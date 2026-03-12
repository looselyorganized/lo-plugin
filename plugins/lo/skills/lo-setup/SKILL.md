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

# LO Setup

Scaffolds the `.lo/` directory convention in the current repository root. Creates the project identity, backlog, stream, and directory structure that all other LO skills depend on.

## When to Use

- User invokes `/lo:setup`
- User says "setup lo", "new lo project", "scaffold lo", "add lo to this repo"
- A repo needs LO project tracking added for the first time

## Critical Rules

- Check for an existing `.lo/` directory FIRST. If one exists, warn the user and ask for explicit confirmation before overwriting. Do not silently replace project data.
- `project.yml` is pure YAML — no frontmatter delimiters (`---`), no markdown body.
- Always generate a fresh `proj_` UUID for new projects. Never reuse an existing ID.
- Consult `references/project-yml-format.md` for the authoritative format spec.

## Flow

<preflight>
### Step 1: Check for Existing .lo/

Before creating anything, check if `.lo/` exists at the repo root.

If it exists:

```
A .lo/ directory already exists in this repo.
Overwriting will replace project.yml, BACKLOG.md, and STREAM.md.

Proceed? (yes / no)
```

HARD GATE: Do not continue unless the user explicitly confirms. If they say no, stop.

Also check if this is a git repo:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

If not a git repo, warn but proceed:

```
This directory is not a git repository. LO will work, but GitHub automation
(Step 8) will be skipped. Consider running git init first.
```
</preflight>

### Step 2: Gather Project Metadata

Ask the user for four values:

**Title** — project name (e.g., "Nexus", "Platform"). If `README.md` or `package.json` exists, suggest a value from those.

**Description** — one-sentence description of what this project does. Suggest from README or package.json if available.

**Status** (default: `explore`):
- `explore` — Vibing on an idea. Minimal ceremony.
- `build` — Committed to production-ready software. Full CI/CD.
- `open` — Multi-tenant ready. Public-facing polish.
- `closed` — No longer active.

**State** (default: `private`):
- `public` — Publicly visible
- `private` — Internal only

### Step 3: Generate project.yml

Generate a project ID:

```bash
echo "proj_$(uuidgen | tr '[:upper:]' '[:lower:]')"
```

Write `.lo/project.yml` — pure YAML, five fields, no extras. See `references/project-yml-format.md` for the format contract.

```yaml
id: "proj_[generated-uuid]"
title: "[title from Step 2]"
description: "[description from Step 2]"
status: "[status from Step 2]"
state: "[state from Step 2]"
```

### Step 4: Create Directory Structure

```bash
mkdir -p .lo/park .lo/work .lo/solutions
```

The full structure after setup:

```
.lo/
  project.yml
  BACKLOG.md
  STREAM.md
  park/           ← conversation captures (/lo:park)
  work/           ← active plans and execution (/lo:plan, /lo:work)
  solutions/      ← reusable knowledge (/lo:solution)
```

No `.lo/research/` directory — research happens in conversation, not files.

### Step 5: Create BACKLOG.md

Write `.lo/BACKLOG.md` with frontmatter counters for safe ID allocation:

```markdown
---
updated: YYYY-MM-DD
last_feature: 0
last_task: 0
---

## Features

## Tasks
```

Use today's date for `updated`. The `last_feature` and `last_task` counters start at 0 and are incremented by `/lo:park`, `/lo:plan`, and `/lo:work` when creating new items. These counters prevent ID collisions when done items are pruned from the backlog.

### Step 6: Create STREAM.md

Write `.lo/STREAM.md` with type frontmatter:

```markdown
---
type: stream
---
```

Stream entries are added later via `/lo:stream` or during `/lo:ship` release mode.

<optional-todo-scan>
### Step 7: Scan for TODOs (Optional)

Ask the user:

```
Scan the repo for TODO/FIXME/HACK comments and add them to the backlog? (yes / no)
```

If yes:
1. Search the codebase for `TODO`, `FIXME`, `HACK` comments
2. Present findings to the user for review
3. For each approved item, add as a task entry in BACKLOG.md
4. Increment `last_task` in frontmatter for each added item
5. Update the `updated` date

If no, skip.
</optional-todo-scan>

<optional-github-sync>
### Step 8: Reconcile GitHub Automation (Optional)

Skip this step if the repo has no git remote or is not a git repo.

If a remote exists, check for the sync script:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If the script exists, run it. For `explore` projects this creates minimal CI config. For `build` or `open` projects it sets up full automation.

If the script doesn't exist:

```
GitHub sync script not found at scripts/lo-github-sync.sh.
Skipping automation setup. You can configure CI/CD manually or add the script later.
```
</optional-github-sync>

### Step 9: Write .gitkeep Files and Report

Write empty `.gitkeep` files in directories that start empty:
- `.lo/park/.gitkeep`
- `.lo/work/.gitkeep`
- `.lo/solutions/.gitkeep`

Report what was created:

```
.lo/ directory created:

  project.yml
    id: proj_[generated]
    title: [title]
    description: [description]
    status: [status]
    state: [state]

  BACKLOG.md         (empty, counters at 0)
  STREAM.md          (empty)
  park/              conversation captures
  work/              plans and execution
  solutions/         reusable knowledge

  GitHub automation: [applied / skipped (no remote) / skipped (script not found)]

Next steps:
  /lo:park         — capture an idea
  /lo:plan         — design a feature
  /lo:work         — start building
  /lo:status       — view project dashboard
```

## Error Handling

- `.lo/` already exists → warn and require explicit confirmation (Step 1)
- Not a git repo → warn but proceed; skip Step 8
- `uuidgen` not available → fall back to generating a UUID via other means
- Sync script missing → skip with informative message (Step 8)
- Sync script fails → report the error, continue (setup is still valid without automation)

## Validation

Before reporting, verify:
- `.lo/project.yml` exists with valid YAML and all five required fields
- `status` is one of: `explore`, `build`, `open`, `closed`
- `state` is one of: `public`, `private`
- `id` is first field in project.yml, format: `proj_` + lowercase UUID v4
- `.lo/BACKLOG.md` exists with frontmatter counters
- `.lo/STREAM.md` exists with `type: stream` frontmatter
- All three subdirectories exist: `park/`, `work/`, `solutions/`
- `.gitkeep` files exist in all three subdirectories

<example name="new-project-explore">
User: /lo:setup

Checking for existing .lo/ directory... none found.

What's the project title?

User: Nexus

One-sentence description?

User: A coordination server for multi-agent engineering teams.

Status (explore/build/open/closed)? Default: explore

User: explore

State (public/private)? Default: private

User: public

.lo/ directory created:

  project.yml
    id: proj_a8f23bc1-4d91-4e7a-b392-1f8c5e6d9a04
    title: Nexus
    description: A coordination server for multi-agent engineering teams.
    status: explore
    state: public

  BACKLOG.md         (empty, counters at 0)
  STREAM.md          (empty)
  park/              conversation captures
  work/              plans and execution
  solutions/         reusable knowledge

  GitHub automation: applied (explore — dormant CI)

Next steps:
  /lo:park         — capture an idea
  /lo:plan         — design a feature
  /lo:work         — start building
  /lo:status       — view project dashboard
</example>
