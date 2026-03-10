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

<critical>
Quality gate: would you post this? If you wouldn't put it on the project page or tweet it, it's not a stream entry. Git history already captures the small stuff.
Never create duplicate entries. Always read existing stream entries first.
</critical>

## When to Use

- User invokes `/lo:stream`
- User says "update stream", "add milestone", "log progress"
- Invoked by `/lo:ship` during release mode (with context passed)
- Significant work has shipped and the stream hasn't been updated

## Modes

Detect from context:
- **Scan mode** (default) — scan git history, identify milestones, write entries
- **Manual mode** — user wants to add a specific entry without scanning git
- **Ship mode** — invoked by `/lo:ship` with release context passed in conversation

Follow ONLY the section matching your mode.

## Frontmatter

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `date` | yes | date | YYYY-MM-DD, must match filename prefix |
| `title` | yes | string | Short descriptive title (under 80 chars) |
| `version` | no | string | Semver if this milestone is a release (Build/Open projects only) |
| `feature_id` | no | string | `f{NNN}` if tied to a specific backlog feature |
| `commits` | no | number | Count of commits this milestone groups |
| `research` | no | list | Slugs of related research articles |

---

<scan-mode>
## Scan Mode (default)

You are scanning git history to identify milestones.

### Progress Checklist

```
Stream Progress:
  - [ ] Step 1: Verify .lo/ exists
  - [ ] Step 2: Read existing stream
  - [ ] Step 3: Scan git history
  - [ ] Step 4: Identify milestones
  - [ ] Step 5: Write files
  - [ ] Step 6: Confirm
```

### Step 1: Verify .lo/ Exists

Check that `.lo/stream/` exists. If not:

```
No .lo/ directory found. Run /lo:new first to set up the project structure.
```

Stop here.

### Step 2: Read Existing Stream

Read every file in `.lo/stream/` and build an index:

- Parse each file's frontmatter (`date`, `title`, `version`, `feature_id`, `commits`)
- Note the **most recent entry date** — this is the "last known" point

```
Stream has N entries, last updated YYYY-MM-DD ("title of most recent").
```

### Step 3: Scan Git History

```bash
git log --after="YYYY-MM-DD" --pretty=format:"%H|%ad|%s" --date=short
```

```bash
git tag --sort=-creatordate --format="%(creatordate:short)|%(refname:short)|%(subject)"
```

If no commits found since the last entry:

```
No new commits since last stream entry (YYYY-MM-DD). Stream is up to date.
```

Stop here.

### Step 4: Identify Milestones

This is the editorial step. Only surface events that pass the quality gate.

**What qualifies:**
- A version release (always)
- A major feature landing that changes how the project works
- A research article published
- A significant architectural decision or pivot

**What does NOT qualify:**
- Routine fixes, config changes, dependency updates
- Internal housekeeping (backlog cleanup, CI tweaks)
- Incremental improvements that don't change the user experience
- Anything you wouldn't mention on the project page

For each candidate, draft a title and 1-3 sentence body. Count the commits it groups. Identify version, feature_id, research links if applicable.

Present candidates:

```
Found N milestones since last stream update:

1. YYYY-MM-DD — "Title here" (version: 0.4.0, 15 commits)
   Body preview...

2. YYYY-MM-DD — "Title here" (f003, 26 commits)
   Body preview...

Skip any? Edit any? Or write all?
```

**Wait for user confirmation.** The user can approve all, skip entries, edit titles/bodies, or adjust what qualifies.

### Step 5: Write Files

For each approved entry, write to `.lo/stream/YYYY-MM-DD-{slug}.md`:

```markdown
---
date: "YYYY-MM-DD"
title: "[Short descriptive title]"
version: "[semver]"
feature_id: "f{NNN}"
commits: N
---

[1-3 sentences. Public voice — concrete, editorial, no filler.]
```

Omit optional frontmatter fields that don't apply.

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

</scan-mode>

---

<manual-mode>
## Manual Mode

The user wants to add a specific milestone without scanning git.

Ask:
1. What happened?
2. When? (default: today)
3. Version? (if applicable)
4. Related feature or research?

Generate a single entry from their answers. Write the file using the same template as scan mode Step 5.

Present for confirmation before writing.

</manual-mode>

---

<ship-mode>
## Ship Mode (invoked by /lo:ship)

When `/lo:ship` invokes the stream during release mode, it passes context in the conversation:
- Version number
- Feature names and IDs from the release
- Commit count
- Work artifact summaries (plans, key decisions)

Use this context to draft the entry. Do NOT scan git history — the context is already provided.

1. Draft a title and 1-3 sentence body from the provided context
2. Present for user review before writing
3. Write using the same template as scan mode Step 5
4. Include `version` in frontmatter

</ship-mode>

---

## Writing Style

Stream entries are public-facing, not internal logs:
- Lead with what was built and why it matters
- Include concrete details: component names, counts, key decisions
- Don't repeat what's obvious from the title
- No filler ("In this update we...", "This milestone represents...")
- Write for someone discovering the project, not for yourself

<example name="good-entry">
```
One ship command, three modes — Explore pushes to main, Build pushes the branch,
release branches get the full pipeline. Replaced 9 gates with 6 and moved code
review to a dedicated subagent.
```
</example>

<example name="bad-entry">
```
In this milestone, we made significant progress on the shipping experience by
implementing various improvements and consolidating commands.
```
</example>

## Examples

<example name="scan-mode-flow">
User: /lo:stream

Stream has 15 entries, last updated 2026-03-09 ("v0.4.0: unified ship and plugin redesign").

Found 1 milestone since last stream update:

1. 2026-03-10 — "Skill prompt engineering audit" (34 commits)
   Applied Anthropic's prompt best practices across all LO skills...

User approves → writes 2026-03-10-skill-prompt-engineering-audit.md

Stream updated: 1 new milestone written.
Stream now has 16 entries.
</example>

<example name="manual-entry">
User: /lo:stream (says "I want to add a milestone about the new auth system")

What happened? → "Launched session-based auth with OAuth providers"
When? → 2026-03-08
Version? → no
Related feature? → f003

Writes 2026-03-08-auth-system.md
</example>
