---
name: research
description: Generates a structured LO research article with proper frontmatter, editorial headings, narrative prose, and image placement notes. Takes file(s) as input and walks the user through creating a research document following the Loosely Organized editorial style. Use when user says "write research", "create research article", "draft research", "new research doc", "write up findings", or "/lo:research".
metadata:
  version: 2.0.0
  author: LORF
  category: research-writing
  tags: [lorf, research, writing, editorial, documentation]
---

# LO Research Article Generator

Walks the user through creating a structured research article for `.lo/research/`.

## When to Use

- User invokes `/lo:research`
- User says "write research", "create research article", "draft research"
- User has notes, findings, or observations to formalize into a research document

## Critical Rules

- `.lo/` directory MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- All files are plain Markdown with YAML frontmatter. No MDX.
- Filename convention: `{slug}.md` (kebab-case, descriptive)
- Research articles in `.lo/research/` are project-scoped. They are accessed through the parent project's page — there is no standalone `/research` route on the website.
- Default status is `draft`. Only the user can promote to `review` or `published`.

## Editorial Style

The Loosely Organized research style has specific characteristics. Before writing, consult `references/design-systems-for-agents.mdx` for the canonical example.

### Voice & Tone

- **Direct and declarative.** Lead with the point, not the preamble.
- **Technical but accessible.** Assume the reader is smart but not necessarily in your domain.
- **Show the work.** Don't just state conclusions — show the iteration, the failures, the tightening of the spec.
- **Concrete over abstract.** Use specific examples, real numbers, actual code.

### Structure Patterns

Research articles follow a narrative arc, not an academic paper format:

1. **Opening hook** — State the problem or insight in 1-2 paragraphs. No throat-clearing.
2. **Context/background** — What existed before, why it matters, what reference points you started from.
3. **The iteration loop** — The core of the article. Show attempts, failures, refinements. This is where the value is.
4. **What we learned** — Distilled insights, patterns, principles that emerged.
5. **Implications** — What this means for the broader domain. What changes because of this work.
6. **What's next** — Where this leads. Open questions. Future directions.

### Heading Rhythm

- `##` for major sections (5-8 per article)
- `###` sparingly for subsections within complex sections
- Headings should be descriptive and specific, not generic
  - Good: "The Iteration Loop", "From Iteration to Character Bible", "Sprite Sheets: Designing for Extraction"
  - Bad: "Background", "Discussion", "Results"

### Image Placement

Use HTML comment placeholders where images would strengthen the narrative:

```markdown
<!-- IMAGE: [Description of what the image should show, why it matters to the narrative, and what the reader should notice] -->
```

Image placement guidelines:
- After describing something visual, show it
- After each iteration attempt, show the result
- Before/after comparisons are powerful
- One image per major section is a good baseline
- Don't cluster images — space them between prose

### Paragraph Length

- 2-5 sentences per paragraph
- Mix short punchy paragraphs (1-2 sentences for emphasis) with longer explanatory ones
- Break up walls of text with lists, code blocks, or images

## Workflow

### Step 1: Verify .lo/ Exists

Check that `.lo/research/` exists. If not:
```
No .lo/ directory found. Run /lo:new first to set up the project structure.
```
Stop here.

### Step 2: Read Input (if provided)

If the user provided file path(s):
1. Read each file
2. Identify the core thesis, findings, or narrative thread
3. Summarize what you found and propose an article angle

If no files provided, ask:
```
What did you discover, build, or learn that you want to write up?
```

### Step 3: Define Article Metadata

Walk the user through:

1. **Title** — Specific and descriptive. Follow the pattern: "[Insight]: [Context]"
   - Good: "From Aesthetic to Algorithm: Building Design Systems as Agent Skills"
   - Good: "Distributed Locking for Multi-Agent Systems"
   - Bad: "My Research Findings" or "Notes on Redis"

2. **Topics** — 2-5 topic tags (kebab-case strings) for categorization
   - Draw from existing topics in the project or suggest new ones

3. **Slug** — Derived from title, kebab-case, used as filename

### Step 4: Build the Outline

Before writing prose, present an outline to the user:

```
## Proposed Structure

1. [Opening hook — 1-2 paragraphs on the core insight]
2. [Context section — what existed before]
3. [Iteration/discovery section — the core narrative]
4. [Lessons section — what emerged]
5. [Implications — what this means]
6. [What's next — open questions]

Image opportunities:
- After section 2: [description]
- After section 3: [description]

Does this structure work, or should we adjust?
```

Wait for user confirmation before writing.

### Step 5: Generate the Article

Write to `.lo/research/{slug}.md`:

```markdown
---
title: "[Article Title]"
date: "YYYY-MM-DD"
topics:
  - [topic-1]
  - [topic-2]
status: "draft"
---

[Full article content following the editorial style guidelines above]
```

Guidelines for generation:
- Write complete prose, not bullet-point outlines
- Include `<!-- IMAGE: ... -->` placeholders where visuals would help
- Every section should have substance — no placeholder text like "[expand this later]"
- End the article with a clear closing that ties back to the opening
- Consult `references/design-systems-for-agents.mdx` for the structural pattern, heading rhythm, and narrative arc

### Step 6: Confirm

```
Research article created: .lo/research/{slug}.md

  Title: [title]
  Topics: [topics]
  Status: draft
  Sections: [count]
  Image placeholders: [count]

This article belongs to the [project name] project.
It will appear on the project's page when the status is updated to "published".

Next steps:
  - Review and edit the draft
  - Add actual images where placeholders are marked
  - Update status to "review" when ready for feedback
  - Update status to "published" when finalized
```

## Reference

For the canonical example of the Loosely Organized editorial style, consult `references/design-systems-for-agents.mdx`.

For the research doc frontmatter contract, consult `references/frontmatter-contract.md`.
