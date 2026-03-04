# Research Document Frontmatter Contract

> From the .lo/ Convention Spec
> Updated 2026-03-04 — research files are raw materials captured during deep work. Publishing happens in the platform repo.

## Filename Convention

`{slug}.md` — e.g., `distributed-locking.md`

- Kebab-case
- Descriptive (2-6 words)
- No date prefix (unlike stream entries)

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Descriptive title for the findings |
| `date` | date | Creation or last update (YYYY-MM-DD) |
| `topics` | string[] | 2-5 topic tags for categorization |

## Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `published_as` | string | Slug of the platform MDX article this was published into. Set by `/lo:research pub`. |

## Example

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
---
```

## Example (after publishing)

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
published_as: "distributed-locking-for-agents"
---
```

## Where Research Lives

Research files are raw materials — findings, observations, and analysis captured during deep work sessions. They live in `.lo/research/` within their parent project's repo.

To publish research as an article on the platform, use `/lo:research pub` from the platform repo. This combines one or more research files into an MDX article.
