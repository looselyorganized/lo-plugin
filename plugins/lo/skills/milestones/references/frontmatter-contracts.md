# Stream Entry Frontmatter Contract

> From the .lo/ Convention Spec v0.1.0

Stream entries are chronological records in `.lo/stream/`. Filename convention: `YYYY-MM-DD-{slug}.md`.

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | enum | `milestone` \| `update` \| `note` |
| `date` | date | Must match filename prefix (YYYY-MM-DD) |
| `title` | string | Short descriptive title |

## Type Semantics

- `milestone` — Significant achievement or deliverable
- `update` — Progress report, status change, design decision
- `note` — Informal observation, thought, or reference

## Validation Rules

- `type` must be one of: `milestone`, `update`, `note`
- `date` must be a valid YYYY-MM-DD date
- `date` in frontmatter must match the date prefix in the filename
- `title` should be concise (under 80 characters)
- Body text: 1-3 sentences, terse and factual

## Example

```yaml
---
type: "milestone"
date: "2026-02-15"
title: "Prototype deployed to Railway"
---

First working deployment. API responds to health checks, WebSocket connections establish successfully. No persistence layer yet — all state is in-memory.
```

## Slug Rules

- Derived from title, kebab-case
- 2-5 words
- If a slug already exists for that date, append a distinguishing word
- Examples: `initial-commit`, `cli-setup-wizard`, `auth-system-complete`
