---
name: stream
description: Creates milestone entries in .lo/stream/ — the public-facing narrative of a project. Each entry marks a significant event worth showing on the project page or posting to socials. Not a git log summary — a curated editorial timeline. Use when user says "update stream", "add milestone", "log progress", or "/lo:stream". Also invoked by /lo:ship during release mode.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
---

# LO Stream

The stream is the **public face of the project** — what appears on looselyorganized.org and feeds social posts. Every entry is a milestone: something worth showing a visitor.

## The Quality Gate

**Would you post this?** If you wouldn't put it on the project page or tweet it, it's not a stream entry. Git history already captures the small stuff.

## When to Use

- User invokes `/lo:stream`
- User says "update stream", "add milestone", "log progress"
- Invoked by `/lo:ship` during release mode (with context passed)
- Significant work has shipped and the stream hasn't been updated

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- ALWAYS read existing stream entries before generating new ones — never create duplicates.
- Filename convention: `YYYY-MM-DD-{slug}.md` — date must match frontmatter `date` field.
- Multiple entries on the same date are fine — use distinct slugs.
- Body text is 1-3 sentences. Public voice — concrete, editorial, no filler.
- All files are plain Markdown with YAML frontmatter. No MDX.

## Frontmatter

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `date` | yes | date | YYYY-MM-DD, must match filename prefix |
| `title` | yes | string | Short descriptive title (under 80 chars) |
| `version` | no | string | Semver if this milestone is a release (Build/Open projects only) |
| `feature_id` | no | string | `f{NNN}` if tied to a specific backlog feature |
| `commits` | no | number | Count of commits this milestone groups |
| `research` | no | list | Slugs of related research articles |

### Examples

```yaml
# Explore project — no version
---
date: "2026-03-09"
title: "First working prototype"
---

# Build project — feature milestone
---
date: "2026-03-07"
title: "GitHub automation"
feature_id: "f003"
commits: 26
---

# Build project — release milestone
---
date: "2026-03-09"
title: "Unified ship and plugin redesign"
version: "0.4.0"
feature_id: "f006"
commits: 15
---

# With linked research
---
date: "2026-03-04"
title: "Research becomes publishing"
version: "0.3.1"
research: ["capabilities-analysis"]
---
```

## Workflow

### Step 1: Verify .lo/ Exists

Check that `.lo/stream/` exists. If not:
```
No .lo/ directory found. Run /lo:new first to set up the project structure.
```
Stop here.

### Step 2: Read Existing Stream

Read every file in `.lo/stream/` and build an index of what's already recorded:
- Parse each file's frontmatter (`date`, `title`, `version`, `feature_id`, `commits`)
- Note the **most recent entry date** — this is the "last known" point

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

### Step 4: Identify Milestones

This is the editorial step. Only surface events that pass the quality gate.

**What qualifies as a milestone:**
- A version release (always)
- A major feature landing that changes how the project works
- A research article published
- A significant architectural decision or pivot

**What does NOT qualify:**
- Routine fixes, config changes, dependency updates
- Internal housekeeping (backlog cleanup, CI tweaks)
- Incremental improvements that don't change the user experience
- Anything you wouldn't mention on the project page

**For each candidate milestone:**
- Draft a title and 1-3 sentence body
- Count the commits it groups (if applicable)
- Identify version, feature_id, research links (if applicable)

**Present candidates:**

```
Found N milestones since last stream update:

1. YYYY-MM-DD — "Title here" (version: 0.4.0, 15 commits)
   Body preview...

2. YYYY-MM-DD — "Title here" (f003, 26 commits)
   Body preview...

Skip any? Edit any? Or write all?
```

Wait for user confirmation. The user can:
- Approve all
- Skip entries
- Edit titles or bodies
- Adjust what qualifies

### Step 5: Write Files

For each approved entry, write to `.lo/stream/YYYY-MM-DD-{slug}.md`.

Slug rules:
- Derive from title, kebab-case
- 2-5 words
- If a slug already exists for that date, add a distinguishing word

### Step 6: Confirm

```
Stream updated: N new milestones written.

  YYYY-MM-DD-slug.md — "Title" (version: X.Y.Z, N commits)
  YYYY-MM-DD-slug.md — "Title" (f003, N commits)

Stream now has TOTAL entries.
```

## Writing Style

Stream entries are public-facing, not internal logs:
- Lead with what was built and why it matters
- Include concrete details: component names, counts, key decisions
- Don't repeat what's obvious from the title
- No filler ("In this update we...", "This milestone represents...")
- Write for someone discovering the project, not for yourself

**Good:**
```
One ship command, three modes — Explore pushes to main, Build pushes the branch,
release branches get the full pipeline. Replaced 9 gates with 6 and moved code
review to a dedicated subagent.
```

**Bad:**
```
In this milestone, we made significant progress on the shipping experience by
implementing various improvements and consolidating commands.
```

## Invoked by Ship (Release Mode)

When `/lo:ship` invokes the stream during release mode, it passes context:
- Version number
- Feature names and IDs from the release
- Commit count
- Work artifact summaries (plans, key decisions) — captured before cleanup

Use this context to draft the entry. Still present for user review before writing.

## Manual Entry Mode

If the user wants to add a specific milestone (not scan git), ask:
1. What happened?
2. When? (default: today)
3. Version? (if applicable)
4. Related feature or research?

Generate a single entry from their answers.
