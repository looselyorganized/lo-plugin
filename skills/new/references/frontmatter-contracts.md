# LO Frontmatter Contracts

> From the .lo/ Convention Spec v2.0.0
> Updated 2026-02-23 — lifecycle phases changed to explore/build/open/closed.

All `.lo/` files use Markdown with YAML frontmatter (parsed by gray-matter). No MDX — content is plain Markdown.

---

## project.md — Project Brief & Metadata

The root file. One per project. Contains all metadata and the project brief.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Project title, e.g. `"Project: Nexus"` |
| `description` | string | One-sentence description |
| `status` | enum | `explore` \| `build` \| `open` \| `closed` |
| `classification` | enum | `public-open` \| `public-closed` \| `classified` |
| `topics` | string[] | Non-empty array for filtering/discovery |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `repo` | string | GitHub repo URL |
| `stack` | string[] | Code-level technologies (languages, frameworks, libraries) |
| `infrastructure` | string[] | Deployment/service layer (Supabase, Railway, Vercel, AWS, etc.) |
| `agents` | object[] | AI coding agents used on this project (each needs `name` and `role`) |

### Validation Rules

- `status` must be one of: `explore`, `build`, `open`, `closed`
- `classification` must be one of: `public-open`, `public-closed`, `classified`
- `topics` must be a non-empty array of strings
- `agents[].name` and `agents[].role` are required if `agents` is present
- `stack` and `infrastructure` are distinct: stack = code (Bun, React, Hono), infrastructure = services (Supabase, Railway, Docker)

### Status Semantics

| Status | Meaning | Visibility |
|-------|---------|------------|
| `explore` | Poking at an idea. Conversations, research, references. Nothing built yet. | Just you |
| `build` | Committed to making something. Code, demo, or prototype exists. | Shareable |
| `open` | Inviting people in. Public, accepting feedback, telemetry running. | Public |
| `closed` | Stopped working on it. Record stays up as history. | Still visible, no longer active |

### Body Sections

The project page parses the body by `## ` headings. Three headings get special rendering:

| Heading | Rendering | Body format |
|---------|-----------|-------------|
| `## Capabilities` | Grid of capability cards | Bullet list: `- **Title** — description` (one per line) |
| `## Architecture` | Prose block alongside the `stack` array | Free-form Markdown |
| `## Why This Matters` | Prose block | Free-form Markdown |

Any other `## ` headings render as generic prose sections. All sections are optional.

### Example

```yaml
---
title: "Project: Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"
classification: "public-open"
repo: "https://github.com/mhofwell/nexus-2"
stack:
  - Bun
  - Hono
  - Redis
infrastructure:
  - Railway
  - Supabase
topics:
  - distributed-systems
  - agent-coordination
agents:
  - name: "claude-code"
    role: "AI coding agent (Claude Code)"
---

Nexus is a coordination server that gives multi-agent engineering teams shared state, mutual exclusion, and structured communication. It replaces ad-hoc file locking with a purpose-built protocol.

## Capabilities

- **Distributed Locking** — File-level mutual exclusion via Redis with TTL-based expiration
- **Agent Registry** — Tracks active agents, their capabilities, and current assignments
- **Task Routing** — Assigns work items to agents based on availability and skill match
- **Event Streaming** — Real-time WebSocket feed of coordination events for observability

## Architecture

The server runs on Hono with Redis as the state backend. Agents connect via WebSocket for real-time events and use REST endpoints for lock acquisition and task management. All state is ephemeral — Redis TTLs handle cleanup when agents crash or disconnect.

## Why This Matters

Current multi-agent setups have no coordination layer. Agents overwrite each other's work, duplicate effort, and have no way to signal intent. Nexus provides the missing infrastructure — like a database server, but for agent collaboration.
```

---

## hypotheses/*.md — Hypothesis Files

One file per hypothesis. Filename convention: `h{NNN}-{slug}.md` (e.g., `h001-redis-locking.md`).

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique within project, matches filename prefix, e.g. `"h001"` |
| `statement` | string | The hypothesis being tested |
| `status` | enum | `proposed` \| `testing` \| `validated` \| `invalidated` \| `revised` |
| `date` | date | Date of last status change (YYYY-MM-DD) |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `revisesId` | string | Links to a prior hypothesis this revises |

### Status Transitions

```
proposed → testing → validated
                   → invalidated
                   → revised (creates new hypothesis with revisesId pointing back)
```

### Example

```yaml
---
id: "h001"
statement: "Redis distributed locks with TTL expiration are sufficient for file-level mutual exclusion in multi-agent systems"
status: "validated"
date: "2026-02-15"
---

## Evidence

Load testing with 8 concurrent agents showed zero lock collisions over 10,000 operations.

## Notes

TTL of 30s proved optimal — long enough for file operations, short enough to recover from agent crashes.
```

---

## stream/*.md — Project Stream Entries

Chronological log. Filename convention: `YYYY-MM-DD-{slug}.md`.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum | `update` \| `milestone` \| `note` |
| `date` | date | Must match filename prefix (YYYY-MM-DD) |
| `title` | string | Short title for the entry |

### Type Semantics

- `milestone` — Significant achievement or deliverable
- `update` — Progress report, status change, design decision
- `note` — Informal observation, thought, or reference

### Example

```yaml
---
type: "milestone"
date: "2026-02-15"
title: "Prototype deployed to Railway"
---

First working deployment. API responds to health checks, WebSocket connections establish successfully. No persistence layer yet — all state is in-memory.
```

---

## research/*.md — Research Documents

Project-specific research. Filename convention: `{slug}.md`.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Article title |
| `date` | date | Creation or last update date (YYYY-MM-DD) |
| `topics` | string[] | Topic tags |
| `status` | enum | `draft` \| `review` \| `published` |

### Status Semantics

| Status | Meaning | Visibility |
|--------|---------|------------|
| `draft` | Work in progress | Project detail page only |
| `review` | Ready for feedback | May appear in project page "research" section |
| `published` | Finalized | Visible on the project page as a complete research article |

Research articles live inside their parent project. There is no standalone `/research` route — all research is accessed through the project it belongs to.

### Example

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
status: "draft"
---

Full research content in Markdown goes here.
```

---

## notes/ — Informal Notes

Notes are informal scratch files that get turned into hypotheses or research docs. They have **no required frontmatter contract** — they are not synced to Supabase. Use whatever format is useful.

Notes are the staging area for ideas that haven't been formalized yet.
