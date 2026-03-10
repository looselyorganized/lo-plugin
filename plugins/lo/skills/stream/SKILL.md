---
name: stream
description: Creates milestone entries in .lo/STREAM.md — the public-facing narrative of a project. Each entry marks a significant event worth showing on the project page or posting to socials. Not a git log summary — a curated editorial timeline. Use when user says "update stream", "add milestone", "log progress", or "/lo:stream". Also invoked by /lo:ship during release mode.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# LO Stream

The stream is the **public face of the project** — what appears on looselyorganized.org and feeds social posts. Every entry is a milestone: something worth showing a visitor.

All entries live in a single `.lo/STREAM.md` file using XML tags for reliable parsing. Newest first.

<critical>
Quality gate: would you post this? If you wouldn't put it on the project page or tweet it, it's not a stream entry. Git history already captures the small stuff.
Never create duplicate entries. Always read existing stream entries first.
</critical>

## STREAM.md Format

See `references/stream-format.md` for the full specification and parsing algorithm.

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

### Entry Metadata Fields

| Field | Required | Type | Notes |
|-------|----------|------|-------|
| `date` | yes | YYYY-MM-DD | Unquoted |
| `title` | yes | string | Quoted, under 80 chars |
| `version` | no | semver | Quoted, only for releases |
| `research` | no | string | Quoted, comma-separated slugs |

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
  - [ ] Step 5: Write entries
  - [ ] Step 6: Confirm
```

### Step 1: Verify .lo/ Exists

Check that `.lo/STREAM.md` exists. If not, check if `.lo/` exists at all:

- No `.lo/` directory: tell user to run `/lo:new` first. Stop here.
- `.lo/` exists but no `STREAM.md`: create it with just the frontmatter:
  ```markdown
  ---
  type: stream
  ---
  ```

### Step 2: Read Existing Stream

Read `.lo/STREAM.md` and parse existing entries:

- Split content on `<entry>` tags
- Parse each entry's metadata (`date`, `title`, `version`)
- Note the **most recent entry date** (first entry in the file) — this is the "last known" point

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

For each candidate, draft a title and 1-3 sentence description.

Present candidates:

```
Found N milestones since last stream update:

1. YYYY-MM-DD — "Title here" (version: 0.4.0)
   Description preview...

2. YYYY-MM-DD — "Title here"
   Description preview...

Skip any? Edit any? Or write all?
```

**Wait for user confirmation.** The user can approve all, skip entries, edit titles/bodies, or adjust what qualifies.

### Step 5: Write Entries

For each approved entry, prepend to `.lo/STREAM.md` after the YAML frontmatter (newest first).

Entry format:

```markdown
<entry>
date: YYYY-MM-DD
title: "Short descriptive title"
version: "X.Y.Z"
<description>
1-3 sentences. Public voice — concrete, editorial, no filler.
</description>
</entry>
```

Omit optional metadata fields (`version`, `research`) that don't apply.

**How to prepend:** Read the file, find the end of the YAML frontmatter (the closing `---`), insert the new entry block(s) immediately after it (with a blank line separator), then write the file back.

### Step 6: Confirm

```
Stream updated: N new milestones written.

  "Title" (version: X.Y.Z)
  "Title"

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
4. Related research?

Generate a single entry. Prepend to `.lo/STREAM.md` after the frontmatter using the same XML format as scan mode Step 5.

Present for confirmation before writing.

</manual-mode>

---

<ship-mode>
## Ship Mode (invoked by /lo:ship)

When `/lo:ship` invokes the stream during release mode, it passes context in the conversation:
- Version number
- Feature names from the release
- Work artifact summaries (plans, key decisions)

Use this context to draft the entry. Do NOT scan git history — the context is already provided.

1. Draft a title and 1-3 sentence description from the provided context
2. Present for user review before writing
3. Prepend to `.lo/STREAM.md` after the frontmatter using the same XML format as scan mode Step 5
4. Include `version` in the entry metadata

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

Stream has 5 entries, last updated 2026-03-09 ("Unified ship and plugin redesign").

Found 1 milestone since last stream update:

1. 2026-03-10 — "Stream redesign and skill hardening" (version: 0.4.1)
   Stream consolidated into single STREAM.md with milestones-only quality gate...

User approves → entry prepended to STREAM.md

Stream updated: 1 new milestone written.
Stream now has 6 entries.
</example>

<example name="manual-entry">
User: /lo:stream (says "I want to add a milestone about the new auth system")

What happened? → "Launched session-based auth with OAuth providers"
When? → 2026-03-08
Version? → no
Related research? → no

Entry prepended to STREAM.md.
</example>
