---
name: hypothesis
description: Generates a properly formatted LO hypothesis file with correct frontmatter and writes it to .lo/hypotheses/. Takes file(s) as input (notes, code, research) and walks the user through distilling a testable hypothesis statement. Use when user says "new hypothesis", "add hypothesis", "create hypothesis", "log a hypothesis", "test this idea", or "/lo:hypothesis".
metadata:
  version: 1.0.0
  author: LORF
  category: project-documentation
  tags: [lorf, hypothesis, research, scientific-method]
---

# LO Hypothesis Generator

Walks the user through creating a properly formatted hypothesis file for `.lo/hypotheses/`.

## When to Use

- User invokes `/lo:hypothesis`
- User says "new hypothesis", "add hypothesis", "create hypothesis", "log a hypothesis"
- User has notes or observations they want to formalize into a testable hypothesis

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- Hypothesis IDs are sequential within the project: `h001`, `h002`, etc.
- Filename convention: `h{NNN}-{slug}.md` — numeric prefix for ordering, slug for readability.
- The `statement` field must be a **testable claim** — something that can be validated or invalidated.
- Date is always today's date unless the user specifies otherwise.
- All files are plain Markdown with YAML frontmatter. No MDX.

## Workflow

### Step 1: Verify .lo/ Exists

Check that `.lo/hypotheses/` exists. If not:
```
No .lo/ directory found. Run /lo:new first to set up the project structure.
```
Stop here.

### Step 2: Read Input (if provided)

If the user provided file path(s):
1. Read each file
2. Identify key claims, observations, or assumptions that could become hypotheses
3. Summarize what you found

If no files provided, ask:
```
What observation, assumption, or idea do you want to formalize as a hypothesis?
```

### Step 3: Determine Next Hypothesis ID

Scan `.lo/hypotheses/` for existing files matching the pattern `h{NNN}-*.md`.

- Extract the highest existing number
- Next ID = highest + 1, zero-padded to 3 digits
- If no hypotheses exist, start at `h001`

### Step 4: Craft the Hypothesis Statement

Work with the user to distill a **testable hypothesis statement**.

A good hypothesis statement:
- Is a specific, falsifiable claim
- Describes what you expect to be true and under what conditions
- Can be validated or invalidated through evidence

Help the user refine their idea. Present the statement and ask for confirmation.

**Examples of good statements:**
- "Redis distributed locks with TTL expiration are sufficient for file-level mutual exclusion in multi-agent systems"
- "Streaming LLM responses through WebSocket connections reduces perceived latency by 60% compared to HTTP polling"
- "A single Bun process can coordinate 20+ concurrent agent connections without message loss"

**Examples of weak statements (help the user improve these):**
- "Redis is good for locking" (too vague, not testable)
- "The system will work" (not specific, not falsifiable)
- "WebSockets are better" (better than what? by what measure?)

### Step 5: Generate the Slug

Derive a kebab-case slug from the hypothesis topic:
- 2-5 words, descriptive
- e.g., `redis-locking`, `websocket-latency`, `agent-coordination-limits`

### Step 6: Determine Status

Default status is `proposed`. Ask the user if they've already started testing:

| If user says... | Set status to |
|----------------|---------------|
| Just an idea / haven't tested | `proposed` |
| Currently testing / running experiments | `testing` |
| Already confirmed / have evidence | `validated` |
| Tried it, didn't work | `invalidated` |
| Revising a previous hypothesis | `revised` (ask for `revisesId`) |

### Step 7: Write the File

Write to `.lo/hypotheses/h{NNN}-{slug}.md`.

To determine `content_slug`, read `.lo/PROJECT.md` and extract the project's slug from its `title` field (the part after "Project: ", kebab-cased). This links the hypothesis to the parent project.

If `revisesId` was set in Step 6, include it. Otherwise omit it entirely (don't include it commented out).

```markdown
---
id: "h{NNN}"
statement: "[The testable hypothesis statement]"
status: "[proposed|testing|validated|invalidated|revised]"
date: "YYYY-MM-DD"
revisesId: "h{NNN}"              # Only include if status is "revised"
content_slug: "[project-slug]"   # FK to parent project
---

## Context

[Where this hypothesis came from — what observation, note, or problem prompted it.]

## How to Test

[What experiment, measurement, or evidence would validate or invalidate this hypothesis.]

## Evidence

[Leave empty for proposed hypotheses. Fill in as evidence is gathered.]

## Notes

[Any additional context, related hypotheses, or open questions.]
```

### Step 8: Confirm

```
Hypothesis created: .lo/hypotheses/h{NNN}-{slug}.md

  ID: h{NNN}
  Statement: [statement]
  Status: [status]

Next steps:
  - Design an experiment to test this hypothesis
  - Update the status as evidence is gathered
  - If this hypothesis is revised, create a new one with revisesId: "h{NNN}"
```

## Reference

For the complete hypothesis frontmatter contract and examples, consult `references/hypothesis-example.md`.
