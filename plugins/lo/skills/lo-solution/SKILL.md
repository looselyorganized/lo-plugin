---
name: lo-solution
description: Captures reusable knowledge in .lo/solutions/ after completing work. Documents patterns, decisions, and techniques that could help in future projects. Use when user says "capture solution", "what did I learn", "save knowledge", "document pattern", or "/lo:solution". Also prompted after /lo:ship.
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

# LO Solution

Captures reusable knowledge in `.lo/solutions/`. Solutions compound over time — future `/lo:plan` sessions scan this directory before starting from scratch, so every solution you capture makes the next project faster.

## When to Use

- User invokes `/lo:solution`
- User says "capture solution", "what did I learn", "save knowledge"
- Prompted after `/lo:ship` completes
- After completing challenging work with lessons learned

## Flow

### Step 1: Determine What to Capture

If invoked after `/lo:ship` or from a work context, gather context automatically from the recent work (feature ID, changed files, branch). Otherwise, prompt:

> "What was the problem? What did you learn? What's reusable?"

If the answer sounds project-specific rather than reusable, gently redirect: "Is there a reusable pattern buried in here? Let's extract just that part."

### Step 2: Check Existing Solutions

Scan `.lo/solutions/` for related solutions. If a related solution already exists, offer to append a new dated section to it rather than creating a duplicate.

When appending, add a new section under a `## YYYY-MM-DD — Additional Finding` heading with Problem, Solution, and Context subsections. Update the frontmatter `date:` to today and merge new tags with existing. Keep the same `id`.

### Step 3: Generate Solution File

Determine the next sequential ID by scanning `.lo/solutions/`:

```bash
# Find highest existing ID
ls .lo/solutions/s*.md 2>/dev/null | sort -t's' -k2 -n | tail -1
# → s003-response-caching.md → next ID is s004
```

IDs are permanent — never reuse an ID, even after deletion.

Derive a topic slug from the problem/solution domain (not from the feature name). Filename: `s{NNN}-topic-slug.md` (kebab-case, 2-5 words).

```bash
# Example path:
# .lo/solutions/s004-bun-debugger-workaround.md
```

Solution file format:

```markdown
---
id: s{NNN}
title: "Solution Title"
date: YYYY-MM-DD
tags:
  - tag1
  - tag2
---

## Problem

What problem was solved. 1-3 sentences, concrete and specific.

## Solution

What was learned and how to apply it. Include code snippets, commands, or configuration if relevant.

## Context

When this applies and when it doesn't. Conditions, caveats, alternatives considered.
```

Tags: choose 2-4 from technical domain (caching, auth, database, api, testing, deployment, performance) or pattern type (workaround, pattern, configuration, debugging, architecture). Create new tags as needed.

### Step 4: Present for Review

Show the full solution file content to the user before writing. Confirm they're happy with the content, title, and tags.

### Step 5: Save

Write to `.lo/solutions/s{NNN}-<slug>.md` and confirm:

```
Solution captured: s{NNN} .lo/solutions/s{NNN}-topic-slug.md
  Title: [title]
  Tags: [tags]
```

## Integration with /lo:plan

Solutions are checked during `/lo:plan` Step 2 (prior art scan). Write solutions with enough context that a future planning session can decide whether the solution applies without reading the full history.

## Error Handling

- `.lo/` doesn't exist: tell the user to run `/lo:setup` first.
- `.lo/solutions/` doesn't exist: create it with `mkdir -p .lo/solutions`.
- No solutions yet: this is the first one, start at `s001`.

<example name="first-solution">
User: /lo:solution

Assistant checks `.lo/solutions/` — empty directory.

> What was the problem? What did you learn? What's reusable?

User explains a debugging technique they discovered.

Assistant writes `.lo/solutions/s001-bun-debugger-workaround.md` with Problem, Solution, Context sections. Confirms with user before saving.

```
Solution captured: s001 .lo/solutions/s001-bun-debugger-workaround.md
  Title: Bun debugger workaround
  Tags: debugging, bun
```
</example>

<example name="append-to-existing">
User: /lo:solution — I found another edge case with that caching pattern

Assistant scans `.lo/solutions/`, finds `s003-response-caching-pattern.md` covers the same topic. Offers to append rather than create a new solution. Adds a dated section to the existing file and updates tags.
</example>

<example name="post-ship-prompt">
After `/lo:ship` completes successfully:

> That feature had some interesting challenges. Want to capture any reusable knowledge as a solution? (/lo:solution)

User: "Yeah, the way we handled the migration was worth saving."

Assistant gathers context from the just-shipped feature and writes the solution with a `from` reference linking back to the feature ID.
</example>
