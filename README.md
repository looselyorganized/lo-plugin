# lo — LO Work System Plugin

Claude Code plugin for managing work in Loosely Organized projects. Provides a complete work lifecycle: idea capture, planning, execution, knowledge capture, and a shipping pipeline.

## Install

Add the marketplace and install the plugin:

```
/plugin marketplace add looselyorganized/lo-plugin
/plugin install lo@looselyorganized
```

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| setup | `/lo:setup` | Scaffold `.lo/` directory |
| park | `/lo:park` | Capture ideas and conversation context for later |
| plan | `/lo:plan` | Brainstorm and design implementation plans |
| work | `/lo:work` | Execute plans with branch/worktree + parallel agents |
| ship | `/lo:ship` | Quality gates → commit → push/PR; also starts releases |
| status | `/lo:status` | Dashboard and lifecycle transitions with automation wizards |
| stream | `/lo:stream` | Milestone entries in `.lo/STREAM.md` |
| solution | `/lo:solution` | Capture reusable knowledge in `.lo/solutions/` |

## The `.lo/` Convention

> Version 0.6.0 — 2026-03-12

Every LO project repo contains a `.lo/` directory at the repository root. This directory is the **single source of truth** for all project content that appears on the LO website. The website reads project data exclusively from Supabase, which is populated by a GitHub webhook that parses `.lo/` on push.

**Source-of-truth principle:** The `.lo/` directory in the project repo is canonical. The website never reads from the filesystem directly. Supabase is a cache of `.lo/` content, kept in sync by webhooks. If Supabase and `.lo/` disagree, `.lo/` wins (re-sync fixes it).

**Why not MDX in the website repo?** Project content belongs with the project code. When an agent works on a project, it can update the brief or add a stream entry in the same commit as the code change. The website repo stays focused on presentation.

### Directory Structure

```
.lo/
├── project.yml           # Project metadata (5 required fields, pure YAML)
├── BACKLOG.md            # Feature and task backlog with ID counters
├── STREAM.md             # Milestones only (single file, newest first)
├── park/                 # Conversation captures (/lo:park)
├── work/                 # In-progress feature/task plans (deleted on ship)
│   └── f001-feature-slug/
│       └── 001-phase-slug.md
├── solutions/            # Reusable knowledge captured after shipping
│   └── s001-topic-slug.md
```

All files use Markdown with YAML frontmatter (parsed by gray-matter). No MDX — `.lo/` content is plain Markdown to keep the contract simple and parseable by any tool.

### `project.yml` — Project Metadata

The root file. One per project. Pure YAML — no frontmatter delimiters, no markdown body.

**Format:**

```yaml
id: "proj_166345da-d821-4b3a-abbc-e3a439925e85"
title: "Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"
state: "public"
```

**Required fields (all 5):** `id`, `title`, `description`, `status`, `state`
**No optional fields.** Data previously stored in PROJECT.md has moved to canonical sources (`git remote`, `package.json`, `CLAUDE.md`, `README.md`).

**Validation rules:**
- `status` must be one of: `explore`, `build`, `open`, `closed`
- `state` must be one of: `public`, `private`
- `id` format: `proj_` + lowercase UUID v4

### `STREAM.md` — Project Stream

Single file containing milestones only, newest first. This is the project's milestone feed.

**File format:** YAML frontmatter (`type: stream`), then entries using XML tags for reliable parsing. Newest first.

```markdown
---
type: stream
---

<entry>
date: 2026-02-15
title: "Prototype deployed to Railway"
version: "0.1.0"
<description>
First working deployment with Redis-backed coordination. API responds to health checks, WebSocket connections establish successfully.
</description>
</entry>

<entry>
date: 2026-01-15
title: "Project initialized"
<description>
Initial project scaffolding and architecture decisions.
</description>
</entry>
```

**Entry metadata fields:** `date` (required), `title` (required), `version` (optional, releases only), `research` (optional, comma-separated slugs)

**Body:** 1-3 sentences per entry inside `<description>` tags. Public-facing voice.

### `park/` — Conversation Captures

Rich conversation summaries saved by `/lo:park`. When you've been discussing an idea and want to preserve the thinking without committing to planning, park it. The capture file preserves the flow of ideas, decisions, and open questions.

**Filename convention:** `<id>-<slug>.md` (e.g., `f010-image-gen.md`)

**Format:** Plain heading with date, followed by narrative capture. No YAML frontmatter.

### `work/` — In-Progress Work

Contains directories for features and tasks that have been pulled from the backlog. When `/lo:plan` creates a work directory, the item is removed from BACKLOG.md — the work dir becomes the source of truth for in-progress work. When `/lo:ship` completes an item, the work directory is deleted (git history preserves everything).

**Directory convention:** `work/f{NNN}-slug/` or `work/t{NNN}-slug/` (e.g., `work/f003-user-auth/`)

Plans follow the numbered convention: `001-phase-slug.md`, `002-phase-slug.md` for multi-phase work.

**Lifecycle:** backlog → `/lo:plan` (creates dir, removes from backlog) → `/lo:work` (executes) → `/lo:ship` (deletes dir)

### `solutions/` — Reusable Knowledge

Captures reusable patterns and knowledge after completing work. Solutions compound over time — future brainstorming and planning sessions search this directory before starting from scratch.

**Filename convention:** `<topic-slug>.md` (e.g., `parallel-agent-dispatch.md`)

**Frontmatter contract:**

```yaml
---
title: "Parallel Agent Dispatch"
date: "2026-02-25"
feature: "changing-lorf-to-lo"
tags:
  - subagents
  - parallelization
---
```

**Body:** What was learned, what's reusable, concrete patterns. Free-form Markdown.

**Required fields:** `title`, `date`
**Optional fields:** `feature`, `tags`

### Sync Pipeline

`.lo/` content is synced to Supabase by the [content-webhook](https://github.com/looselyorganized/content-webhook) — a Bun HTTP server that receives GitHub push webhooks. When a push touches `.lo/`, the webhook fetches files via GitHub API, parses frontmatter, and upserts to Supabase. The Supabase schema is the source of truth for table structure — query it directly rather than referencing documentation that may drift.

### Creating a Valid `.lo/` Directory

To add your project to LO, create a `.lo/` directory at your repo root:

```bash
mkdir -p .lo/park .lo/work .lo/solutions
cat > .lo/STREAM.md <<'EOF'
---
type: stream
---
EOF
```

Create `.lo/project.yml`:

```yaml
id: "proj_a1b2c3d4-e5f6-7890-abcd-ef1234567890"
title: "Your Project Name"
description: "One-sentence description of what this project does."
status: "explore"
state: "public"
```

> **Note:** The `id` field is auto-generated and must be unique. Generate a lowercase UUID v4 — do not copy the example value.

Create `.lo/BACKLOG.md`:

```markdown
---
updated: 2026-03-12
last_feature: 0
last_task: 0
---

## Features

## Tasks
```

That's the minimum. Add stream entries and research docs as the project evolves. The webhook will sync everything to the website automatically.

## Development

Test the plugin locally:

```bash
claude --plugin-dir ./plugins/lo
```

Validate the marketplace:

```bash
claude plugin validate .
```
