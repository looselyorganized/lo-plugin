# Stream Entry Format Contract

> From the .lo/ Convention Spec v0.4.1

Stream entries live in a single `.lo/STREAM.md` file. The file has YAML frontmatter (`type: stream`), then entries using XML tags, newest first.

See `references/stream-format.md` for the full format specification including parsing algorithm and quality gate.

## Entry Structure

```markdown
<entry>
date: 2026-03-10
title: "Entry title here"
version: "0.4.1"
<description>
1-3 sentences. Public voice — concrete, editorial, no filler.
</description>
</entry>
```

## Fields

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `date` | yes | YYYY-MM-DD | Unquoted |
| `title` | yes | string | Quoted, under 80 chars |
| `version` | no | semver | Quoted, only for releases |
| `research` | no | string | Quoted, comma-separated slugs |

## Validation

- Entries must be in reverse chronological order (newest first)
- Every entry must pass the quality gate: "would you post this?"
- Body text: 1-3 sentences, public-facing voice
- `version` must be valid semver — omit for Explore projects and non-release milestones
