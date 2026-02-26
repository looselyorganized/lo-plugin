# Research Document Frontmatter Contract

> From the .lo/ Convention Spec v2.0.0
> Updated 2026-02-23 — research articles are project-scoped, no standalone /research route.

## Filename Convention

`{slug}.md` — e.g., `distributed-locking.md`

- Kebab-case
- Descriptive (2-6 words)
- No date prefix (unlike stream entries)

## Required Fields

```yaml
---
title: "Article Title"           # Descriptive, specific
date: "2026-02-19"              # Creation or last update (YYYY-MM-DD)
topics:                          # 2-5 topic tags
  - topic-one
  - topic-two
status: "draft"                  # draft | review | published
---
```

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Descriptive article title |
| `date` | date | Creation or last significant update (YYYY-MM-DD) |
| `topics` | string[] | Topic tags for categorization |
| `status` | enum | `draft` \| `review` \| `published` |

## Status Semantics

| Status | Meaning | Visibility |
|--------|---------|------------|
| `draft` | Work in progress | Project detail page only |
| `review` | Ready for feedback | May appear in project page "research" section |
| `published` | Finalized | Visible on the project page as a complete research article |

## Status Transitions

```
draft → review → published
draft → published (skip review if confident)
published → draft (pull back for revisions)
```

## Where Research Lives

Research articles are project-scoped. They live in `.lo/research/` within their parent project's repo and are accessed through the project's detail page on the website. There is no standalone `/research` route.

When synced to Supabase via the webhook pipeline, research docs land in the `research_docs` table with a foreign key (`content_slug`) linking them to their parent project.
