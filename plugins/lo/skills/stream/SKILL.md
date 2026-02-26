---
name: stream
description: Updates the .lo/stream/ folder with milestone and update entries by grouping commits under thematic arcs. The stream is a curated editorial layer on top of git — not a restatement of commit messages. Reads existing stream entries first to avoid duplicates. Use when user says "update stream", "add milestone", "catch up stream", "what happened since last stream update", "log progress", "update lo", "sync stream", or "/lo:stream". Also use proactively when significant work has been completed and the stream hasn't been updated recently.
metadata:
  version: 2.1.0
  author: LORF
  category: project-documentation
  tags: [lo, stream, milestones, changelog, project-history]
---

# LO Stream

Groups commits under thematic entries to keep `.lo/stream/` current. The stream is a **curated editorial layer on top of git** — entries are editorial decisions about what matters, not paraphrases of what happened. Git stays the source of truth for details; the stream provides the narrative arc.

## Core Principle

**Don't restate commits. Group them.** A milestone like "lo-open startup command" references the 12 commits that built it. Someone reading the stream gets the narrative without digging through git log. Each entry carries a `commits:` count linking it back to the underlying work.

## When to Use

- User invokes `/lo:stream`
- User says "update stream", "add milestone", "catch up stream", "log progress"
- Significant work has shipped and `.lo/stream/` hasn't been updated
- User wants to backfill stream entries from git history

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- ALWAYS read existing stream entries before generating new ones — never create duplicates.
- Filename convention: `YYYY-MM-DD-{slug}.md` — date must match frontmatter `date` field.
- Multiple entries on the same date are fine — use distinct slugs.
- Body text is terse and factual: 1-3 sentences. No filler, no marketing copy.
- All files are plain Markdown with YAML frontmatter. No MDX.
- Every entry MUST include `commits:` in frontmatter with the count of commits it groups.

## Workflow

### Step 1: Verify .lo/ Exists

Check that `.lo/stream/` exists. If not:
```
No .lo/ directory found. Run /lo:new first to set up the project structure.
```
Stop here.

### Step 2: Read Existing Stream

Read every file in `.lo/stream/` and build an index of what's already recorded:
- Parse each file's frontmatter (`type`, `date`, `title`, `commits`)
- Note the **most recent entry date** — this is the "last known" point in the timeline

Present a summary:
```
Stream has N entries, last updated YYYY-MM-DD ("title of most recent").
```

### Step 3: Scan Git History

Run git log since the last stream entry:

```bash
git log --after="YYYY-MM-DD" --pretty=format:"%H|%ad|%s" --date=short
```

Also check for tags:
```bash
git tag --sort=-creatordate --format="%(creatordate:short)|%(refname:short)|%(subject)"
```

### Step 4: Group Commits Into Themes

This is the editorial step. Cluster commits into logical units of work:

**What makes a good grouping:**
- A feature branch that got merged (all commits in the branch → one milestone)
- Related commits across a few days building toward one outcome
- A coherent theme: "exporter hardening", "auth system", "performance fixes"

**Grouping rules:**
- One entry per meaningful unit of work — not one per commit, not one giant summary
- Tags → always their own milestone entry
- Large features spanning multiple days → one milestone on the completion date
- Multiple unrelated themes on the same day → separate entries
- Routine commits (typo fixes, linting, deps) → fold into a nearby theme or skip
- If there are 20+ commits spanning weeks, aim for 3-6 entries that capture the major arcs
- Count the commits in each group — this becomes the `commits:` frontmatter value

**Present the groupings as a preview:**

```
Found N themes grouping M total commits:

1. [milestone] YYYY-MM-DD — "Title here" (12 commits)
   Body preview...

2. [update] YYYY-MM-DD — "Title here" (3 commits)
   Body preview...

Skip any? Edit any? Or write all?
```

Wait for user confirmation. The user can:
- Approve all
- Skip specific entries
- Edit titles or bodies
- Change entry types (milestone ↔ update ↔ note)
- Adjust groupings (split or merge themes)

### Step 5: Write Files

For each approved entry, write to `.lo/stream/YYYY-MM-DD-{slug}.md`:

```markdown
---
type: "[milestone|update|note]"
date: "YYYY-MM-DD"
title: "[Short descriptive title]"
commits: N
---

[1-3 terse sentences. What was built, why it matters. Concrete details — component names, key decisions, numbers.]
```

Slug rules:
- Derive from the title, kebab-case
- 2-5 words
- If a slug already exists for that date, add a distinguishing word

### Step 6: Confirm

```
Stream updated: N new entries written, grouping M commits.

  YYYY-MM-DD-slug.md — "Title" (type, N commits)
  YYYY-MM-DD-slug.md — "Title" (type, N commits)

Stream now has TOTAL entries, covering EARLIEST_DATE to LATEST_DATE.
```

## Entry Type Guide

| Type | When to use | Examples |
|------|------------|---------|
| `milestone` | Significant deliverable or feature landing | "lo-open startup command", "Supabase exporter launched", "Auth system complete" |
| `update` | Incremental improvement, hardening, config change | "Exporter hardening and type safety", "Performance fixes", "Dependency upgrades" |
| `note` | Observation, investigation, or decision worth recording | "Evaluated Redis vs Memcached", "Noticed latency spike under load" |

When grouping commits:
- A feature branch merging → `milestone`
- A cluster of fixes and improvements → `update`
- A revert or investigation → `note`
- Routine chores → fold into a nearby entry or skip

## Writing Style

Stream entries are editorial, not mechanical:
- Lead with what was built, not how
- Include concrete details: component names, counts, key decisions
- Don't repeat what's obvious from the title
- No filler ("In this update we...", "This milestone represents...")

**Good:**
```
Replaced the naive facility switch with a comprehensive startup command running 8 sequential preflight checks. Self-heals launchd and exporter if needed. Matching lo-close performs graceful shutdown.
```

**Bad:**
```
In this milestone, we made significant progress on the facility management experience by implementing new open and close commands with various checks and improvements.
```

## Manual Entry Mode

If the user wants to add a specific entry (not scan git), ask:
1. What happened?
2. When? (default: today)
3. Type: `milestone`, `update`, or `note`?
4. How many commits does this cover? (can be 0 for non-code milestones)

Generate a single entry from their answers.
