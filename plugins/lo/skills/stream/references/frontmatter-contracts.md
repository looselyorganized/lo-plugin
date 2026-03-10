# Stream Entry Frontmatter Contract

> From the .lo/ Convention Spec v0.1.0

Stream entries are milestone records in `.lo/stream/`. Filename convention: `YYYY-MM-DD-{slug}.md`.

## Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `date` | yes | date | Must match filename prefix (YYYY-MM-DD) |
| `title` | yes | string | Short descriptive title (under 80 chars) |
| `version` | no | string | Semver version if this milestone is a release |
| `feature_id` | no | string | `f{NNN}` if tied to a backlog feature |
| `commits` | no | number | Count of commits this milestone groups |
| `research` | no | list | Slugs of related research articles |

## Validation Rules

- `date` must be a valid YYYY-MM-DD date
- `date` in frontmatter must match the date prefix in the filename
- `title` should be concise (under 80 characters)
- `version` must be valid semver (e.g. `0.4.0`) — omit for Explore projects
- Body text: 1-3 sentences, public-facing voice
- Every entry must pass the quality gate: "would you post this?"

## Example

```yaml
---
date: "2026-03-09"
title: "Unified ship and plugin redesign"
version: "0.4.0"
feature_id: "f006"
commits: 15
---

One ship command, three modes — Explore pushes to main, Build pushes the branch,
release branches get the full pipeline. Replaced 9 gates with 6 and moved code
review to a dedicated subagent.
```

## Slug Rules

- Derived from title, kebab-case
- 2-5 words
- If a slug already exists for that date, append a distinguishing word
- Examples: `first-prototype`, `github-automation`, `unified-ship-redesign`
