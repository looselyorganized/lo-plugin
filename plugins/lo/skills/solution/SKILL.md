---
name: solution
description: Captures reusable knowledge in .lo/solutions/ after completing work. Prompts for what was learned, what's reusable, and writes a structured solution file. Can be invoked standalone or triggered by lo:ship. Use when user says "capture solution", "what did I learn", "save this knowledge", "document solution", "/solution", or when prompted after shipping.
metadata:
  version: 0.2.0
  author: LORF
---

# LO Solution Capture

Captures reusable knowledge in `.lo/solutions/`. Solutions compound over time — future brainstorming and planning sessions search this directory before starting from scratch.

## When to Use

- User invokes `/lo:solution`
- User says "capture solution", "what did I learn", "document solution"
- Triggered by `/lo:ship` after a successful shipment
- After completing a feature, fixing a tricky bug, or discovering a useful pattern

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- If `.lo/solutions/` doesn't exist, create it.
- Solutions are about **reusable knowledge**, not project-specific notes. If it's only relevant to this one instance, suggest `.lo/notes/` instead.
- Filename convention: `<topic-slug>.md` (kebab-case, 2-5 words)
- If a solution file with the same slug exists, append a new dated section rather than overwriting.
- All files are plain Markdown with YAML frontmatter. No MDX.

## Workflow

### Step 1: Verify .lo/ Exists

Check that `.lo/solutions/` exists. If not, create it:
```
mkdir -p .lo/solutions
```

### Step 2: Gather Context

If invoked after `/lo:ship` or from a work context, automatically gather:
- What feature/task was just completed
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

Derive a topic slug from the problem/solution domain (not from the feature name).

Write to `.lo/solutions/<topic-slug>.md`:

    ---
    date: YYYY-MM-DD
    from: <feature-name-or-context>
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

Tags: choose 2-4 from technical domain (caching, auth, database, api, testing, deployment, performance) or pattern type (workaround, pattern, configuration, debugging, architecture). Create new tags as needed.

### Step 5: Confirm

    Solution captured: .lo/solutions/<topic-slug>.md
      Problem: [1-line summary]
      Tags: [tags]
      From: [source]

## Appending to Existing Solutions

If the slug already exists, add a new dated section:

    ---

    ## YYYY-MM-DD — Additional Finding

    ### Problem
    [New problem]

    ### What Worked
    [New solution]

    ### Reuse Notes
    [Updated guidance]

Update frontmatter `date:` to today and merge new tags with existing.
