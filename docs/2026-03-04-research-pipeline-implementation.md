# Research Pipeline Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify `.lo/research/` to a raw materials library and add a `pub` mode to `/lo:research` that drafts MDX articles in the platform repo.

**Architecture:** Strip the publishing lifecycle from `.lo/research/` frontmatter, update all specs and contracts, build a new `pub` mode that reads research files from sibling project directories and creates MDX articles with proper frontmatter and image directories.

**Tech Stack:** Markdown, YAML frontmatter, git CLI, shell (for sibling directory resolution)

---

### Task 1: Simplify research frontmatter contract

**Files:**
- Modify: `plugins/lo/skills/research/references/frontmatter-contract.md`

**Step 1: Rewrite the frontmatter contract**

Replace the entire file with the simplified contract. Remove `status` field and all status-related sections. Add `published_as` optional field.

New content:

```markdown
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
```

**Step 2: Commit**

```bash
git add plugins/lo/skills/research/references/frontmatter-contract.md
git commit -m "refactor: simplify research frontmatter — remove status, add published_as"
```

---

### Task 2: Update master frontmatter contracts

**Files:**
- Modify: `plugins/lo/skills/new/references/frontmatter-contracts.md:186-224`

**Step 1: Replace the research section**

Replace lines 186-224 (the `## research/*.md` section) with:

```markdown
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
| `published_as` | string | Platform article slug (set by `/lo:research pub`) |

Research files are raw materials — findings captured during deep work. To publish as an article, use `/lo:research pub` from the platform repo.

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
```

**Step 2: Commit**

```bash
git add plugins/lo/skills/new/references/frontmatter-contracts.md
git commit -m "refactor: align master frontmatter contracts with simplified research"
```

---

### Task 3: Update `/lo:research` skill — simplify default mode

**Files:**
- Modify: `plugins/lo/skills/research/SKILL.md`

**Step 1: Update the skill**

Changes needed:
1. Line 3 (description): Remove "narrative prose" and "editorial headings" — this is about capturing findings, not publishing articles
2. Line 24: Remove "Research articles in `.lo/research/` are project-scoped. They are accessed through the parent project's page" — they're raw materials now
3. Line 25: Remove "Default status is `draft`. Only the user can promote to `review` or `published`."
4. Lines 142-152: Remove `status: "draft"` from the frontmatter template
5. Lines 161-179 (Step 6 confirm block): Remove status references, update next steps to mention `/lo:research pub`
6. Line 186: Update reference to simplified frontmatter contract

New description (line 3):
```
description: Captures research findings and discoveries in .lo/research/ during deep work sessions. Also publishes research to the platform via pub mode. Use when user says "write research", "create research article", "draft research", "capture findings", or "/lo:research". Use pub mode with "/lo:research pub <project>" to combine findings into a platform MDX article.
```

Remove line 24-25 and replace with:
```
- Research files in `.lo/research/` are raw materials — findings captured during deep work. Publishing to the platform is a separate step via `pub` mode.
```

Update frontmatter template (lines 142-152) — remove `status: "draft"` line.

Update Step 6 confirm block to:
```
Research captured: .lo/research/{slug}.md

  Title: [title]
  Topics: [topics]
  Sections: [count]
  Image placeholders: [count]

Next steps:
  - Continue capturing findings as you work
  - When ready to publish, run /lo:research pub from the platform repo
```

**Step 2: Commit**

```bash
git add plugins/lo/skills/research/SKILL.md
git commit -m "refactor: simplify /lo:research — raw materials, not publishing pipeline"
```

---

### Task 4: Add `pub` mode to `/lo:research` skill

**Files:**
- Modify: `plugins/lo/skills/research/SKILL.md`

**Step 1: Add pub mode section**

Insert a new `## Pub Mode` section after the existing `## Workflow` section (after Step 6). This is the cross-repo publish flow.

```markdown
## Pub Mode

Combines research files from a sibling project into a platform MDX article. **Must be run from the platform repo.**

### Invocation

```
/lo:research pub <project-name> [slug1 slug2 ...]
```

- With slugs: reads those specific files
- Without slugs: lists available research files, lets user pick

### Pub Step 1: Verify Platform Context

Check that you're in the platform repo:
- `content/research/` directory must exist
- `public/research/` directory must exist

If not found:
```
This command must be run from the platform repo.
/lo:research pub reads research files from sibling project directories
and creates MDX articles here.
```

### Pub Step 2: Resolve Project

Scan `../` for a directory with `.lo/PROJECT.md` whose title or directory name matches `<project-name>`.

If not found:
```
No project matching "<project-name>" found in sibling directories.
Available projects:
  nexus (../nexus/.lo/PROJECT.md)
  claude-dashboard (../claude-dashboard/.lo/PROJECT.md)
```

### Pub Step 3: List Research Files

Read all `.md` files in `<project>/.lo/research/`, parse frontmatter.

Display:
```
Research files in <project>/.lo/research/:
  1. distributed-locking.md — "Distributed Locking Findings"
  2. redis-findings.md — "Redis TTL Observations"
  3. agent-coordination.md — "Agent Coordination Patterns" (published → agent-coordination-deep-dive)

Which files to combine? (e.g., 1,2 or all)
```

Files with `published_as` in frontmatter are marked but still selectable.

If slugs were passed as args, skip this step and use those files directly.

### Pub Step 4: Article Metadata

Ask for:
1. **Title** — specific and descriptive
2. **Description** — 1-2 sentence excerpt for metadata

Pre-populate topics from the union of source files' topics. Let user adjust.

Derive slug from title (kebab-case). Derive `readingTime` from combined word count.

### Pub Step 5: Combine and Draft

Merge the selected files' content into a cohesive MDX article following the editorial style from `references/design-systems-for-agents.mdx`:

1. Opening hook — state the core insight
2. Context — what existed before, reference points
3. Iteration/discovery — the core narrative from the source files
4. What we learned — distilled insights
5. Implications — what changes because of this
6. What's next — open questions

Add `<!-- IMAGE: ... -->` placeholders where visuals would strengthen the narrative.

### Pub Step 6: Create Branch and Write

In the platform repo:

1. Create branch: `git checkout -b research/{slug}`
2. Write `content/research/YYYY-MM-DD-{slug}.mdx` with frontmatter:

```yaml
---
title: "[title]"
date: "YYYY-MM-DD"
description: "[description]"
topics:
  - [topics]
status: "draft"
project: "[project-name]"
author: "[from PROJECT.md or ask]"
readingTime: "[estimated]"
---
```

3. Create image directory: `mkdir -p public/research/{slug}/`
4. Commit the draft:

```bash
git add content/research/YYYY-MM-DD-{slug}.mdx public/research/{slug}/
git commit -m "draft: research article — {title}"
```

### Pub Step 7: Update Source Files

Go back to the project repo and add `published_as: "{slug}"` to each source file's frontmatter. Do not commit in the project repo — let the user decide when to commit that change.

### Pub Step 8: Report

```
Article drafted: content/research/YYYY-MM-DD-{slug}.mdx
Branch: research/{slug}
Image dir: public/research/{slug}/
Sources updated: N files marked with published_as in <project>/.lo/research/

Next steps:
  - Add images to public/research/{slug}/
  - Polish the MDX — add demo components if needed
  - Update status to "published" when ready
  - Push branch and merge to go live
```
```

**Step 2: Update the Modes section at the top of the skill**

Add pub mode to the detection logic. After the existing modes section, add:
```
- `/lo:research pub <project>` or `/lo:research pub <project> slug1 slug2` → pub mode (must be in platform repo)
```

**Step 3: Commit**

```bash
git add plugins/lo/skills/research/SKILL.md
git commit -m "feat: add pub mode to /lo:research for cross-repo MDX publishing"
```

---

### Task 5: Update lo-spec.md

**Files:**
- Modify: `docs/lo-spec.md:148-176` (research section)
- Modify: `docs/lo-spec.md:320-338` (research_docs table)
- Modify: `docs/lo-spec.md:385` (webhook research line)

**Step 1: Rewrite research section (lines 148-176)**

Replace with:

```markdown
### `research/*.md` — Research Files

Raw materials captured during deep work sessions. Findings, observations, and analysis that may later be combined into published articles on the platform.

**Filename convention:** `{slug}.md` (e.g., `distributed-locking.md`)

**Frontmatter contract:**

```yaml
---
title: "Distributed Locking for Multi-Agent Systems"
date: "2026-01-20"
topics:
  - distributed-systems
  - redis
published_as: "distributed-locking-for-agents"  # optional, set by /lo:research pub
---
```

**Body:** Free-form Markdown. Findings, code snippets, observations.

**Required fields:** `title`, `date`, `topics`
**Optional fields:** `published_as` (slug of the platform MDX article, set by `/lo:research pub`)

Publishing to the platform is handled by `/lo:research pub` from the platform repo, which combines one or more research files into an MDX article.
```

**Step 2: Remove `research_docs` table (lines 320-338)**

Delete the entire `### Table: research_docs` section.

**Step 3: Remove research from webhook flow (line 385)**

Delete the line:
```
   - research/*.md → upsert research_docs
```

**Step 4: Commit**

```bash
git add docs/lo-spec.md
git commit -m "docs: update lo-spec — research is raw materials, remove research_docs table"
```

---

### Task 6: Fix dangling `notes/` reference

**Files:**
- Modify: `.lo/research/from-brief-to-workflow.md:179-182`

**Step 1: Remove `notes/` from the directory tree**

Replace lines 179-182:
```markdown
├── research/           # Structured research articles
├── work/               # Active feature directories with plans
├── solutions/          # Reusable knowledge from completed work
└── notes/              # Scratch space
```

With:
```markdown
├── research/           # Raw materials from deep work sessions
├── work/               # Active feature directories with plans
└── solutions/          # Reusable knowledge from completed work
```

**Step 2: Update line 185 (webhook description)**

The text says "The website reads this directory — via GitHub webhooks into Supabase — and populates project pages automatically." This is still true for everything except research. No change needed — the statement is about `.lo/` generally, not research specifically.

**Step 3: Commit**

```bash
git add .lo/research/from-brief-to-workflow.md
git commit -m "fix: remove dangling notes/ reference from research article"
```

---

### Task 7: Push and verify

**Step 1: Push all commits**

```bash
git push
```

**Step 2: Verify the skill loads**

```bash
claude --plugin-dir ./plugins/lo -c "/lo:research"
```

Verify the skill loads without errors and shows the updated help text.
