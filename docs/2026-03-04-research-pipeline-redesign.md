# Research Pipeline Redesign

> 2026-03-04

## Problem

The research pipeline has two disconnected systems: `.lo/research/` files synced to Supabase via webhook, and MDX files in the platform repo served at `/research/[slug]`. Published research cards on project pages link to `/research/[slug]`, but that route reads from MDX — not Supabase. The link breaks unless the article exists in both places. There's no bridge between them.

Additionally, `.lo/research/` has a `draft → review → published` status lifecycle that nothing enforces or automates. The `review` status is defined but unused. The webhook syncs all statuses indiscriminately.

## Design

### Simplified `.lo/research/`

`.lo/research/` becomes a raw materials library — findings captured during deep work sessions. No publishing lifecycle.

**Frontmatter (before):**
```yaml
title: "..."
date: "YYYY-MM-DD"
topics: [...]
status: "draft"  # draft | review | published
```

**Frontmatter (after):**
```yaml
title: "..."
date: "YYYY-MM-DD"
topics: [...]
published_as: "slug"  # optional, set by pub skill
```

`status` removed. `published_as` added — links to the platform MDX article slug when the file has been used to compose an article.

### `/lo:research pub` skill

New mode on the existing `/lo:research` skill. Runs from the platform repo, reads research files from a sibling project directory.

**Invocation:**
```
/lo:research pub <project-name> [slug1 slug2 ...]
```

**Flow:**

1. **Resolve project** — scan `../` for a directory with `.lo/PROJECT.md` whose title or directory name matches `<project-name>`.
2. **List research files** — read `.lo/research/*.md` from that project, parse frontmatter, show list. Files with `published_as` are marked `(published → slug)` but still selectable.
3. **User selects files** — pick which to combine (or pass slugs as args to skip this step).
4. **Article metadata** — ask for title, description. Pre-populate topics from source files. Derive slug from title.
5. **Combine and draft** — merge selected files into MDX editorial structure (hook → context → iteration → lessons → implications). Add `<!-- IMAGE: ... -->` placeholders.
6. **Create branch and write:**
   - `git checkout -b research/{slug}` in the platform repo
   - Write `content/research/YYYY-MM-DD-{slug}.mdx` with frontmatter: `title`, `date`, `description`, `topics`, `status: "draft"`, `project`, `author`, `readingTime`
   - Create `public/research/{slug}/` directory for images
   - Commit the draft
7. **Update source files** — add `published_as: "{slug}"` to each source file's frontmatter in the project repo.
8. **Report:**
   ```
   Article drafted: content/research/YYYY-MM-DD-{slug}.mdx
   Image dir ready: public/research/{slug}/
   Sources updated: N files marked with published_as

   Next steps:
     - Add images to public/research/{slug}/
     - Polish the MDX, add any demo components
     - Commit and push when ready
   ```

### Webhook changes (claude-dashboard/webhook)

Remove research parsing and `research_docs` sync from the webhook. The webhook continues to sync: PROJECT.md, hypotheses, stream entries, contributors.

### Supabase changes

Drop or deprecate the `research_docs` table.

### Platform changes (platform repo)

Repurpose `<ResearchList>` on project pages to query published MDX articles by `project` frontmatter field instead of querying `research_docs` from Supabase. The MDX content system already loads all articles with their frontmatter — filter where `project` matches.

Remove Supabase `research_docs` queries from `src/lib/project-content.ts`.

## Scope by repo

| Repo | Changes |
|------|---------|
| **lo-plugin** | Simplify research frontmatter, add `pub` mode to `/lo:research`, update lo-spec, update frontmatter contracts, fix dangling `notes/` reference |
| **claude-dashboard/webhook** | Remove research parsing and `research_docs` sync |
| **platform** | Repurpose `<ResearchList>` to query MDX by `project` field, remove `research_docs` Supabase queries |
