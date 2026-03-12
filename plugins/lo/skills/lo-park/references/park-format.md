# Park File Format

Parked conversation captures live in `.lo/park/`. One file per parked item.

## File naming

`<id>-<slug>.md` — e.g., `f009-image-gen.md`, `t015-auth-refactor.md`

## Format

```markdown
# <id> — <name>
parked: <YYYY-MM-DD>

<Rich narrative capture of the conversation. Multiple paragraphs.
Preserves the flow of thinking, not just the conclusions.>
```

## Content guidelines

The capture should read like meeting notes that preserve the actual flow of ideas:
- What was discussed and in what order
- Decisions made and WHY
- Approaches considered and WHY accepted/rejected
- Points of emphasis from the user
- Open questions that weren't resolved
- Technical details, code patterns, or architecture discussed

Err on too much context rather than too little. Future-you should be immediately
back in the headspace after reading this.
