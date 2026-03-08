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
| ship | `/lo:ship` | Test → simplify → security → commit → push → PR |
| solution | `/lo:solution` | Capture reusable knowledge |
| status | `/lo:status` | Manage project lifecycle transitions (explore → build → open → closed) |
| new | `/lo:new` | Scaffold `.lo/` directory |
| stream | `/lo:stream` | Update `.lo/stream/` with milestones and updates |
| publish | `/lo:publish` | Publish research articles to the platform from `.lo/research/` material |
| stocktaper-design-system | — | StockTaper / LO design system tokens, components, and layout patterns |

## The `.lo/` Convention

> Version 0.2.0 — 2026-02-25

Every LO project repo contains a `.lo/` directory at the repository root. This directory is the **single source of truth** for all project content that appears on the LO website. The website reads project data exclusively from Supabase, which is populated by a GitHub webhook that parses `.lo/` on push.

**Source-of-truth principle:** The `.lo/` directory in the project repo is canonical. The website never reads from the filesystem directly. Supabase is a cache of `.lo/` content, kept in sync by webhooks. If Supabase and `.lo/` disagree, `.lo/` wins (re-sync fixes it).

**Why not MDX in the website repo?** Project content belongs with the project code. When an agent works on a project, it can update the brief or add a stream entry in the same commit as the code change. The website repo stays focused on presentation.

### Directory Structure

```
.lo/
├── PROJECT.md            # Brief, metadata, agent declarations
├── BACKLOG.md            # Feature and task backlog
├── stream/               # Milestones, updates, notes
│   ├── 2026-01-15-project-started.md
│   ├── 2026-02-15-prototype-deployed.md
│   └── 2026-02-17-load-test-results.md
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

### `project.md` — Project Brief & Metadata

The root file. One per project. Contains all metadata and the project brief.

**Frontmatter contract:**

```yaml
---
title: "Project: Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"                  # explore | build | open | closed
state: "public"                  # public | private
repo: "https://github.com/mhofwell/nexus-2"  # optional
stack:                           # optional, array of strings
  - Bun
  - Hono
  - Redis
topics:                          # array of strings (for filtering/discovery)
  - distributed-systems
  - agent-coordination
agents:                          # optional, array of agent declarations
  - name: "nexus-coordinator"
    role: "Coordination and task distribution"
    email: "nexus@lo.dev"      # optional, for AgentMail
relatedContent:                  # optional, cross-references to website content
  - type: research
    slug: distributed-locking-for-agents
  - type: thoughts
    slug: why-agents-need-locks
---
```

**Body:** The project brief. Free-form Markdown describing what the project is, why it exists, architecture, capabilities, and current state. This replaces the body of `content/projects/{slug}/index.mdx`.

**Required fields:** `title`, `description`, `status`, `state`, `topics`
**Optional fields:** `repo`, `stack`, `agents`, `relatedContent`

**Validation rules:**
- `status` must be one of: `explore`, `build`, `open`, `closed`
- `state` must be one of: `public`, `private`
- `topics` must be a non-empty array of strings
- `agents[].name` and `agents[].role` are required if `agents` is present
- `relatedContent[].type` must be `research` or `thoughts`

### `stream/*.md` — Project Stream Entries

Chronological log of updates, milestones, and notes. This is the project's activity feed.

**Filename convention:** `YYYY-MM-DD-{slug}.md` (e.g., `2026-02-15-prototype-deployed.md`). Date prefix enables chronological sorting by filename.

**Frontmatter contract:**

```yaml
---
type: "milestone"                # update | milestone | note
date: "2026-02-15"              # Must match filename prefix
title: "Prototype deployed to Railway"
---
```

**Body:** Details of the update. Free-form Markdown.

**Required fields:** `type`, `date`, `title`

**Type semantics:**
- `milestone` — Significant achievement or deliverable (first deploy, major feature complete, etc.)
- `update` — Progress report, status change, design decision
- `note` — Informal observation, thought, or reference

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
mkdir -p .lo/stream .lo/research
```

Create `.lo/project.md`:

```markdown
---
title: "Your Project Name"
description: "One-sentence description of what this project does."
status: "explore"
state: "public"
topics:
  - your-topic
  - another-topic
---

Your project brief goes here. What is this? Why does it exist?
What problem does it solve? What's the current state?
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
