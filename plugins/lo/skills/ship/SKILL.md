---
name: ship
description: Quality pipeline for shipping completed work. Full pipeline (tests, review, commit, push, PR) on feature branches. Light pipeline (tests, security, commit, mark done) on main. Not for planning or execution — use /lo:plan to design and /lo:work to build first. Cleans up work dirs and prompts for stream/solution capture. Stops if any gate fails. Use when user says "ship it", "ready to merge", "ship this", "push and PR", "done with", "mark done", "/ship", or when work execution is complete.
metadata:
  version: 0.3.0
  author: LORF
---

# LO Ship Pipeline

Runs the quality pipeline to ship completed work. Each gate must pass before proceeding. Stops and reports if any gate fails.

Two modes based on branch context:
- **Full pipeline** (feature/fix branch): tests → simplify → security → commit → push → PR → clean up → wrap-up
- **Light pipeline** (main branch, tasks only): tests → security → commit → mark done → wrap-up

## When to Use

- User invokes `/lo:ship`
- User says "ship it", "ready to merge", "push and PR", "ready to ship", "done with", "mark done"
- Work has been completed via `/lo:work`

## Critical Rules

- Run every pipeline gate in order. Skipping a gate risks shipping broken or insecure code.
- If any gate fails, stop and report what needs fixing. Continuing past a failure defeats the purpose of the pipeline.
- Prompt for stream update and solution capture after shipping — but respect "no" as an answer.
- Identify items by their `f{NNN}` or `t{NNN}` ID throughout the pipeline.

## Pipeline

### Gate 1: Pre-flight

1. **Branch check:** Check `git branch --show-current`.
   - If on a feature/fix branch → **full pipeline** (Gates 1-9).
   - If on main/master → ask the user:

         You're on main. Two options:

         1. Create a branch and run full pipeline (recommended)
         2. Quick ship — tests + security + commit on main, mark done (for small tasks)

     If they choose option 1, create the branch and proceed with full pipeline.
     If they choose option 2, proceed with **light pipeline** (Gates 1-5, skip 6-7, then Gate 8-9).
     Light pipeline is only available for tasks (`t{NNN}`). If the user is shipping a feature on main, recommend option 1.

2. **Working tree status:** Check `git status`. If uncommitted changes, ask whether to include or stash.
3. **Identify the item:** Map branch name (e.g., `feat/f003-auth-system` or `fix/t005-slug`) to the feature/task ID. On main, ask the user which backlog item this work completes. Cross-reference with `.lo/work/` directory and BACKLOG.md entry. If unclear, ask.

### Gate 2: Run Tests

Detect the project's test runner (package.json scripts, Cargo.toml, pyproject.toml, etc.) and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed without tests.

### Gate 3: Code Simplification

*Full pipeline only. Skip for light pipeline.*

1. Identify changed files: `git diff --name-only main...HEAD`
2. Review for: unnecessary complexity, dead code, verbose patterns, duplication
3. If simplifications found → present them, ask whether to apply
4. If clean → proceed

### Gate 4: Security Review

Two-phase security gate. Both phases must pass.

**Phase 1 — Static scan (quick):**

Scan changed files for:
- Hardcoded secrets, API keys, tokens, passwords
- `.env` files or credentials staged for commit
- Sensitive data in logs or error messages

**Phase 2 — Vulnerability sweep (thorough):**

Read every changed file and analyze for:
- **Injection:** SQL injection, XSS, command injection, path traversal, template injection
- **Auth/access:** broken authentication, missing authorization checks, privilege escalation
- **Data exposure:** information leakage, insecure direct object references, verbose errors revealing internals
- **Crypto:** weak hashing, hardcoded salts, insecure random number generation, missing encryption
- **Dependencies:** known-vulnerable packages (check lock files if changed), insecure imports
- **OWASP Top 10:** any other applicable categories for the language/framework in use

For each file, think through how an attacker could exploit the code. Consider the context — is this a public endpoint, internal service, or CLI tool? Calibrate severity accordingly.

**Reporting:**

- **Issues found:** Stop. Report each issue with:
  - File and line number
  - Vulnerability class (e.g., "SQL Injection", "Broken Access Control")
  - Severity: critical / high / medium / low
  - Explanation of the attack vector
  - Suggested fix
  Do not continue past critical or high severity issues. Medium/low issues: warn and ask user whether to proceed.
- **Clean:** Proceed.

### Gate 5: Commit

1. Stage changes: `git add` relevant files (avoid blindly adding all)
2. Draft commit message based on item ID and name
3. Present for user approval
4. Commit

### Gate 6: Push

*Full pipeline only. Skip for light pipeline.*

```
git push -u origin <branch-name>
```

If push fails, stop and report.

### Gate 7: Create Pull Request

*Full pipeline only. Skip for light pipeline.*

Create PR with:
- Title derived from item ID and name (e.g., "f003: Auth system" or "t005: Fix button color")
- Body summarizing what was built and why
- Reference to plan in `.lo/work/` if applicable

After creating the PR, enable auto-merge:

```
gh pr merge <PR-NUMBER> --auto --squash
```

This allows the PR to merge automatically once CI passes and CodeRabbit approves. Report the PR URL.

### Gate 8: Clean Up

Detect item type from ID prefix and handle accordingly:

**For features (`f{NNN}`):**
1. Delete `.lo/work/f{NNN}-slug/` entirely (git history preserves everything)
2. Feature was already removed from BACKLOG.md at plan time — no backlog update needed

**For tasks (`t{NNN}`):**
1. Mark the task checkbox done in BACKLOG.md: `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD`
2. If `.lo/work/t{NNN}-slug/` exists, delete it
3. Update `updated:` date in BACKLOG.md

### Gate 9: Wrap-up Prompts

    Shipped: <f{NNN}|t{NNN}> "<name>"

    PR: [url] (full pipeline only)
    Cleaned: .lo/work/<slug>/ removed

    Update the stream? Run /lo:stream to capture this milestone.
    Anything reusable worth capturing? Run /lo:solution, or "no" to skip.

## Pipeline Summary

**Full pipeline** (feature/fix branch):

    Ship complete: f{NNN} "<name>"
      Tests:    passed (N tests)
      Simplify: [N changes | clean]
      Security: clean (static + vuln sweep)
      Commit:   <hash> "<message>"
      Push:     origin/<branch>
      PR:       <url> (auto-merge enabled)
      Cleaned: .lo/work/f{NNN}-slug/ removed

**Light pipeline** (main branch, tasks):

    Ship complete: t{NNN} "<name>"
      Tests:    passed (N tests)
      Security: clean (static + vuln sweep)
      Commit:   <hash> "<message>"
      Done:     t{NNN} marked complete in backlog

## Error Recovery

    Ship stopped at Gate N: <gate-name>
    Item: <f{NNN}|t{NNN}> "<name>"
    Pipeline: [full | light]
    Issue: [what failed]
    Fix: [suggestion]
    After fixing, run /lo:ship again.

Pipeline always restarts from Gate 1 (gates are cheap, ensures consistency).

## Examples

### Full pipeline (feature branch)

    User: /lo:ship

    Agent checks branch → on feat/f003-user-auth
    Identifies item: f003 "User Authentication"

    Gate 1: Pre-flight ✓
    Gate 2: Tests — 47 passed ✓
    Gate 3: Simplify — 2 suggestions applied ✓
    Gate 4: Security — clean ✓
    Gate 5: Commit — abc1234 "feat(f003): user authentication" ✓
    Gate 6: Push — origin/feat/f003-user-auth ✓
    Gate 7: PR — github.com/org/repo/pull/42 (auto-merge enabled) ✓
    Gate 8: Clean up — .lo/work/f003-user-auth/ removed ✓
    Gate 9: Wrap-up ✓

    Shipped: f003 "User Authentication"
    Update the stream? Run /lo:stream to capture this milestone.

### Light pipeline (task on main)

    User: /lo:ship

    Agent checks branch → on main
    Asks: full pipeline or quick ship?
    User picks quick ship → identifies t005 "Update dependency versions"

    Gate 1: Pre-flight ✓
    Gate 2: Tests — 47 passed ✓
    Gate 4: Security — clean ✓
    Gate 5: Commit — def5678 "chore(t005): update dependency versions" ✓
    Gate 8: Done — t005 marked complete in backlog ✓
    Gate 9: Wrap-up ✓

    Shipped: t005 "Update dependency versions"
