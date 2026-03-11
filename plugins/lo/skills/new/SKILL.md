---
name: new
description: Scaffolds the .lo/ directory structure for a new LO project. Creates project.yml with 5 required fields, subdirectories (research, work, solutions), STREAM.md, .gitkeep files, and optional stream initialization. Use when user says "new lo", "create lo", "set up lo", "scaffold lo", "new lo project", "add lo to this repo", "new project", or "/lo:new".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Skill
---

# LO New Project

Scaffolds the `.lo/` directory convention in the current repository root.

## When to Use

- User wants to add LO project tracking to a repo
- User invokes `/lo:new`
- User says "new lo", "set up lo", "scaffold lo", "new lo project", "new project"

## Critical Rules

- NEVER overwrite an existing `.lo/` directory. If one exists, warn the user and stop.
- `project.yml` is pure YAML — no frontmatter delimiters (`---`), no markdown body.
- `project.yml` is the only content file created at init. `BACKLOG.md` is created by `/lo:backlog` on first use.
- If git history exists, ask the user how to handle it (backfill, start fresh, or skip). If no history, ask for the first stream announcement.

## Workflow

### Step 1: Check for Existing .lo/

Before creating anything, check if `.lo/` already exists at the repo root.

If it exists:
```
A .lo/ directory already exists in this repo.
To avoid overwriting existing project content, I won't re-initialize.
```
Stop here.

### Step 2: Gather Project Metadata

#### 2a: Detect Git Remote

Check for a git remote (used by sync script, not written to project file):
```bash
git remote get-url origin
```

#### 2b: Ask Title & Description

Ask the user for:
- **Title** — project name (e.g., "Loosely Organized", "Nexus")
- **Description** — one-sentence description of what this project does

If a `README.md` or `package.json` exists, suggest values from those.

#### 2c: Ask Status & State

Ask the user for the project's current status and state:

**Status** (single select):
- `explore` — Vibing on an idea, building some demo software, doing initial exploratory research.
- `build` — Committed to developing production-ready software. Full CI/CD setup. Security hardening.
- `open` — Multi-tenant ready. Onboarding flows, access controls, and public-facing polish.
- `closed` — Stopped working on it. Record stays up.

**State** (single select):
- `public` — Publicly visible
- `private` — Private / internal only

#### 2d: Generate project ID

Generate a stable project identifier:

```bash
echo "proj_$(uuidgen | tr '[:upper:]' '[:lower:]')"
```

Save the output (e.g., `proj_166345da-d821-4b3a-abbc-e3a439925e85`) — you will use it in Step 4.

#### 2e: Verify .gitignore

Check if `.gitignore` exists at the repo root.

**If missing:** Generate a default based on detected stack:

| Stack | Default .gitignore entries |
|-------|---------------------------|
| Node/Bun | `node_modules/`, `.env`, `.env.local`, `.env*.local`, `.next/`, `dist/`, `.turbo/` |
| Rust | `target/`, `.env` |
| Go | `.env`, `bin/` |
| Python | `__pycache__/`, `.env`, `venv/`, `.venv/`, `dist/`, `*.egg-info/` |
| Any | `.env`, `.DS_Store` |

Always include `.env` and `.DS_Store`. Add stack-specific entries on top. Present the proposed `.gitignore` to the user for review before writing.

**If exists:** Check whether `.env` is covered by the repo's `.gitignore`:

```bash
git check-ignore -v .env
```

Parse the output — only treat `.env` as covered if the match source is the repository's `.gitignore` file (not global excludes or `.git/info/exclude`). If `.env` is not covered by the repo `.gitignore`, warn:

```
Your .gitignore doesn't exclude .env files. This risks committing secrets.
Add .env to .gitignore?
```

If user confirms, append `.env` to the file.

**If exists and covers .env:** No action needed.

### Step 3: Create Directory Structure

```bash
mkdir -p .lo/research .lo/work .lo/solutions
```

Create `.lo/STREAM.md` with the file frontmatter:

```markdown
---
type: stream
---
```

### Step 4: Write project.yml

Write `.lo/project.yml` using the values gathered in Step 2. Pure YAML — no `---` delimiters, no markdown body.

Template:

```yaml
id: "proj_[generated-id]"
title: "[title from Step 2b]"
description: "[description from Step 2b]"
status: "[from Step 2c]"
state: "[from Step 2c]"
```

**Required fields (all 5):** `id`, `title`, `description`, `status`, `state`
**No optional fields.** Stack, infrastructure, agents, and body sections are not part of project.yml.

### Step 5: Initialize Stream

Check if the repo has any commit history:

```bash
git log --oneline 2>/dev/null | head -1
```

**If no commits exist (empty repo):**

Ask the user to write the first stream announcement. Prompt them: "What's the first thing you want to say about this project?" Use their response as the body of the stream entry.

Prepend the entry to `.lo/STREAM.md` (after the frontmatter):

```markdown
<entry>
date: YYYY-MM-DD
title: "Project initialized"
<description>
[User's announcement text]
</description>
</entry>
```

**If commits exist:**

Ask the user how they want to handle existing git history:

- **Backfill stream** — Run `/lo:stream` to scan all existing commits and generate stream entries for the full history.
- **Start fresh** — Write a single "project started" entry dated to the first commit and ignore prior history.
- **Skip** — Don't create any stream entries yet.

If backfill: find the first commit date, write the "project started" entry backdated to it, then run `/lo:stream`.
If start fresh: write the "project started" entry backdated to the first commit date only.
If skip: leave `.lo/STREAM.md` with just the frontmatter (created by Step 3).

### Step 6: Write .gitkeep Files

Write empty `.gitkeep` files in directories that start empty:
- `.lo/research/.gitkeep`
- `.lo/work/.gitkeep`
- `.lo/solutions/.gitkeep`

### Step 7: Reconcile GitHub Automation

**Skip this step entirely if the repo has no git remote** (detected in Step 2a).

If a remote exists, run the sync script to set up GitHub automation:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If the script doesn't exist, warn and skip:

```
GitHub sync script not found at scripts/lo-github-sync.sh. Skipping automation setup.
You can set up CI/CD manually or add the script later.
```

For new `explore` projects (the common case), this creates:
- `.coderabbit.yaml` with `reviews.enabled: false`
- `.github/workflows/ci.yml` with dormant status

For new `build` or `open` projects, it also creates auto-merge workflow, enables branch protection, etc.

The script auto-detects capabilities from `package.json` and env files.

### Step 8: Confirm

Show the user what was created:

```
.lo/ directory created:

  project.yml
    id: [generated]
    title: [user input]
    description: [user input]
    status: [user selection]
    state: [user selection]

  GitHub automation: [lo-github-sync applied / skipped (no remote) / skipped (script not found)]

  STREAM.md [show entry count if created, or "(empty)" if user chose skip]
  research/
  work/
  solutions/

Next steps:
  1. Scan the repo for TODO/FIXME/HACK comments and unfinished work, then add each as a task or feature in BACKLOG.md via /lo:backlog
```

## Directory Structure Reference

```
.lo/
├── project.yml
├── STREAM.md
├── research/
├── work/
└── solutions/
```

## Validation

Before finishing, verify:
- [ ] `.lo/project.yml` exists with valid YAML (`id` is first field)
- [ ] All five required fields present: `id`, `title`, `description`, `status`, `state`
- [ ] `status` is one of: `explore`, `build`, `open`, `closed`
- [ ] `state` is one of: `public`, `private`
- [ ] All three subdirectories exist: `research/`, `work/`, `solutions/`
- [ ] `.gitkeep` files exist in `research/`, `work/`, `solutions/`
- [ ] `.lo/STREAM.md` exists with `type: stream` frontmatter
- [ ] Stream entry (if created) has correct date
- [ ] If Step 7 ran: `.coderabbit.yaml` and `.github/workflows/ci.yml` exist with correct values

## project.yml Reference

`id` is **required** and **auto-generated** by this skill (Step 2d). It must be the first field in project.yml. Format: `proj_` + lowercase UUID v4 (e.g., `proj_166345da-d821-4b3a-abbc-e3a439925e85`). Never manually assign or reuse an id.

For the full format contract, consult `references/frontmatter-contracts.md`.
