---
name: solution
description: Captures reusable knowledge in .lo/solutions/ after completing work. Prompts for what was learned, what's reusable, and writes a structured solution file. Can be invoked standalone or triggered by lo:ship. Use when user says "capture solution", "what did I learn", "save this knowledge", "document solution", "/solution", or when prompted after shipping.
metadata:
  version: 0.2.1
  author: LORF
---

# LO Solution Capture

Captures reusable knowledge in `.lo/solutions/`. Solutions compound over time — future brainstorming and planning sessions search this directory before starting from scratch.

## ID Convention

Solutions get sequential IDs: `s001`, `s002`, etc. IDs are permanent — never reuse an ID, even after deletion. To determine the next ID, scan `.lo/solutions/` for the highest existing `s{NNN}` in filenames and increment.

When a solution comes from a shipped feature, the `from` field links back to the feature ID (e.g., `from: "f003"`). This creates a traceable chain: backlog → work → ship → solution.

## When to Use

- User invokes `/lo:solution`
- User says "capture solution", "what did I learn", "document solution"
- Triggered by `/lo:ship` after a successful shipment
- After completing a feature, fixing a tricky bug, or discovering a useful pattern

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- If `.lo/solutions/` doesn't exist, create it.
- Solutions are about **reusable knowledge**, not project-specific notes. If it's only relevant to this one instance, suggest `.lo/notes/` instead.
- Filename convention: `s{NNN}-topic-slug.md` (ID prefix, kebab-case slug, 2-5 words)
- Every solution MUST have an `id` in frontmatter matching the filename prefix.
- If appending to an existing solution, keep the same ID — don't create a new one.
- All files are plain Markdown with YAML frontmatter. No MDX.

## Workflow

### Step 1: Verify .lo/ Exists

Check that `.lo/solutions/` exists. If not, create it:
```
mkdir -p .lo/solutions
```

### Step 2: Gather Context

If invoked after `/lo:ship` or from a work context, automatically gather:
- What feature/task was just completed (including its `f{NNN}` ID)
- What branch the work was on
- Key files that were changed

If invoked standalone, ask: "What did you just finish working on?"

### Step 3: Prompt for Knowledge

Ask three questions (adapt phrasing to context):

1. **What problem did you run into?** — What was hard, unexpected, or non-obvious?
2. **What approach worked?** — What was the solution, pattern, or technique?
3. **When would you use this again?** — Under what conditions would future-you want to know this?

If answers sound project-specific rather than reusable, gently redirect:
"This sounds specific to [feature]. Would it be better as a note in .lo/notes/? If there's a reusable pattern buried in here, let's extract just that part."

### Step 4: Write the Solution

1. Determine next solution ID: scan `.lo/solutions/` for the highest `s{NNN}` in filenames, increment.
2. Derive a topic slug from the problem/solution domain (not from the feature name).
3. Write to `.lo/solutions/s{NNN}-topic-slug.md`:

```markdown
---
id: "s{NNN}"
date: YYYY-MM-DD
from: "f{NNN}"
tags:
  - tag-one
  - tag-two
---

## Problem

[What we ran into. 1-3 sentences. Concrete, specific.]

## What Worked

[The approach that solved it. Include code snippets, commands, or configuration if relevant.]

## Reuse Notes

[When to apply this again. Conditions, caveats, alternatives considered.]
```

The `from` field links to the originating feature ID. If the solution doesn't come from a tracked feature, use a descriptive string (e.g., `from: "debugging session"` or `from: "t005"`).

Tags: choose 2-4 from technical domain (caching, auth, database, api, testing, deployment, performance) or pattern type (workaround, pattern, configuration, debugging, architecture). Create new tags as needed.

### Step 5: Confirm

```
Solution captured: s{NNN} .lo/solutions/s{NNN}-topic-slug.md
  Problem: [1-line summary]
  Tags: [tags]
  From: f{NNN} "<feature-name>"
```

## Appending to Existing Solutions

If the topic matches an existing solution, append a new dated section to the existing file rather than creating a new ID:

```markdown
---

## YYYY-MM-DD — Additional Finding

### Problem
[New problem]

### What Worked
[New solution]

### Reuse Notes
[Updated guidance]
```

Update frontmatter `date:` to today and merge new tags with existing. Keep the same `id`.
