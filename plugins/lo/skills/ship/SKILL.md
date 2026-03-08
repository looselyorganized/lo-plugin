---
name: ship
description: Quality pipeline for shipping completed work. Behavior adapts to project status — Explore/Closed ships fast to main, Build/Open commits to feature branch for release coordination. Stops if any gate fails. Use when user says "ship it", "ready to merge", "ship this", "push and PR", "done with", "mark done", "/ship", or when work execution is complete.
metadata:
  version: 0.3.2
  author: LORF
---

# LO Ship Pipeline

Runs the quality pipeline to ship completed work. Each gate must pass before proceeding. Stops and reports if any gate fails.

Pipeline behavior depends on **project status** (from `.lo/PROJECT.md`) and **branch context**:

- **Explore/Closed** — Ship fast. Commit, push to main, done. No PR ceremony, no release coordination.
- **Build/Open** — Ship to feature branch. Commit + push branch (for backup), but do NOT create a PR or merge to main. That's `/lo:release ship`'s job.
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

1. **Read project status:** Read `.lo/PROJECT.md` frontmatter `status` field. This determines pipeline behavior at Gates 7-8.

   | Status | Pipeline mode |
   |--------|--------------|
   | `Explore` / `Closed` | **Fast mode** — commit, push to main, done |
   | `Build` / `Open` | **Release mode** — commit, push feature branch (backup), no PR. `/lo:release ship` handles the merge. |

2. **Branch check:** Check `git branch --show-current`.
   - If on a feature/fix branch → **full pipeline** (Gates 1-9).
   - If on main/master → ask the user:

         You're on main. Two options:

         1. Create a branch and run full pipeline (recommended)
         2. Quick ship — tests + security + commit on main, mark done (for small tasks)

     If they choose option 1, create the branch and proceed with full pipeline.
     If they choose option 2, proceed with **light pipeline** (Gates 1, 3, 5, 6, 8, 9).
     Light pipeline is only available for tasks (`t{NNN}`). If the user is shipping a feature on main, recommend option 1.

3. **Working tree status:** Check `git status`. If uncommitted changes, ask whether to include or stash.
4. **Identify the item:** Map branch name (e.g., `feat/f003-auth-system` or `fix/t005-slug`) to the feature/task ID. On main, ask the user which backlog item this work completes. Cross-reference with `.lo/work/` directory and BACKLOG.md entry. If unclear, ask.

### Gate 2: EARS Requirements Audit

*Only runs if `ears-requirements.md` exists in the work directory.*

Check `.lo/work/f{NNN}-slug/ears-requirements.md`. If present:

1. Parse all `REQ-*` requirement IDs and their statements
2. For each requirement, verify it was addressed by the implementation:
   - Check plan task references (tasks that cite `REQ-*` IDs and are marked `[x]`)
   - Scan changed files (`git diff --name-only main...HEAD`) for behavior matching the requirement
   - Mark each requirement as: **covered**, **partial**, or **uncovered**
3. Report:

        EARS audit: ears-requirements.md
          REQ-T01: covered ✓
          REQ-T02: covered ✓
          REQ-A01: covered ✓
          REQ-A02: partial — missing retry logic
          REQ-X01: uncovered — no auth between services

        Coverage: 18/22 covered, 2 partial, 2 uncovered

4. **Uncovered or partial requirements:**
   - Ask the user for each: **implement now**, **defer to next iteration**, or **out of scope** (with rationale)
   - If "implement now" → stop pipeline, redirect to `/lo:work`
   - If "defer" or "out of scope" → note the decision, proceed to Gate 3
   - Update `ears-requirements.md` status to `updated` and add a `## Deferred` section listing deferred REQ-* IDs with rationale

This gate is informational for partial/uncovered items — it surfaces gaps but lets the user decide. It does NOT auto-fail the pipeline.

### Gate 3: Run Tests

Detect the project's test runner (package.json scripts, Cargo.toml, pyproject.toml, etc.) and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed without tests.

### Gate 4: Code Simplification

*Full pipeline only. Skip for light pipeline.*

1. Identify changed files: `git diff --name-only main...HEAD`
2. Review for: unnecessary complexity, dead code, verbose patterns, duplication
3. If simplifications found → present them, ask whether to apply
4. If clean → proceed

### Gate 5: Security Review

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

### Gate 6: Commit

1. Stage changes: `git add` relevant files (avoid blindly adding all)
2. Draft commit message based on item ID and name
3. Present for user approval
4. Commit

### Gate 7: Push

*Full pipeline only. Skip for light pipeline.*

Behavior depends on project status (determined in Gate 1):

**Explore/Closed (fast mode):**

Push directly to main. If on a feature branch, merge to main first, then push:

```bash
git checkout main
git merge <branch-name> --no-ff -m "feat(<item-id>): <name>"
git push origin main
```

**Build/Open (release mode):**

Push the feature branch for backup, but do NOT merge to main or create a PR:

```bash
git push -u origin <branch-name>
```

Report:

    Pushed: origin/<branch-name> (backup)
    To merge: run /lo:release ship when the release is ready.

If push fails, stop and report.

### Gate 8: Clean Up

Behavior depends on project status:

**Explore/Closed — clean up now:**

Work artifacts are no longer needed. Clean up immediately.

*For features (`f{NNN}`):*
1. Delete `.lo/work/f{NNN}-slug/` entirely (git history preserves everything)
2. Feature was already removed from BACKLOG.md at plan time — no backlog update needed

*For tasks (`t{NNN}`):*
1. Mark the task checkbox done in BACKLOG.md: `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD`
2. If `.lo/work/t{NNN}-slug/` exists, delete it
3. Update `updated:` date in BACKLOG.md

**Build/Open — leave artifacts for release:**

Do NOT delete work dirs or update BACKLOG.md. `/lo:release ship` needs these artifacts to generate the changelog (plan files, EARS requirements, backlog entries). Release ship handles cleanup after the changelog is written.

### Gate 9: Wrap-up Prompts

**Explore/Closed:**

    Shipped: <f{NNN}|t{NNN}> "<name>"

    Merged to main and pushed.
    Cleaned: .lo/work/<slug>/ removed

    Update the stream? Run /lo:stream to capture this milestone.
    Anything reusable worth capturing? Run /lo:solution, or "no" to skip.

**Build/Open:**

    Shipped: <f{NNN}|t{NNN}> "<name>"

    Branch: origin/<branch-name> (pushed)
    Work artifacts preserved for /lo:release ship changelog.

    Run /lo:release ship when the release is ready.
    Anything reusable worth capturing? Run /lo:solution, or "no" to skip.

## Pipeline Summary

**Explore/Closed — fast mode** (feature/fix branch):

    Ship complete: f{NNN} "<name>"
      EARS:     [N/N covered | skipped (no EARS)]
      Tests:    passed (N tests)
      Simplify: [N changes | clean]
      Security: clean (static + vuln sweep)
      Commit:   <hash> "<message>"
      Merged:   to main, pushed
      Cleaned:  .lo/work/f{NNN}-slug/ removed

**Build/Open — release mode** (feature/fix branch):

    Ship complete: f{NNN} "<name>"
      EARS:     [N/N covered | skipped (no EARS)]
      Tests:    passed (N tests)
      Simplify: [N changes | clean]
      Security: clean (static + vuln sweep)
      Commit:   <hash> "<message>"
      Pushed:   origin/<branch> (backup, no PR)
      Work:     artifacts preserved for changelog
      Next:     /lo:release ship to finalize

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

### Explore — fast mode (feature branch)

    User: /lo:ship

    Agent reads PROJECT.md → status: Explore
    Agent checks branch → on feat/f003-user-auth
    Identifies item: f003 "User Authentication"

    Gate 1: Pre-flight — Explore, fast mode ✓
    Gate 2: EARS — 22/22 requirements covered ✓
    Gate 3: Tests — 47 passed ✓
    Gate 4: Simplify — 2 suggestions applied ✓
    Gate 5: Security — clean ✓
    Gate 6: Commit — abc1234 "feat(f003): user authentication" ✓
    Gate 7: Merged to main, pushed ✓
    Gate 8: Clean up — .lo/work/f003-user-auth/ removed ✓
    Gate 9: Wrap-up ✓

    Shipped: f003 "User Authentication"
    Update the stream? Run /lo:stream to capture this milestone.

### Build/Open — release mode (feature branch)

    User: /lo:ship

    Agent reads PROJECT.md → status: Build
    Agent checks branch → on feat/f003-user-auth (on release branch 0.3.2)
    Identifies item: f003 "User Authentication"

    Gate 1: Pre-flight — Build, release mode ✓
    Gate 2: EARS — 22/22 requirements covered ✓
    Gate 3: Tests — 47 passed ✓
    Gate 4: Simplify — clean ✓
    Gate 5: Security — clean ✓
    Gate 6: Commit — abc1234 "feat(f003): user authentication" ✓
    Gate 7: Pushed origin/feat/f003-user-auth (backup, no PR) ✓
    Gate 8: Work artifacts preserved for changelog ✓
    Gate 9: Wrap-up ✓

    Shipped: f003 "User Authentication"
    Branch pushed. Work artifacts preserved. Run /lo:release ship to finalize.

### Light pipeline (task on main)

    User: /lo:ship

    Agent checks branch → on main
    Asks: full pipeline or quick ship?
    User picks quick ship → identifies t005 "Update dependency versions"

    Gate 1: Pre-flight ✓
    Gate 3: Tests — 47 passed ✓
    Gate 5: Security — clean ✓
    Gate 6: Commit — def5678 "chore(t005): update dependency versions" ✓
    Gate 8: Done — t005 marked complete in backlog ✓
    Gate 9: Wrap-up ✓

    Shipped: t005 "Update dependency versions"
