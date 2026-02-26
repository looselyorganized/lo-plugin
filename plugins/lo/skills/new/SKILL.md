---
name: new
description: Scaffolds the .lo/ directory structure for a new LO project. Creates PROJECT.md with full frontmatter template, subdirectories (hypotheses, stream, notes, research, work, solutions), .gitkeep files, and an initial "project started" stream entry. Use when user says "new lo", "create lo", "set up lo", "scaffold lo", "new lo project", "add lo to this repo", "new project", or "/lo:new".
metadata:
  version: 2.0.0
  author: LORF
  category: project-scaffolding
  tags: [lorf, project-setup, scaffolding, convention]
---

# LO New Project

Scaffolds the `.lo/` directory convention in the current repository root.

## When to Use

- User wants to add LO project tracking to a repo
- User invokes `/lo:new`
- User says "new lo", "set up lo", "scaffold lo", "new lo project", "new project"

## Critical Rules

- NEVER overwrite an existing `.lo/` directory. If one exists, warn the user and stop.
- All files use plain Markdown with YAML frontmatter. No MDX.
- `PROJECT.md` is the only content file created at init. `BACKLOG.md` is created by `/lo:backlog` on first use.
- Use today's date (YYYY-MM-DD) for the initial stream entry.

## Workflow

### Step 1: Check for Existing .lo/

Before creating anything, check if `.lo/` already exists at the repo root.

If it exists:
```
A .lo/ directory already exists in this repo.
To avoid overwriting existing project content, I won't re-initialize.
```
Stop here.

### Step 2: Scan the Repo

Before creating files, gather context from the repo to pre-populate the template.

#### 2a: Detect Git Remote

Check for a git remote to pre-fill the `repo` field:
```bash
git remote get-url origin
```
If found, include it as the `repo` value (uncommented). If not, leave it commented out.

#### 2b: Detect Stack

Scan for stack indicators:
- `package.json` → check `dependencies` and `devDependencies` for frameworks (Next.js, React, Hono, Express, etc.)
- `Cargo.toml` → Rust
- `go.mod` → Go
- `pyproject.toml` / `requirements.txt` → Python
- `bun.lockb` / `bun.lock` → Bun runtime
- `pnpm-lock.yaml` → pnpm
- Language/framework names from config files

Pre-populate the `stack` field with what you find.

#### 2c: Detect Infrastructure

Scan ALL of the following sources — check every one, not just the first hit:

1. **package.json** — search `dependencies` AND `devDependencies` for infra packages
2. **Source code** — grep `src/` (or equivalent) for import statements referencing infra SDKs
3. **Config files** — check for infra-specific config at the repo root and common subdirs
4. **Environment variables** — check `.env.example`, `.env.local.example`, or any `.env*` files (NOT `.env` itself) for variable name prefixes
5. **CI/CD files** — check `.github/workflows/`, `Procfile`, `nixpacks.toml`

| Signal (match ANY of these) | Infrastructure |
|------------------------------|---------------|
| `@supabase/supabase-js` or `@supabase/ssr` in deps, `supabase/` dir, `createClient` imported from `@supabase/*` in source, `SUPABASE_URL` or `SUPABASE_ANON_KEY` in env files | Supabase |
| `railway.toml`, `railway.json`, `.railwayignore`, `nixpacks.toml`, `RAILWAY_*` env vars, Railway deploy URL in configs | Railway |
| `vercel.json`, `@vercel/*` in deps, `VERCEL_*` env vars | Vercel |
| `firebase.json`, `firebase-functions` or `firebase-admin` in deps, `.firebaserc` | Firebase / Google Cloud |
| `fly.toml` | Fly.io |
| `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, `.dockerignore` | Docker |
| `terraform/`, `*.tf` files | Terraform |
| `.aws/`, `serverless.yml`, `AWS_*` env vars | AWS |
| `netlify.toml` | Netlify |
| `render.yaml` | Render |
| `planetscale` in deps, `DATABASE_URL` with `pscale` | PlanetScale |

**Important:** Do not stop after checking package.json. Many projects use infra SDKs without listing a CLI tool in deps — you must also grep source files for import patterns like `from "@supabase/"` or `from "firebase"` and check for config/env files.

#### 2d: Ask Which Agent(s)

Ask the user which AI coding agent(s) they use on this project:

Options:
- Claude Code
- Codex
- Cursor
- Other (let user type)

Allow multiple selections. Pre-populate the `agents` field accordingly.

Agent field mapping:

| Selection | name | role |
|-----------|------|------|
| Claude Code | `"claude-code"` | `"AI coding agent (Claude Code)"` |
| Codex | `"codex"` | `"AI coding agent (Codex)"` |
| Cursor | `"cursor"` | `"AI coding agent (Cursor)"` |
| Other | Ask user for name | Ask user for role |

#### 2e: Ask Status & Classification

Ask the user for the project's current status and classification:

**Status** (single select):
- `explore` — Poking at an idea. Conversations, research, references. Nothing built yet.
- `build` — Committed to making something. Code, demo, or prototype exists.
- `open` — Inviting people in. Public, accepting feedback, telemetry running.
- `closed` — Stopped working on it. Record stays up.

**Classification** (single select):
- `public-open` — Open source, anyone can contribute
- `public-closed` — Publicly visible but not accepting contributions
- `classified` — Private / internal only

#### 2f: Auto-fill from Codebase

If a codebase exists (not an empty repo), scan it to pre-populate body sections:

1. **Opening paragraph**: Read the project's README.md (if it exists) to draft a 1-2 sentence summary of what the project is and why it exists.
2. **Capabilities**: Scan the codebase structure (key directories, route files, main entry points, exported modules) and generate a short list of capabilities. Each capability should follow this format exactly: `**Name** — terse technical description`. Example: `**File Claims** — Redis-backed distributed locks on file paths with TTL-based lease expiration`. Keep each capability to one line, no fluff.
3. **Architecture**: Generate a ≤300 character summary of how the system is structured. Focus on key components, runtime, and data flow. Example: `Next.js app router + Supabase Postgres. MDX content parsed at build time, served as static pages. Edge functions handle sync. Railway hosts prod.`

Present all auto-filled content to the user for review/editing before writing. Mark any section you couldn't auto-detect with a `[TODO]` placeholder — never fabricate lengthy descriptions.

### Step 3: Create Directory Structure

```bash
mkdir -p .lo/hypotheses .lo/stream .lo/notes .lo/research .lo/work .lo/solutions
```

### Step 4: Write PROJECT.md

Write `.lo/PROJECT.md` using the scanned values from Step 2.

- Required fields get placeholder values (user edits after)
- `repo`, `stack`, `infrastructure`, `agents` get pre-populated from scan results (uncommented if detected, commented if not)

Template structure:

```markdown
---
title: "Project: [NAME]"
description: "[One-sentence description of what this project does.]"
status: "[from Step 2e]"              # explore | build | open | closed
classification: "[from Step 2e]"      # public-open | public-closed | classified
topics:
  - [topic-1]
  - [topic-2]
repo: "[detected-or-placeholder]"     # Uncommented if detected, commented if not
stack:                                # Uncommented if detected, commented if not
  - [Detected Technology]
  - [Detected Framework]
infrastructure:                       # Uncommented if detected, commented if not
  - [Detected Service]
agents:                               # Populated from user selection in Step 2d
  - name: "[agent-name]"
    role: "[agent-role]"
---

[Opening paragraph: what this project is, why it exists, what problem it solves. Auto-filled from README if available.]

## Capabilities

- **[Name]** — [Terse technical description, one line max]
- **[Name]** — [Terse technical description, one line max]

## Architecture

[≤300 characters. Key components, runtime, data flow. No fluff.]
```

#### Body section notes

The project page parses the body by `## ` headings. Two headings get special rendering:

| Heading | Rendering | Format | Constraint |
|---------|-----------|--------|------------|
| `## Capabilities` | Grid of capability cards | Bullet list: `- **Name** — terse description` (one per line) | Keep each line short and technical |
| `## Architecture` | Prose block alongside the `stack` array | Free-form Markdown | ≤300 characters total |

**Do NOT generate verbose placeholder text.** No multi-sentence product descriptions, no marketing copy. Each section should be terse and technical. If you can't auto-detect content, use a short `[TODO]` placeholder — never fabricate lengthy descriptions.

Any other `## ` headings render as generic prose sections. All sections are optional — omit any that aren't relevant yet.

### Step 5: Write Initial Stream Entry

Write `.lo/stream/YYYY-MM-DD-project-started.md` using today's date:

```markdown
---
type: "milestone"
date: "YYYY-MM-DD"
title: "Project initialized"
---

LO project structure created. Project tracking begins.
```

### Step 6: Write .gitkeep Files

Write empty `.gitkeep` files in directories that start empty:
- `.lo/hypotheses/.gitkeep`
- `.lo/notes/.gitkeep`
- `.lo/research/.gitkeep`
- `.lo/work/.gitkeep`
- `.lo/solutions/.gitkeep`

### Step 7: Confirm

Show the user what was created and what was auto-detected:

```
.lo/ directory created:

  PROJECT.md
    status: [user selection]
    classification: [user selection]
    repo: [detected or placeholder]
    stack: [detected items]
    infrastructure: [detected items]
    agents: [user selections]
    body: [auto-filled sections or TODOs]

  hypotheses/
  stream/YYYY-MM-DD-project-started.md
  notes/
  research/
  work/
  solutions/

Next steps:
  1. Review .lo/PROJECT.md — verify auto-filled content, fill any [TODO] placeholders
  2. Use /lo:backlog to set up your backlog
  3. Use /lo:hypothesis to log your first hypothesis
  4. Use /lo:research to start a research doc
```

## Directory Structure Reference

```
.lo/
├── PROJECT.md
├── hypotheses/
├── stream/
├── notes/
├── research/
├── work/
└── solutions/
```

## Validation

Before finishing, verify:
- [ ] `.lo/PROJECT.md` exists with valid YAML frontmatter
- [ ] All subdirectories exist
- [ ] Stream entry has today's date in both filename and frontmatter
- [ ] `.gitkeep` files in hypotheses/, notes/, research/, work/, solutions/
- [ ] No files outside the expected structure
- [ ] `.lo/work/` directory exists
- [ ] `.lo/solutions/` directory exists
- [ ] `.lo/work/.gitkeep` exists
- [ ] `.lo/solutions/.gitkeep` exists

## Frontmatter Reference

For the full frontmatter contracts for all file types, consult `references/frontmatter-contracts.md`.
