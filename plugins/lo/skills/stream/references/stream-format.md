# STREAM.md Format Specification

> XML-structured markdown for parseable project milestones.

## File Structure

```markdown
---
type: stream
---

<entry>
date: 2026-03-10
title: "Stream redesign and skill hardening"
version: "0.4.1"
<description>
Stream consolidated into single STREAM.md with milestones-only quality gate.
</description>
</entry>

<entry>
date: 2026-03-09
title: "Unified ship and plugin redesign"
version: "0.4.0"
<description>
One ship command, three modes — Explore pushes to main, Build pushes the branch,
release branches get the full pipeline.
</description>
</entry>
```

## Rules

- File-level YAML frontmatter: `type: stream` (only field)
- Entries wrapped in `<entry>...</entry>`, newest first
- Metadata as `key: value` lines inside `<entry>` but outside `<description>`
- Body wrapped in `<description>...</description>`
- String values in `title` quoted, `date` unquoted
- No blank lines between metadata fields
- One blank line between `</entry>` closing tags is optional (readability)

## Metadata Fields

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `date` | yes | YYYY-MM-DD | Unquoted |
| `title` | yes | string | Quoted |
| `version` | no | semver | Quoted, only for releases |
| `research` | no | string | Quoted, comma-separated slugs |

- `version` — present only when the milestone is a release (Build/Open projects)
- `research` — present only when linking to published research articles

## Parsing Algorithm

```
1. Strip YAML frontmatter
2. Split content on <entry> tags
3. For each entry:
   a. Extract metadata: key-value lines before <description>
   b. Extract body: content inside <description>...</description>
   c. Strip </entry> closing tag
```

## What Qualifies as an Entry

Every entry must pass the quality gate: **would you post this?**

Qualifies:
- A version release (always)
- A major feature that changes how the project works
- A published research article
- A significant architectural decision or pivot

Does not qualify:
- Routine fixes, config changes, dependency updates
- Internal housekeeping
- Incremental improvements
- Anything you wouldn't put on the project page
