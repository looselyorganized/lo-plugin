---
name: lo-park
description: Captures ideas and rich conversation context for later. Creates a backlog entry linked to a detailed conversation summary in .lo/park/. Use when user says "park this", "save this for later", "park", "remember this idea", or "/lo:park". Not for planning or execution — use /lo:plan to design, /lo:work to build.
allowed-tools:
  - Read
  - Glob
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---

# LO Park

Captures ideas and conversation context for later. When you've been discussing something with Claude and want to save the thinking without committing to planning or building, park it.

## When to Use

- User invokes `/lo:park`
- User says "park this", "save this for later", "let's come back to this"
- A conversation has produced valuable thinking that isn't ready for `/lo:plan`

## When NOT to Use — Redirect Instead

- "Let's plan this" → `/lo:plan` (creates backlog entry + plans in one motion)
- "Let's build this" → `/lo:work` (creates backlog entry + executes)
- "Ship it" → `/lo:ship`

## Critical Rules

- The `.lo/` directory must exist. If missing, tell user to run `/lo:setup` first.
- ALWAYS present the capture for user review before writing. Nothing saves without approval.
- Re-read BACKLOG.md from disk on every invocation. Never rely on cached content.
- Read `last_feature` and `last_task` from BACKLOG.md frontmatter for ID allocation.
- After writing, increment the relevant counter in BACKLOG.md frontmatter.

## Mode Detection

Detect mode from arguments:

- `/lo:park` (no args) → **Mode 1: Capture from Conversation**
- `/lo:park feature "name"` → **Mode 2: Quick Park** (backlog entry only)
- `/lo:park task "name"` → **Mode 2: Quick Park** (backlog entry only)

---

## Mode 1: Capture from Conversation

This is the primary mode. The user has been discussing something and wants to preserve the thinking.

<capture-flow>
Step 1: Determine what to capture.

Suggest a name based on the conversation topic:

    What should I call this?

    1. [suggested name based on conversation]
    2. Something else

Classify as feature (f{NNN}) or task (t{NNN}) based on scope. Features are bigger and need design. Tasks are smaller, just-do-it items. If scope is ambiguous, ask:

    Is this a feature (bigger, needs design) or a task (smaller, just do it)?

Step 2: Generate the conversation capture.

Read the conversation context and produce a rich, near-verbatim summary that preserves the thinking. This is NOT a structured extraction — it reads like meeting notes that capture the actual flow of ideas.

Include all of these:
- What was discussed and in what order
- Decisions that were made and WHY
- Approaches that were considered and WHY they were accepted or rejected
- Points of excitement or emphasis from the user
- Open questions that weren't resolved
- Technical details, code patterns, or architecture discussed

The capture should be long enough that future-you can read it and be immediately back in the headspace. Err on the side of too much context rather than too little.

Format the capture file per `references/park-format.md`:

    # <id> — <name>
    parked: <YYYY-MM-DD>

    <Rich narrative capture. Multiple paragraphs.
    Preserves the flow of thinking, not just the conclusions.>

Step 3: Present for review.

Show the complete capture to the user:

    Here's what I captured. Review and approve, or tell me what to change:

    ---
    [full capture content]
    ---

    Save this? (yes / edit / redo)

HARD GATE: Do not write any files until the user approves. If the user says "edit" or "redo", ask what to change, regenerate, and re-present. Repeat until approved.

Step 4: Persist.

After the user approves:

1. Read BACKLOG.md from disk. Extract the next ID:

```bash
# Read the counter from frontmatter
grep 'last_feature:' .lo/BACKLOG.md   # → last_feature: 9
# Next feature ID = last_feature + 1 → f010
```

2. Create `.lo/park/` directory if it doesn't exist:

```bash
mkdir -p .lo/park
```

3. Write the capture file:

```bash
# Path: .lo/park/<id>-<slug>.md
# Example: .lo/park/f010-image-gen.md
```

```markdown
# f010 — Image Generation for MDX Pipeline
parked: 2026-03-12

Started by exploring whether we could auto-generate hero images...
[rich narrative continues]
```

4. Add a backlog entry under the appropriate section of BACKLOG.md.

For features, add under `## Features`:

```markdown
- [ ] f010 Image Generation for MDX Pipeline
  AI-powered image generation integrated into the article publishing pipeline.
  [parked](.lo/park/f010-image-gen.md)
```

For tasks, add under `## Tasks`:

```markdown
- [ ] t016 Fix dark mode toggle
  [parked](.lo/park/t016-dark-mode.md)
```

5. Increment the counter in BACKLOG.md frontmatter:

```yaml
# Before:
last_feature: 9
# After:
last_feature: 10
```

6. Update the `updated:` date in BACKLOG.md frontmatter to today.

7. Report:

```
Parked: f010 "Image Generation for MDX Pipeline"
Capture: .lo/park/f010-image-gen.md

Pick this up later with /lo:plan f010 or /lo:work f010
```
</capture-flow>

---

## Mode 2: Quick Park

Just a backlog entry. No capture file. Use when the user provides a name directly.

1. Read BACKLOG.md from disk. Get the next ID from the frontmatter counter:

```bash
grep 'last_task:' .lo/BACKLOG.md   # → last_task: 15
# Next task ID = 15 + 1 → t016
```

2. If feature and no description was provided, ask for 1-2 sentences describing it.

3. Add the entry to BACKLOG.md under the appropriate section. No `[parked]` link — this is a plain backlog item.

For features:

```markdown
- [ ] f010 Real-time Collab Editing
  Collaborative editing for field notes using CRDTs.
```

For tasks:

```markdown
- [ ] t016 Fix dark mode toggle
```

4. Increment the relevant counter in BACKLOG.md frontmatter.
5. Update the `updated:` date to today.
6. Report: `Parked: <id> "<name>"`

---

## Error Handling

- **`.lo/` directory doesn't exist** → Stop. Tell the user: "Run `/lo:setup` first to initialize the project."
- **BACKLOG.md doesn't exist** → Create it from this template before proceeding:

```markdown
---
updated: <today>
last_feature: 0
last_task: 0
---

## Features

## Tasks
```

- **User rejects the capture** ("edit" or "redo") → Ask what to change, regenerate the capture, and re-present for approval. Loop until the user says "yes".

---

<example name="rich-capture-mid-conversation">
User has been discussing image generation for MDX articles for 20 minutes.

User: park this

Assistant suggests name: "Image Generation for MDX Pipeline" (feature).
User confirms.

Assistant generates rich capture preserving the full conversation thinking,
presents it for review.

User: yes

    Parked: f009 "Image Generation for MDX Pipeline"
    Capture: .lo/park/f009-image-gen.md

    Pick this up later with /lo:plan f009 or /lo:work f009
</example>

<example name="quick-park-feature">
User: /lo:park feature "real-time collab editing"

Assistant reads BACKLOG.md, gets next feature ID (f010), asks for a brief
description since none was provided.

User: Collaborative editing for field notes using CRDTs.

Assistant adds backlog entry with description, increments counter.

    Parked: f010 "Real-time Collab Editing"
</example>

<example name="quick-park-task">
User: /lo:park task "fix dark mode toggle"

Assistant reads BACKLOG.md, gets next task ID (t016), adds entry directly.
No description prompt needed for tasks.

    Parked: t016 "Fix dark mode toggle"
</example>