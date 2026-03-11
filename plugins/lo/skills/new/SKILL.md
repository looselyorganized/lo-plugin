---
name: new
description: Scaffolds the .lo/ directory structure for a new LO project. Creates PROJECT.md with full frontmatter template, subdirectories (research, work, solutions), STREAM.md, .gitkeep files, and optional stream initialization. Use when user says "new lo", "create lo", "set up lo", "scaffold lo", "new lo project", "add lo to this repo", "new project", or "/lo:new".
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
- All files use plain Markdown with YAML frontmatter. No MDX.
- `PROJECT.md` is the only content file created at init. `BACKLOG.md` is created by `/lo:backlog` on first use.
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

Scan ALL of the following sources in order — check every one, not just the first hit:

1. **Config files** (definitive — check first) — infra-specific config at repo root and common subdirs
2. **Known directories** — `supabase/`, `prisma/`, `terraform/`, `.aws/`
3. **Package dependencies** — search `dependencies` AND `devDependencies` in `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`
4. **Source code imports** — grep `src/` (or equivalent) for import statements referencing infra SDKs
5. **Environment variable declarations** — check `env.d.ts`, `.env.example`, `.env.template`, `.env.sample`, `.env.local.example`, or any committed `.env*` files (NOT `.env` itself) for variable name prefixes
6. **CI/CD files** — check `.github/workflows/`, `Procfile`, `nixpacks.toml`

| Signal (match ANY of these) | Infrastructure |
|------------------------------|---------------|
| `supabase/config.toml`, `supabase/migrations/`, `@supabase/supabase-js` or `@supabase/ssr` in deps, `createClient` imported from `@supabase/*` in source, `SUPABASE_URL` or `SUPABASE_ANON_KEY` in env declarations | Supabase |
| `railway.toml`, `railway.json`, `.railwayignore`, `nixpacks.toml`, `RAILWAY_*` env vars | Railway |
| `vercel.json`, `@vercel/*` in deps, `VERCEL_*` env vars | Vercel |
| `firebase.json`, `.firebaserc`, `firebase-functions` or `firebase-admin` in deps | Firebase / Google Cloud |
| `wrangler.toml`, `@cloudflare/workers-types` in deps, `CLOUDFLARE_*` env vars | Cloudflare Workers |
| `fly.toml` | Fly.io |
| `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml`, `.dockerignore` | Docker |
| `terraform/`, `*.tf` files | Terraform |
| `.aws/`, `serverless.yml`, `cdk.json`, `aws-cdk-lib` in deps, `AWS_*` env vars | AWS |
| `amplify.yml`, `@aws-amplify/*` in deps | AWS Amplify |
| `netlify.toml` | Netlify |
| `render.yaml` | Render |
| `planetscale` in deps, `DATABASE_URL` with `pscale` | PlanetScale |
| `turso` in deps, `TURSO_*` env vars | Turso |
| `prisma/schema.prisma`, `prisma` in deps | Prisma (ORM) |
| `drizzle.config.ts`, `drizzle-orm` in deps | Drizzle (ORM) |

**Important:** Do not stop after checking package.json. Many projects use infra SDKs without listing a CLI tool in deps — you must also check config files, known directories, grep source files for import patterns, and check env declarations (`env.d.ts` is especially reliable for TypeScript projects).

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

#### 2e: Ask Status & State

Ask the user for the project's current status and state:

**Status** (single select):
- `Explore` — Vibing on an idea, building some demo software, doing initial exploratory research.
- `Build` — Committed to developing production-ready software. Full CI/CD setup. Security hardening.
- `Open` — Multi-tenant ready. Onboarding flows, access controls, and public-facing polish.
- `Closed` — Stopped working on it. Record stays up.

**State** (single select):
- `public` — Publicly visible
- `private` — Private / internal only

#### 2f: Generate project ID

Generate a stable project identifier for this project. This value is written into PROJECT.md frontmatter and used as the universal ID across the platform.

```bash
echo "proj_$(uuidgen | tr '[:upper:]' '[:lower:]')"
```

Save the output (e.g., `proj_166345da-d821-4b3a-abbc-e3a439925e85`) — you will use it in Step 4.

#### 2g: Auto-fill from Codebase

If a codebase exists (not an empty repo), scan it to pre-populate body sections:

1. **Opening paragraph**: Read the project's README.md (if it exists) to draft a 1-2 sentence summary of what the project is and why it exists.
2. **Capabilities**: Scan the codebase structure (key directories, route files, main entry points, exported modules) and generate a short list of capabilities. Each capability should follow this format exactly: `**Name** — terse technical description`. Example: `**File Claims** — Redis-backed distributed locks on file paths with TTL-based lease expiration`. Keep each capability to one line, no fluff.
3. **Architecture**: Generate a ≤300 character summary of how the system is structured. Focus on key components, runtime, and data flow. Example: `Next.js app router + Supabase Postgres. MDX content parsed at build time, served as static pages. Edge functions handle sync. Railway hosts prod.`

Present all auto-filled content to the user for review/editing before writing. Mark any section you couldn't auto-detect with a `[TODO]` placeholder — never fabricate lengthy descriptions.

#### 2h: Verify .gitignore

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

**If exists:** Check whether `.env` is covered:

```bash
grep -q '\.env' .gitignore
```

If `.env` is not in `.gitignore`, warn:

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

### Step 4: Write PROJECT.md

Write `.lo/PROJECT.md` using the scanned values from Step 2.

- Required fields get placeholder values (user edits after)
- `repo`, `stack`, `infrastructure`, `agents` get pre-populated from scan results (uncommented if detected, commented if not)

Template structure:

```markdown
---
id: "[generated-proj-id]"              # From Step 2f — do not edit
title: "[NAME]"
description: "[One-sentence description of what this project does.]"
status: "[from Step 2e]"              # Explore | Build | Open | Closed
state: "[from Step 2e]"               # public | private
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

## Infrastructure

[List hosting, databases, and services. One line per service with its role. Omit if no infrastructure detected.]
```

#### Body section notes

The project page parses the body by `## ` headings. Three headings get special rendering:

| Heading | Rendering | Format | Constraint |
|---------|-----------|--------|------------|
| `## Capabilities` | Grid of capability cards | Bullet list: `- **Name** — terse description` (one per line) | Keep each line short and technical |
| `## Architecture` | Prose block alongside the `stack` array | Free-form Markdown | ≤300 characters total |
| `## Infrastructure` | Service list rendered alongside `infrastructure` array | Bullet list: `- **Service** — role/purpose` (one per line) | Keep terse; omit if none |

**Do NOT generate verbose placeholder text.** No multi-sentence product descriptions, no marketing copy. Each section should be terse and technical. If you can't auto-detect content, use a short `[TODO]` placeholder — never fabricate lengthy descriptions.

Any other `## ` headings render as generic prose sections. All sections are optional — omit any that aren't relevant yet.

### Step 5: Initialize Stream

Check if the repo has any commit history:

```bash
git log --oneline 2>/dev/null | head -1
```

**If no commits exist (empty repo):**

Ask the user to write the first stream announcement. Prompt them: "What's the first thing you want to say about this project?" Use their response as the body of the stream entry.

Prepend the entry to `.lo/STREAM.md` (after the frontmatter):

```markdown
<!-- entry -->
date: YYYY-MM-DD
title: "Project initialized"
commits: 0

[User's announcement text]
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

For new `Explore` projects (the common case), this creates:
- `.coderabbit.yaml` with `reviews.enabled: false`
- `.github/workflows/ci.yml` with dormant status

For new `Build` or `Open` projects, it also creates auto-merge workflow, enables branch protection, etc.

The script auto-detects capabilities from `package.json` and env files.

### Step 8: Confirm

Show the user what was created and what was auto-detected:

```
.lo/ directory created:

  PROJECT.md
    id: [generated]
    status: [user selection]
    state: [user selection]
    repo: [detected or placeholder]
    stack: [detected items]
    infrastructure: [detected items]
    agents: [user selections]
    body: [auto-filled sections or TODOs]

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
├── PROJECT.md
├── STREAM.md
├── research/
├── work/
└── solutions/
```

## Validation

Before finishing, verify:
- [ ] `.lo/PROJECT.md` exists with valid YAML frontmatter (`id` is first field)
- [ ] All three subdirectories exist: `research/`, `work/`, `solutions/`
- [ ] `.gitkeep` files exist in `research/`, `work/`, `solutions/`
- [ ] `.lo/STREAM.md` exists with `type: stream` frontmatter
- [ ] Stream entry (if created) has correct date in inline metadata
- [ ] If Step 7 ran: `.coderabbit.yaml` and `.github/workflows/ci.yml` exist with correct values

## Frontmatter Reference

`id` is **required** and **auto-generated** by this skill (Step 2f). It must be the first field in PROJECT.md frontmatter. Format: `proj_` + lowercase UUID v4 (e.g., `proj_166345da-d821-4b3a-abbc-e3a439925e85`). Never manually assign or reuse an id.

For the full frontmatter contracts for all file types, consult `references/frontmatter-contracts.md`.
