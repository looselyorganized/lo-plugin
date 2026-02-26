---
name: ship
description: Quality pipeline for shipping completed work. Runs tests, code-simplifier, security review, then commits, pushes, and creates a PR. Creates a stream milestone and prompts for solution capture. Stops and reports if any gate fails. Use when user says "ship it", "ready to merge", "ship this", "push and PR", "/ship", or when work execution is complete.
metadata:
  version: 0.2.0
  author: LORF
---

# LO Ship Pipeline

Runs the quality pipeline to ship completed work. Each gate must pass before proceeding. Stops and reports if any gate fails.

## When to Use

- User invokes `/lo:ship`
- User says "ship it", "ready to merge", "push and PR", "ready to ship"
- Work has been completed via `/lo:work`

## Critical Rules

- NEVER skip a pipeline gate. Every stage runs in order.
- If ANY gate fails, STOP and report what needs fixing. Do not continue.
- Must be on a feature branch, not main. If on main, stop and explain.
- Always create a stream milestone after successful shipping.
- Always prompt for solution capture — but respect "no" as an answer.

## Pipeline

### Gate 1: Pre-flight

1. **Not on main/master:** Check `git branch --show-current`. If on main/master, stop.
2. **Working tree status:** Check `git status`. If uncommitted changes, ask whether to include or stash.
3. **Identify the feature:** Map branch name to `.lo/work/` directory or BACKLOG.md entry. If unclear, ask.

### Gate 2: Run Tests

Detect the project's test runner (package.json scripts, Cargo.toml, pyproject.toml, etc.) and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed without tests.

### Gate 3: Code Simplification

1. Identify changed files: `git diff --name-only main...HEAD`
2. Review for: unnecessary complexity, dead code, verbose patterns, duplication
3. If simplifications found → present them, ask whether to apply
4. If clean → proceed

### Gate 4: Security Review

Scan changed files for:
- Hardcoded secrets, API keys, tokens
- SQL injection, XSS vectors
- Insecure dependencies
- Sensitive data in logs

- **Issues found:** Stop. Report each with file and line.
- **Clean:** Proceed.

### Gate 5: Commit

1. Stage changes: `git add` relevant files (avoid blindly adding all)
2. Draft commit message based on feature name and changes
3. Present for user approval
4. Commit

### Gate 6: Push

```
git push -u origin <branch-name>
```

If push fails, stop and report.

### Gate 7: Create Pull Request

Create PR with:
- Title derived from feature name
- Body summarizing what was built and why
- Reference to plan in `.lo/work/` if applicable

Report the PR URL.

### Gate 8: Stream Milestone

Write to `.lo/stream/YYYY-MM-DD-<feature-slug>.md`:

    ---
    type: "milestone"
    date: "YYYY-MM-DD"
    title: "<Feature name>"
    commits: N
    ---

    [1-3 terse sentences about what was built and why it matters.]

Count commits: `git rev-list --count main..HEAD`

### Gate 9: Update Backlog

1. Read BACKLOG.md
2. Update matching feature status: `done -> YYYY-MM-DD`
3. Update `updated:` date

### Gate 10: Solution Prompt

    Feature shipped!

    PR: [url]
    Stream: .lo/stream/YYYY-MM-DD-<slug>.md
    Backlog: updated

    Anything reusable worth capturing?
    Type /lo:solution to capture it, or "no" to skip.

## Pipeline Summary

After completion:

    Ship complete!
      Tests:    passed (N tests)
      Simplify: [N changes | clean]
      Security: clean
      Commit:   <hash> "<message>"
      Push:     origin/<branch>
      PR:       <url>
      Stream:   .lo/stream/YYYY-MM-DD-<slug>.md
      Backlog:  <feature> -> done
      Solution: [captured | skipped]

## Error Recovery

    Ship stopped at Gate N: <gate-name>
    Issue: [what failed]
    Fix: [suggestion]
    After fixing, run /lo:ship again.

Pipeline always restarts from Gate 1 (gates are cheap, ensures consistency).
