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
| `id` | string | Auto-generated project identifier. Format: `proj_` + lowercase UUID v4. Never manually assign or reuse. |
| `title` | string | Project title, e.g. `"Project: Nexus"` |
| `description` | string | One-sentence description |
| `status` | enum | `explore` \| `build` \| `open` \| `closed` |
| `state` | enum | `public` \| `private` |
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
- `state` must be one of: `public`, `private`
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
id: "proj_166345da-d821-4b3a-abbc-e3a439925e85"
title: "Project: Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"
state: "public"
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

## research/*.md — Research Files

Raw materials captured during deep work. Filename convention: `{slug}.md`.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Descriptive title |
| `date` | date | Creation or last update date (YYYY-MM-DD) |
| `topics` | string[] | Topic tags |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `published_as` | string | Platform article slug (set by `/lo:publish`) |

Research files are raw materials — findings captured during deep work. To publish as an article, use `/lo:publish` from the platform repo.

### Example

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
---

Full research content in Markdown goes here.
```

---

