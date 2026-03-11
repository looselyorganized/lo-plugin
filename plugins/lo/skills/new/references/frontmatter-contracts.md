# LO Frontmatter Contracts

> From the .lo/ Convention Spec v3.0.0
> Updated 2026-03-11 — PROJECT.md replaced by project.yml (pure YAML, 5 required fields, no body).

---

## project.yml — Project Metadata

The root file. One per project. Pure YAML — no frontmatter delimiters, no markdown body.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated project identifier. Format: `proj_` + lowercase UUID v4. Never manually assign or reuse. Must be the first field. |
| `title` | string | Project title, e.g. `"Loosely Organized"` |
| `description` | string | One-sentence description |
| `status` | enum | `explore` \| `build` \| `open` \| `closed` |
| `state` | enum | `public` \| `private` |

### No Optional Fields

Fields previously in PROJECT.md have moved to canonical sources:

| Removed Field | New Home |
|--------------|----------|
| `repo` | `git remote -v` / GitHub API |
| `stack` | `package.json` (or ask user during `/lo:new`) |
| `infrastructure` | Ask user during `/lo:status` transitions |
| `agents` | Dropped — boilerplate, not displayed |
| Body sections | `CLAUDE.md` (architecture), `README.md` (public description) |

### Validation Rules

- `status` must be one of: `explore`, `build`, `open`, `closed`
- `state` must be one of: `public`, `private`
- `id` format: `proj_` + lowercase UUID v4

### Example

```yaml
id: "proj_166345da-d821-4b3a-abbc-e3a439925e85"
title: "Nexus"
description: "A coordination server for multi-agent engineering teams."
status: "build"
state: "public"
```

---

## STREAM.md — Project Stream

Single file containing all milestones, newest first. File has `type: stream` frontmatter, entries use XML tags for reliable parsing. See `plugins/lo/skills/stream/references/stream-format.md` for full spec.

### Entry Metadata Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `date` | yes | date | YYYY-MM-DD |
| `title` | yes | string | Short descriptive title (under 80 chars) |
| `version` | no | string | Semver if this is a release milestone |
| `research` | no | string | Comma-separated slugs of related research articles |

### Example

```markdown
---
type: stream
---

<entry>
date: 2026-02-15
title: "Prototype deployed to Railway"
version: "0.1.0"
research: "railway-deployment,bun-http-server"
<description>
First working deployment. API responds to health checks, WebSocket connections establish successfully.
</description>
</entry>
```

---

## research/*.md — Research Files

Raw materials captured during deep work. Filename convention: `{slug}.md`.

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Descriptive title |
| `date` | date | Creation or last update date (YYYY-MM-DD) |
| `topics` | string[] | Topic tags (used by platform for articles; not used in project.yml) |

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
