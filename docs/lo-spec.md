# The `.lo/` Convention Spec

> Version 0.2.0 — 2026-02-25

## Overview

Every LO project repo contains a `.lo/` directory at the repository root. This directory is the **single source of truth** for all project content that appears on the LO website. The website reads project data exclusively from Supabase, which is populated by a GitHub webhook that parses `.lo/` on push.

**Source-of-truth principle:** The `.lo/` directory in the project repo is canonical. The website never reads from the filesystem directly. Supabase is a cache of `.lo/` content, kept in sync by webhooks. If Supabase and `.lo/` disagree, `.lo/` wins (re-sync fixes it).

**Why not MDX in the website repo?** Project content belongs with the project code. When an agent works on a project, it can update the brief, log a hypothesis, or add a stream entry in the same commit as the code change. The website repo stays focused on presentation.

---

## Directory Structure

```
.lo/
├── PROJECT.md            # Brief, metadata, agent declarations
├── BACKLOG.md            # Feature and task backlog
├── hypotheses/           # One file per hypothesis
│   ├── h001-redis-locking.md
│   └── h002-crdt-state.md
├── stream/               # Milestones, updates, notes
│   ├── 2026-01-15-project-started.md
│   ├── 2026-02-15-prototype-deployed.md
│   └── 2026-02-17-load-test-results.md
├── research/             # Research docs (raw/drafts)
│   ├── distributed-locking.md
│   └── institutional-memory.md
├── work/                 # Active feature work directories
│   └── feature-name/
│       └── plan.md
├── solutions/            # Reusable knowledge captured after shipping
│   └── topic-slug.md
└── notes/                # Informal scratch notes
    └── observation.md
```

All files use Markdown with YAML frontmatter (parsed by gray-matter). No MDX — `.lo/` content is plain Markdown to keep the contract simple and parseable by any tool.

---

## File Specifications

### `project.md` — Project Brief & Metadata

The root file. One per project. Contains all metadata and the project brief.

**Frontmatter contract:**

```yaml
---
title: "Project: Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"                  # explore | build | open | closed
classification: "public"         # public | private
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

**Required fields:** `title`, `description`, `status`, `classification`, `topics`
**Optional fields:** `repo`, `stack`, `agents`, `relatedContent`

**Validation rules:**
- `status` must be one of: `explore`, `build`, `open`, `closed`
- `classification` must be one of: `public`, `private`
- `topics` must be a non-empty array of strings
- `agents[].name` and `agents[].role` are required if `agents` is present
- `relatedContent[].type` must be `research` or `thoughts`

---

### `hypotheses/*.md` — Hypothesis Files

One file per hypothesis. Hypotheses track the research questions and bets a project is testing.

**Filename convention:** `h{NNN}-{slug}.md` (e.g., `h001-redis-locking.md`). The numeric prefix ensures stable ordering; the slug is for human readability.

**Frontmatter contract:**

```yaml
---
id: "h001"                       # Unique within the project, matches filename prefix
statement: "Redis distributed locks with TTL expiration are sufficient for file-level mutual exclusion in multi-agent systems"
status: "validated"              # proposed | testing | validated | invalidated | revised
date: "2026-02-15"              # Date of last status change
revisesId: "h000"               # optional — links to a prior hypothesis this revises
---
```

**Body:** Notes, evidence, observations, test results. Free-form Markdown. This is where the reasoning lives.

**Required fields:** `id`, `statement`, `status`, `date`
**Optional fields:** `revisesId`

**Status transitions:**
```
proposed → testing → validated
                   → invalidated
                   → revised (creates new hypothesis with revisesId pointing back)
```

---

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

---

### `research/*.md` — Research Documents

Research articles that are specific to this project. These may be drafts that eventually get published to the website's `content/research/` directory, or they may stay as project-internal docs.

**Filename convention:** `{slug}.md` (e.g., `distributed-locking.md`)

**Frontmatter contract:**

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
status: "draft"                  # draft | review | published
---
```

**Body:** Full research content. Free-form Markdown.

**Required fields:** `title`, `date`, `topics`, `status`

**Status semantics:**
- `draft` — Work in progress, visible only on the project detail page
- `review` — Ready for review, may appear in a "coming soon" section
- `published` — Finalized, synced to the website's research section

---

### `work/` — Active Feature Work

Contains directories for features graduated from the backlog. Each feature gets its own directory with plan files.

**Directory convention:** `work/<feature-slug>/` (e.g., `work/changing-lorf-to-lo/`)

Plans follow the numbered convention: `plan.md` for single-phase features, or `001-phase-name.md`, `002-phase-name.md` for multi-phase work.

Managed by `/lo:backlog pick` (creates directory) and `/lo:work` (executes plans).

---

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

Managed by `/lo:solution`.

---

### `notes/` — Scratch Notes

Informal observations, thoughts, and reference material that don't fit elsewhere. Not synced to the website.

**Filename convention:** `<slug>.md` — no date prefix required.

No frontmatter contract — freeform.

---

## Supabase Schema Design

Five new tables store parsed `.lo/` content. These are **separate from the existing telemetry tables** (`projects`, `events`, `daily_metrics`, `facility_status`). The telemetry pipeline owns those tables; the webhook pipeline owns these.

### Table: `project_content`

The core table. One row per project. Keyed by `content_slug` (matches the existing `content_slug` column on the telemetry `projects` table, enabling joins).

| Column | Type | Notes |
|--------|------|-------|
| `content_slug` | `text` PRIMARY KEY | e.g., `"nexus"`. Universal FK across both pipelines. |
| `title` | `text` NOT NULL | From `project.md` frontmatter |
| `description` | `text` NOT NULL | From `project.md` frontmatter |
| `status` | `text` NOT NULL | Enum-like: `explore\|build\|open\|closed` |
| `classification` | `text` NOT NULL | Enum-like: `public\|private` |
| `repo_url` | `text` | Nullable. GitHub repo URL. |
| `stack` | `jsonb` | Array of strings: `["Bun", "Hono", "Redis"]` |
| `topics` | `jsonb` NOT NULL | Array of strings: `["distributed-systems", "redis"]` |
| `agents` | `jsonb` | Array of `{name, role, email?}` objects |
| `related_content` | `jsonb` | Array of `{type, slug}` objects |
| `body` | `text` NOT NULL | Markdown body from `project.md` |
| `synced_at` | `timestamptz` NOT NULL | Last webhook sync timestamp |
| `repo_owner` | `text` | Parsed from `repo_url` for webhook routing |
| `repo_name` | `text` | Parsed from `repo_url` for webhook routing |

**Indexes:**
- Primary key on `content_slug`
- Index on `status` (for filtering)
- Index on `(repo_owner, repo_name)` (for webhook lookup)

**Design decisions:**
- JSONB for `stack`, `topics`, `agents`, `related_content` — preserves the document shape from `.lo/project.md` without normalization overhead. Queried via `@>` containment or `->` extraction.
- `content_slug` is the universal join key across both the telemetry pipeline (`projects.content_slug`) and the content pipeline. This means a single query can join project content + telemetry data.
- `body` stored as plain Markdown, not rendered HTML. The frontend handles rendering (same as current MDX approach, but simpler — no JSX components in `.lo/` content).

### Table: `hypotheses`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `text` NOT NULL | e.g., `"h001"` |
| `content_slug` | `text` NOT NULL FK → `project_content` | |
| `statement` | `text` NOT NULL | The hypothesis statement |
| `status` | `text` NOT NULL | `proposed\|testing\|validated\|invalidated\|revised` |
| `date` | `date` NOT NULL | Date of last status change |
| `revises_id` | `text` | Nullable. Points to a prior hypothesis `id` within the same project. |
| `notes` | `text` | Markdown body from the hypothesis file |
| `synced_at` | `timestamptz` NOT NULL | |

**Primary key:** `(content_slug, id)` — composite, since hypothesis IDs are scoped to a project.

**Indexes:**
- FK index on `content_slug`
- Index on `status` (for filtering)

### Table: `project_stream`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` DEFAULT `gen_random_uuid()` PRIMARY KEY | |
| `content_slug` | `text` NOT NULL FK → `project_content` | |
| `slug` | `text` NOT NULL | Derived from filename: `2026-02-15-prototype-deployed` |
| `type` | `text` NOT NULL | `update\|milestone\|note` |
| `date` | `date` NOT NULL | |
| `title` | `text` NOT NULL | |
| `body` | `text` | Markdown content |
| `source` | `text` NOT NULL DEFAULT `'webhook'` | `manual\|webhook` — distinguishes entries created via webhook (from `.lo/stream/`) vs manual entries added through the website or MCP tools. |
| `synced_at` | `timestamptz` NOT NULL | |

**Indexes:**
- FK index on `content_slug`
- Index on `(content_slug, date DESC)` for chronological queries
- Unique on `(content_slug, slug)` to prevent duplicate stream entries

### Table: `project_contributors`

Contributor data comes from two sources: the GitHub API (commit authors) and agent declarations in `.lo/project.md`. The webhook pipeline merges both.

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` DEFAULT `gen_random_uuid()` PRIMARY KEY | |
| `content_slug` | `text` NOT NULL FK → `project_content` | |
| `username` | `text` NOT NULL | GitHub username or agent name |
| `avatar_url` | `text` | GitHub avatar URL |
| `commits` | `integer` DEFAULT 0 | Commit count from GitHub API |
| `profile_url` | `text` | GitHub profile URL |
| `type` | `text` NOT NULL | `author\|core-contributor\|contributor\|agent` |
| `agent_name` | `text` | Only set for `type = 'agent'`. Matches `agents[].name` from `project.md`. |
| `synced_at` | `timestamptz` NOT NULL | |

**Indexes:**
- FK index on `content_slug`
- Unique on `(content_slug, username)` to prevent duplicates

**Contributor type derivation:**
- `author` — repo owner (from GitHub API)
- `core-contributor` — top contributors by commit count (threshold TBD)
- `contributor` — anyone with commits
- `agent` — matched from `agents[]` declaration in `project.md` (by name or email)

### Table: `research_docs`

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` DEFAULT `gen_random_uuid()` PRIMARY KEY | |
| `content_slug` | `text` NOT NULL FK → `project_content` | |
| `slug` | `text` NOT NULL | Derived from filename |
| `title` | `text` NOT NULL | |
| `date` | `date` NOT NULL | |
| `topics` | `jsonb` NOT NULL | Array of strings |
| `status` | `text` NOT NULL | `draft\|review\|published` |
| `body` | `text` NOT NULL | Full Markdown content |
| `synced_at` | `timestamptz` NOT NULL | |

**Indexes:**
- FK index on `content_slug`
- Unique on `(content_slug, slug)`
- Index on `status` (for filtering published docs)

---

## Activity State Derivation

Activity state is **computed, not stored**. It's derived from the most recent event timestamp across all data sources for a project.

```
last_activity = MAX(
  project_content.synced_at,
  MAX(project_stream.date),
  MAX(events.timestamp WHERE project = content_slug)  -- from telemetry pipeline
)

activity_state = CASE
  WHEN now() - last_activity < interval '24 hours'  THEN 'active'
  WHEN now() - last_activity < interval '7 days'     THEN 'idle'
  ELSE 'dormant'
END
```

**Rules:**
- **Active** (<24h since last activity) — Project has recent commits, telemetry events, or stream updates.
- **Idle** (24h–7d) — No recent activity, but the project was recently worked on.
- **Dormant** (>7d) — No activity for over a week.

Activity state is computed at query time (or cached with a short TTL). It is never written to a column — this avoids stale data and the need for a cron job.

---

## Webhook Data Flow Overview

> This section is a reference for Phase 3 implementation. No webhook code is written in Phase 1.

### Push Event Flow

```
1. Developer pushes to project repo (e.g., nexus-2)
2. GitHub sends push webhook to Supabase Edge Function
3. Edge Function checks: does the push modify files under .lo/?
   - If no → exit early
   - If yes → continue
4. Edge Function fetches .lo/ contents via GitHub Contents API
5. Parse each file:
   - project.md → upsert project_content
   - hypotheses/*.md → upsert hypotheses (delete removed files)
   - stream/*.md → upsert project_stream (source = 'webhook')
   - research/*.md → upsert research_docs
6. Fetch contributors via GitHub Contributors API → upsert project_contributors
7. Match agents[] from project.md → insert agent contributors
8. Update synced_at timestamps
```

### Webhook Routing

The Edge Function identifies which project to update by matching `(repo_owner, repo_name)` from the webhook payload against `project_content.repo_owner` and `project_content.repo_name`.

**Bootstrap problem:** The first `.lo/project.md` push for a new project creates the `project_content` row. The Edge Function must handle the INSERT case (new project) as well as UPDATE (existing project).

### Conflict Resolution

- Webhook is the authority for all `.lo/`-sourced data. Each sync is a full overwrite of the parsed content.
- `project_stream` entries with `source = 'manual'` are never touched by the webhook. Only `source = 'webhook'` entries are upserted/deleted.
- `synced_at` timestamps enable debugging sync issues and cache invalidation.

---

## Indexing Strategy

### Website Queries

| Query | Table(s) | Index Used |
|-------|----------|------------|
| List all public projects | `project_content` | `status` |
| Project detail page | `project_content` JOIN `hypotheses` JOIN `project_stream` JOIN `project_contributors` JOIN `research_docs` | PK + FK indexes |
| Filter by topic | `project_content` | GIN on `topics` (add if needed) |
| Project + telemetry | `project_content` JOIN `projects` ON `content_slug` | PK on both |
| Stream feed (all projects) | `project_stream` | `(date DESC)` |
| Published research | `research_docs` | `status` |

### Performance Notes

- Project list page is a single query on `project_content` (no joins needed for the card view).
- Project detail page does 5 parallel queries (one per table) rather than a single mega-join. Simpler, and Supabase handles parallel queries well.
- JSONB containment queries (`topics @> '["redis"]'`) are fast enough at LO's scale (~10-50 projects). Add a GIN index on `topics` if it becomes a bottleneck.
- `synced_at` enables HTTP `If-Modified-Since` caching and ISR revalidation.

---

## Creating a Valid `.lo/` Directory

To add your project to LO, create a `.lo/` directory at your repo root:

```bash
mkdir -p .lo/hypotheses .lo/stream .lo/research
```

Create `.lo/project.md`:

```markdown
---
title: "Your Project Name"
description: "One-sentence description of what this project does."
status: "explore"
classification: "public"
topics:
  - your-topic
  - another-topic
---

Your project brief goes here. What is this? Why does it exist?
What problem does it solve? What's the current state?
```

That's the minimum. Add hypotheses, stream entries, and research docs as the project evolves. The webhook will sync everything to the website automatically.
