---
name: lo-stream
description: Creates public milestone entries in .lo/STREAM.md — the editorial narrative of a project. Each entry marks a significant event worth posting to socials or showing on a project page. Not a git log. Use when user says "stream", "add milestone", "log progress", "update stream", or "/lo:stream". Also prompted after /lo:ship.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---

# LO Stream

The stream is the editorial narrative of a project — milestones that appear on looselyorganized.org and feed social posts. Not a changelog, not a git log. A curated timeline of events worth telling the world about.

All entries live in a single `.lo/STREAM.md` file using XML tags. Newest first.

## When to Use

- User invokes `/lo:stream`
- User says "stream", "add milestone", "log progress", "update stream"
- Prompted after `/lo:ship` completes

## Quality Gate

Every entry must pass one test: **would you post this?**

If the answer is no, it is not a milestone.

**Qualifies:** version releases, major features that change how the project works, published research, architectural pivots, lessons learned that other builders would find useful.

**Does not qualify:** routine fixes, config changes, dependency updates, internal housekeeping, incremental improvements, CI tweaks. Git history already captures the small stuff.

## Critical Rules

- The `.lo/` directory must exist. If missing, tell user to run `/lo:setup` first.
- ALWAYS present the draft entry for user review before writing. Nothing saves without approval.
- Re-read STREAM.md from disk on every invocation. Never rely on cached content.
- Never create duplicate entries. Check existing entries before writing.

## Mode Detection

Detect mode from arguments and context:

- `/lo:stream` (no args) → **Scan Mode** — scan recent history for milestone candidates
- `/lo:stream "title"` → **Manual Mode** — create entry with provided title
- Invoked after `/lo:ship` → **Ship Mode** — context already available from ship pipeline

---

## Scan Mode

The default. Scan recent git history and work artifacts to surface milestone candidates.

Step 1: Verify `.lo/STREAM.md` exists.

If `.lo/` does not exist, stop and tell the user: "Run `/lo:setup` first to initialize the project."

If `.lo/` exists but `STREAM.md` does not, create it with frontmatter only:

```markdown
---
type: stream
---
```

Step 2: Read existing stream entries.

Read `.lo/STREAM.md` and parse existing entries. Note the most recent entry date (first entry in the file) — this is the "last known" point.

    Stream has N entries, last updated YYYY-MM-DD ("title of most recent").

Step 3: Scan for milestones.

Look at git log since the last stream entry date. Also scan `.lo/work/` for completed features and recent artifacts.

```bash
git log --after="YYYY-MM-DD" --pretty=format:"%H|%ad|%s" --date=short
```

```bash
git tag --sort=-creatordate --format="%(creatordate:short)|%(refname:short)|%(subject)"
```

If no commits found since the last entry:

    No new commits since last stream entry (YYYY-MM-DD). Nothing milestone-worthy found. Add one manually with /lo:stream "title"?

Stop here.

Step 4: Identify milestones.

Apply the quality gate. For each candidate that passes, draft a title and 1-3 sentence description.

Present candidates to the user:

    Found N milestones since last stream update:

    1. YYYY-MM-DD — "Title here" (version: 0.4.0)
       Description preview...

    2. YYYY-MM-DD — "Title here"
       Description preview...

    Skip any? Edit any? Or write all?

HARD GATE: Wait for user confirmation before writing anything. The user can approve all, skip entries, or edit titles and descriptions.

Step 5: Write entries.

For each approved entry, prepend to `.lo/STREAM.md` after the YAML frontmatter (newest first). Read the file, find the closing `---` of the frontmatter, insert new entries immediately after it with a blank line separator, then write the file.

Entry format — see `references/stream-format.md` for the full spec:

```
<entry>
date: YYYY-MM-DD
title: "Short descriptive title"
version: "X.Y.Z"
<description>
1-3 sentences. Public voice.
</description>
</entry>
```

Omit `version` unless the milestone is a release. Omit `research` unless linking to published research.

Step 6: Report.

    Stream updated: N new milestones written.

      "Title" (version: X.Y.Z)
      "Title"

    Stream now has TOTAL entries.

---

## Manual Mode

The user provided a title or wants to add a specific milestone without scanning git.

Step 1: Gather details.

If the user provided a title, confirm the details. Otherwise ask:

1. What happened?
2. When? (default: today)
3. Version? (only if it was a release)

Step 2: Draft a single entry using the XML format from Scan Mode Step 5.

Step 3: Present for review.

    Here's the stream entry. Save it? (yes / edit)

HARD GATE: Do not write until the user approves.

Step 4: Prepend to `.lo/STREAM.md` after the frontmatter.

Step 5: Report what was saved.

---

## Ship Mode

When invoked after `/lo:ship`, context is already available in the conversation: version number, feature names, work artifact summaries.

Do NOT scan git history — use the context provided.

1. Draft a title and 1-3 sentence description from the ship context.
2. Include `version` in the entry metadata.
3. Present for user review before writing.
4. Prepend to `.lo/STREAM.md` after the frontmatter.

---

## Writing Style

Stream entries are public-facing. Write for someone discovering the project, not for yourself.

- Lead with what was built and why it matters.
- Include concrete details: component names, counts, key decisions.
- Do not repeat what is obvious from the title.
- No filler ("In this update we...", "This milestone represents...").
- 1-3 sentences. Every word should earn its place.

## Error Handling

- **`.lo/` directory does not exist** → Stop. Tell the user: "Run `/lo:setup` first to initialize the project."
- **STREAM.md does not exist** → Create it with `type: stream` frontmatter, then proceed.
- **No milestones found in scan** → "Nothing milestone-worthy found since YYYY-MM-DD. Add one manually with `/lo:stream "title"`?"

---

<example name="release-milestone">
User: /lo:stream (after shipping v0.5.0)

Stream has 4 entries, last updated 2026-03-10 ("Stream redesign and skill hardening").

Found 1 milestone since last stream update:

1. 2026-03-11 — "Stage-aware engineering rigor" (version: 0.5.0)
   Ship pipeline now reads project.yml status and adjusts gates — Explore skips
   review and tests, Build runs the full pipeline, Open adds npm audit. Code review
   moved to a dedicated subagent.

Write this? (yes / edit)

User: yes

Stream updated: 1 new milestone written.
Stream now has 5 entries.
</example>

<example name="feature-milestone">
User: /lo:stream

Stream has 5 entries, last updated 2026-03-11 ("Stage-aware engineering rigor").

Found 1 milestone since last stream update:

1. 2026-03-12 — "Plugin redesign: skills as standalone units"
   Eleven skills rewritten as self-contained SKILL.md files with YAML frontmatter.
   Each skill declares its own tools, reducing coupling and making the plugin
   marketplace-ready.

Write this? (yes / edit)

User: change "marketplace-ready" to "distributable"

Updated. Save it? (yes / edit)

User: yes

Stream updated: 1 new milestone written.
Stream now has 6 entries.
</example>

<example name="manual-entry">
User: /lo:stream "Launched public API documentation"

Here's the stream entry:

<entry>
date: 2026-03-12
title: "Launched public API documentation"
<description>
API reference published at docs.example.com covering all REST endpoints.
OpenAPI spec auto-generated from route handlers.
</description>
</entry>

Save it? (yes / edit)

User: yes

Stream updated. Entry saved: "Launched public API documentation"
</example>
