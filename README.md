# lo — LORF Work System Plugin

Claude Code plugin for managing work in Loosely Organized projects. Provides a complete work lifecycle: backlog management, plan execution, knowledge capture, and a shipping pipeline.

## Install

Add the marketplace and install the plugin:

```
/plugin marketplace add looselyorganized/lo-plugin
/plugin install lo@looselyorganized
```

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| backlog | `/lo:backlog` | View, add tasks/features |
| plan | `/lo:plan` | Brainstorm and design implementation plans |
| work | `/lo:work` | Execute plans with branch/worktree + parallel agents |
| ship | `/lo:ship` | Stage-aware quality gates → commit → push/PR |
| solution | `/lo:solution` | Capture reusable knowledge |
| status | `/lo:status` | Lifecycle transitions with stage-appropriate automation wizards |
| new | `/lo:new` | Scaffold `.lo/` directory |
| stream | `/lo:stream` | Update `.lo/STREAM.md` with milestones, decisions, and lessons |
| publish | `/lo:publish` | Publish research articles to the platform from `.lo/research/` material |
| stocktaper-design-system | — | StockTaper / LO design system tokens, components, and layout patterns |

## The `.lo/` Convention

> Version 0.5.0 — 2026-03-10

Every LO project repo contains a `.lo/` directory at the repository root. This directory is the **single source of truth** for all project content that appears on the LO website. The website reads project data exclusively from Supabase, which is populated by a GitHub webhook that parses `.lo/` on push.

**Source-of-truth principle:** The `.lo/` directory in the project repo is canonical. The website never reads from the filesystem directly. Supabase is a cache of `.lo/` content, kept in sync by webhooks. If Supabase and `.lo/` disagree, `.lo/` wins (re-sync fixes it).

**Why not MDX in the website repo?** Project content belongs with the project code. When an agent works on a project, it can update the brief or add a stream entry in the same commit as the code change. The website repo stays focused on presentation.

### Directory Structure

```
.lo/
├── PROJECT.md            # Brief, metadata, agent declarations
├── BACKLOG.md            # Feature and task backlog
├── STREAM.md             # Milestones only (single file, newest first)
├── research/             # Research docs (draft → review → published)
│   ├── distributed-locking.md
│   └── institutional-memory.md
├── work/                 # In-progress feature/task plans (deleted on ship)
│   └── f001-feature-slug/
│       └── 001-phase-slug.md
├── solutions/            # Reusable knowledge captured after shipping
│   └── topic-slug.md
```

All files use Markdown with YAML frontmatter (parsed by gray-matter). No MDX — `.lo/` content is plain Markdown to keep the contract simple and parseable by any tool.

### `PROJECT.md` — Project Brief & Metadata

The root file. One per project. Contains all metadata and the project brief.

**Frontmatter contract:**

```yaml
---
id: "proj_UUID"                  # auto-generated, never reused
title: "Project: Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"                  # explore | build | open | closed
state: "public"                  # public | private
repo: "https://github.com/mhofwell/nexus-2"  # optional
stack:                           # optional, array of strings
  - Bun
  - Hono
  - Redis
infrastructure:                  # optional, services layer
  - Railway
  - Supabase
agents:                          # optional, array of agent declarations
  - name: "nexus-coordinator"
    role: "Coordination and task distribution"
---
```

**Body:** The project brief. Free-form Markdown describing what the project is, why it exists, architecture, capabilities, and current state. This replaces the body of `content/projects/{slug}/index.mdx`.

**Required fields:** `id`, `title`, `description`, `status`, `state`
**Optional fields:** `repo`, `stack`, `infrastructure`, `agents`

**Validation rules:**
- `status` must be one of: `explore`, `build`, `open`, `closed`
- `state` must be one of: `public`, `private`
- `agents[].name` and `agents[].role` are required if `agents` is present
- `stack` and `infrastructure` are distinct: stack = code (Bun, React), infrastructure = services (Supabase, Railway)

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

### `research/*.md` — Research Files

Raw materials captured during deep work sessions. Findings, observations, and analysis that may later be combined into published articles on the platform.

**Filename convention:** `{slug}.md` (e.g., `distributed-locking.md`)

**Frontmatter contract:**

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
published_as: "distributed-locking-for-agents"  # optional, set by /lo:publish
---
```

**Body:** Free-form Markdown. Findings, code snippets, observations.

**Required fields:** `title`, `date`, `topics`
**Optional fields:** `published_as` (slug of the platform MDX article, set by `/lo:publish`)

Publishing to the platform is handled by `/lo:publish` from the platform repo, which combines one or more research files into an MDX article.

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

Research articles are published separately via `/lo:publish` from the platform repo, which writes MDX files directly.

### Creating a Valid `.lo/` Directory

To add your project to LO, create a `.lo/` directory at your repo root:

```bash
mkdir -p .lo/research .lo/work .lo/solutions
cat > .lo/STREAM.md <<'EOF'
---
type: stream
---
EOF
```

Create `.lo/PROJECT.md`:

```markdown
---
id: "proj_a1b2c3d4-e5f6-7890-abcd-ef1234567890"   # generate a new UUID v4 — must be unique
title: "Your Project Name"
description: "One-sentence description of what this project does."
status: "explore"
state: "public"
---

Your project brief goes here. What is this? Why does it exist?
What problem does it solve? What's the current state?
```

> **Note:** The `id` field is auto-generated and must be unique. Generate a lowercase UUID v4 — do not copy the example value.

Create `.lo/BACKLOG.md`:

```markdown
---
type: backlog
---

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
