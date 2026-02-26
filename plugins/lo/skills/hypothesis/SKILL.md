---
name: hypothesis
description: Logs a hypothesis to .lo/hypotheses/. Quick mode (default) takes a statement inline and generates the file immediately. Guided mode walks through refining the statement and adding context. Use when user says "new hypothesis", "add hypothesis", "log hypothesis", "I think X will work", or "/lo:hypothesis".
metadata:
  version: 0.2.0
  author: LORF
---

# LO Hypothesis

Captures hypotheses — directional bets about technology, architecture, or approach — in `.lo/hypotheses/`.

## When to Use

- User invokes `/lo:hypothesis`
- User says "new hypothesis", "add hypothesis", "I think X", "I bet X"
- User has an assumption worth recording before acting on it

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- Hypothesis IDs are sequential within the project: `h001`, `h002`, etc.
- Filename convention: `h{NNN}-{slug}.md` — numeric prefix for ordering, slug for readability.
- Date is always today's date unless the user specifies otherwise.
- All files are plain Markdown with YAML frontmatter. No MDX.
- **Default to quick mode.** Only use guided mode if the user asks for help refining their idea or provides files as input.

## Quick Mode (Default)

If the user provides a statement (inline or as `$ARGUMENTS`), generate the file with minimal prompting.

### Step 1: Verify .lo/ Exists

Check that `.lo/hypotheses/` exists. If not:
```
No .lo/ directory found. Run /lo:new first to set up the project structure.
```
Stop here.

### Step 2: Determine Next Hypothesis ID

Scan `.lo/hypotheses/` for existing files matching the pattern `h{NNN}-*.md`.

- Extract the highest existing number
- Next ID = highest + 1, zero-padded to 3 digits
- If no hypotheses exist, start at `h001`

### Step 3: Generate the File

Derive a kebab-case slug (2-5 words) from the statement.

Read `.lo/PROJECT.md` and extract the project's slug from its `title` field (the part after "Project: ", kebab-cased) for the `content_slug` field.

Write to `.lo/hypotheses/h{NNN}-{slug}.md`:

```markdown
---
id: "h{NNN}"
statement: "[The hypothesis statement as provided]"
status: "proposed"
date: "YYYY-MM-DD"
content_slug: "[project-slug]"
---

## Context

[Infer 1-2 sentences from the statement about why this hypothesis matters. Keep it brief.]

## Evidence

[Empty — fill in as evidence is gathered.]
```

### Step 4: Confirm

```
h{NNN}: [statement]
→ .lo/hypotheses/h{NNN}-{slug}.md
```

Done. No follow-up questions.

## Guided Mode

Use guided mode when:
- The user asks for help refining their idea
- The user provides file(s) as input (notes, code, research)
- The user says "help me think through this" or similar

### Step 1: Verify .lo/ Exists

Same as quick mode.

### Step 2: Read Input (if provided)

If the user provided file path(s):
1. Read each file
2. Identify key claims, observations, or assumptions that could become hypotheses
3. Summarize what you found

If no files provided, ask:
```
What are you thinking? What assumption or bet are you making?
```

### Step 3: Determine Next Hypothesis ID

Same as quick mode.

### Step 4: Refine the Statement

Help the user sharpen their idea into a clear directional statement. Don't gatekeep — a hypothesis doesn't need to be formally falsifiable to be worth recording. It just needs to be specific enough that you'll know later whether it held up.

**Good statements (specific, directional):**
- "Redis distributed locks with TTL expiration are sufficient for file-level mutual exclusion in multi-agent systems"
- "Monorepo will simplify deploys for the three services"
- "A single Bun process can coordinate 20+ concurrent agent connections without message loss"

**Weak statements (help the user tighten these):**
- "Redis is good for locking" → good for what specifically?
- "The system will work" → which part, under what conditions?
- "WebSockets are better" → better than what, by what measure?

Present the refined statement and ask for confirmation.

### Step 5: Determine Status

Default status is `proposed`. Ask the user if they've already started testing:

| If user says... | Set status to |
|----------------|---------------|
| Just an idea / haven't tested | `proposed` |
| Currently testing / running experiments | `testing` |
| Already confirmed / have evidence | `validated` |
| Tried it, didn't work | `invalidated` |
| Revising a previous hypothesis | `revised` (ask for `revisesId`) |

### Step 6: Write the File

Same template as quick mode, but:
- Use the refined statement
- Use the determined status
- If `revisesId` was set, include it in frontmatter. Otherwise omit it entirely.
- Add richer context based on the conversation or input files.

```markdown
---
id: "h{NNN}"
statement: "[Refined statement]"
status: "[proposed|testing|validated|invalidated|revised]"
date: "YYYY-MM-DD"
revisesId: "h{NNN}"              # Only include if status is "revised"
content_slug: "[project-slug]"
---

## Context

[Where this hypothesis came from — what observation, conversation, or problem prompted it.]

## Evidence

[Leave empty for proposed hypotheses. Fill in as evidence is gathered.]
```

### Step 7: Confirm

```
h{NNN}: [statement]
Status: [status]
→ .lo/hypotheses/h{NNN}-{slug}.md
```

## Reference

For the complete hypothesis frontmatter contract and examples, consult `references/hypothesis-example.md`.
