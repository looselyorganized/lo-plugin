---
name: publish
description: Publishes research articles to the platform website. Takes raw material from a project's .lo/research/ directory (or a description), transforms it into a polished MDX article, and opens a PR on the platform repo. Use when user says "publish research", "write article", "publish to platform", or "/lo:publish". Must be run from the platform repo.
metadata:
  version: 0.3.0
  author: LORF
---

# LO Publish

Transforms raw research material into a published article on the platform. Creates a branch, writes the MDX, opens a PR.

## Invocation

```
/lo:publish <project> [slug1 slug2 ...]
/lo:publish <project> "description of what to write about"
```

Examples:
```
/lo:publish nexus distributed-locking
/lo:publish nexus distributed-locking institutional-memory
/lo:publish cr-agent "how the code review agent architecture evolved"
```

## When Called Without Args

If someone runs `/lo:publish` or `/lo:research` with no args:
```
Usage: /lo:publish <project> [slugs or description]

This skill publishes articles to the platform from raw .lo/research/ material.
Run it from the platform repo.

Example: /lo:publish nexus distributed-locking
```

## Critical Rules

- **Must be run from the platform repo.** Check for `content/research/` directory.
- Source material comes from sibling project repos (`../<project>/.lo/research/`).
- Output is a single `.mdx` file in `content/research/YYYY-MM-DD-{slug}.mdx`.
- Multiple source files get combined into one article, not multiple.
- The skill rewrites and improves the source material — it does NOT just copy it.
- Max reading time: 10 minutes (~2000 words). If the material is larger, tighten it.

## Workflow

### Step 1: Verify Platform Context

Check that `content/research/` exists in the current directory.

If not:
```
/lo:publish must be run from the platform repo.
```
Stop.

### Step 2: Resolve Source Material

**If slugs provided:** Read `../<project>/.lo/research/<slug>.md` for each slug.

**If description provided:** Scan `../<project>/.lo/research/*.md`, read all files, identify which ones are relevant to the description. Confirm selection with user.

**If no slugs or description:** List available research files and let user pick:
```
Research files in <project>/.lo/research/:
  1. distributed-locking.md — "Distributed Locking Findings"
  2. redis-findings.md — "Redis TTL Observations"
  3. agent-coordination.md — "Agent Coordination Patterns" (published -> agent-coordination-deep-dive)

Which files? (e.g., 1,2 or all)
```

Files with `published_as` in frontmatter are marked but still selectable.

**If project not found as sibling:** List available projects:
```
No project "<name>" found. Available:
  nexus (../nexus/.lo/research/ — 2 files)
  cr-agent (../cr-agent/.lo/research/ — 2 files)
```

### Step 3: Article Metadata

Ask the user for:
1. **Title** — specific and descriptive (see Editorial Prompt for guidance)
2. **Description** — 1-2 sentence excerpt for metadata/SEO

Auto-derive:
- **Topics** — union of source files' topics, let user adjust
- **Slug** — from title, kebab-case
- **Reading time** — estimate from final word count, format as "N min read"
- **Project** — from the project arg
- **Author** — read from `../<project>/.lo/PROJECT.md` agents field, or ask

### Step 4: Create Branch

```bash
git checkout -b research/{slug}
```

### Step 5: Write the Article

Read `references/design-systems-for-agents.mdx` and `references/distributed-locking-for-agents.mdx` as style references. Then transform the source material into a polished article following the Editorial Prompt below.

Write to `content/research/YYYY-MM-DD-{slug}.mdx`:

```yaml
---
title: "[title]"
date: "YYYY-MM-DD"
description: "[description]"
topics: [topic-1, topic-2]
status: "draft"
project: "[project-name]"
author: "[author]"
readingTime: "[N min read]"
---
```

Create image directory:
```bash
mkdir -p public/research/{slug}/
```

### Step 6: Update Source Files

In the sibling project repo, add `published_as: "{slug}"` to each source file's frontmatter. Do NOT commit in the project repo — let the user decide when.

### Step 7: Commit and PR

```bash
git add content/research/YYYY-MM-DD-{slug}.mdx public/research/{slug}/
git commit -m "draft: {title}"
git push -u origin research/{slug}
gh pr create --title "Research: {title}" --body "$(cat <<'EOF'
## Summary
- New research article from {project} .lo/research/ material
- Source files: {list of slugs}
- Status: draft (update to published when ready to go live)

## Checklist
- [ ] Review prose and narrative arc
- [ ] Add images to public/research/{slug}/
- [ ] Replace <!-- IMAGE: ... --> placeholders with actual image tags
- [ ] Update status to "published" in frontmatter
EOF
)"
```

### Step 8: Report

```
Article drafted and PR opened.

  File: content/research/YYYY-MM-DD-{slug}.mdx
  Branch: research/{slug}
  PR: [URL]
  Image dir: public/research/{slug}/
  Sources: N files from <project>/.lo/research/

Next steps:
  - Review the PR
  - Add images to public/research/{slug}/
  - Update status to "published" when ready
  - Merge to go live
```

---

## Editorial Prompt

This is the core transformation engine. When writing the article, follow these instructions exactly.

### Identity

You are transforming raw research notes into a published article for the Loosely Organized Research Facility. The source material is raw — treat it as input, not as a template to copy. Your job is to find the story in the material and tell it well.

### Voice

Write as a builder showing their work to other builders. First person plural ("we"). Direct, declarative, technically precise.

Not academic — no abstracts, no "this paper presents," no hedging ("it seems," "perhaps," "it could be argued"). Not marketing — no superlatives, no calls to action, no "revolutionary" or "game-changing."

Lab notebook energy: here's what we tried, here's what happened, here's what it means.

Lead every section with the point, not the preamble. If a paragraph starts with context or throat-clearing, delete it and start with the sentence that matters.

### Narrative Structure

Every article tells the story of building something. Follow this arc:

1. **OPENING HOOK** (1-2 paragraphs) — State the core problem or insight. Start with something universally recognizable, then narrow to the specific. No "In this article, we will discuss..." The reader should know what this is about and why it matters within 3 sentences.

2. **CONTEXT** — What existed before. What reference points you started from. What constraints shaped the approach. Keep this tight — only what the reader needs to understand the iteration that follows.

3. **THE ITERATION LOOP** — This is the core of every LO article. Show attempts, failures, and refinements. Use explicit markers: "Attempt 1:", "The first version:", "This broke because:". Each iteration should show what was tried, what happened, and what was learned. The failures are as valuable as the successes. Don't skip to the answer.

4. **WHAT WE LEARNED** — Distilled insights as bold-lead paragraphs:
   > **Agents are more cooperative than processes.** Traditional distributed locking assumes adversarial actors...

   Each lesson gets one paragraph. The bold opener is the takeaway; the body is the evidence.

5. **IMPLICATIONS** — What this means beyond this project. What changes because of this work. What patterns generalize.

6. **CLOSING** — Tie back to the opening. End with a pithy sentence or two, not a summary. "The LORF Bots are loosely organized. The system that produces them is not."

### Concrete Over Abstract

Use specific numbers, real code, actual component names. "30-second TTL with heartbeat renewal every 10 seconds" not "a configurable timeout." "Fifteen prototypes across six layout paradigms" not "many iterations."

Show code when it clarifies. Keep snippets short (5-15 lines). Annotate only when the code isn't self-explanatory.

### Heading Rhythm

Use `##` for major sections (5-8 per article). `###` sparingly for subsections within complex iteration sequences.

Headings must be specific and descriptive:
- GOOD: "Redis-Backed File Claims", "From Iteration to Character Bible", "The Braille Spinner"
- BAD: "Background", "Discussion", "Results", "Implementation Details"

### Paragraph Rhythm

Mix paragraph lengths. 2-5 sentences for explanatory paragraphs. 1-2 sentences for emphasis or transitions. Break walls of text with code blocks, lists, or image placeholders. A paragraph longer than 5 sentences should probably be split.

### Image Placeholders

Place `<!-- IMAGE: [description] -->` where visuals would strengthen the narrative:
- After describing something visual, show it
- After each iteration attempt, show the result
- Before/after comparisons
- One per major section is a good baseline
- Don't cluster images — space them between prose

### What NOT To Do

- Don't start with "In this article" or "This research explores"
- Don't use hedging language: "it seems", "perhaps", "it could be argued"
- Don't write a conclusion that restates the article
- Don't pad sections — every sentence carries information
- Don't use generic transitions: "Now let's look at", "Moving on to"
- Don't write marketing copy or hype
- Don't use academic citation style — link inline if referencing external work

### Length

Target 1200-2000 words. Reading time under 10 minutes. If you're over 2000 words, you're either not being concise enough or trying to cover too much in one article. Split it.

---

## References

Before writing, read both reference articles for the canonical LO editorial style:
- `references/design-systems-for-agents.mdx` — narrative-heavy, iteration-focused, image-rich
- `references/distributed-locking-for-agents.mdx` — technical, code-heavy, systems-focused

These show two ends of the LO style spectrum. Match the tone to the material.
