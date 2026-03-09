---
name: ship
description: Quality pipeline for shipping completed work. Behavior adapts to project status — Explore/Closed commits and pushes directly to main; Build/Open commits to feature branch for release coordination. Stops if any gate fails. Use when user says "ship it", "ready to merge", "ship this", "done with", "mark done", "/ship", or when work execution is complete.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
---

# LO Ship Pipeline

Runs the quality pipeline to ship completed work. Each gate must pass before proceeding. Stops and reports if any gate fails.

Pipeline behavior depends on **project status** (from `.lo/PROJECT.md`) and **branch context**:

- **Explore/Closed** — Ship direct to main. Commit and push — no branch, no PR.
- **Build/Open** — Ship to feature branch. Commit + push branch, but do NOT merge to main. That's `/lo:release ship`'s job.

## When to Use

- User invokes `/lo:ship`
- User says "ship it", "ready to merge", "ready to ship", "done with", "mark done"
- Work has been completed via `/lo:work`

## Critical Rules

- Run every pipeline gate in order. Skipping a gate risks shipping broken or insecure code.
- If any gate fails, stop and report what needs fixing.
- Prompt for stream update and solution capture after shipping — but respect "no" as an answer.
- Identify items by their `f{NNN}` ID throughout the pipeline.

## Pipeline Gates

1. Pre-flight
2. EARS audit (if applicable)
3. Tests
4. Reviewer (secrets, security, dead code)
5. Commit + Push
6. Wrap-up

---

### Gate 1: Pre-flight

1. **Read project status:** Read `.lo/PROJECT.md` frontmatter `status` field.

   | Status | Pipeline mode |
   |--------|--------------|
   | `Explore` / `Closed` | **Fast mode** — commit and push directly to main |
   | `Build` / `Open` | **Release mode** — commit, push feature branch. `/lo:release ship` handles the merge. |

2. **Branch check:** Check `git branch --show-current`.
   - **Fast mode**: If on a feature/fix branch, merge it to main first. If already on main, proceed.
   - **Release mode**: If on a feature/fix branch → proceed. If on main → ask user to create a branch first.

3. **Working tree status:** Check `git status`. If uncommitted changes, ask whether to include or stash.

4. **Identify the item:** Map branch name (e.g., `feat/f003-auth-system`) to the feature ID. On main, ask the user which item this work completes. Cross-reference with `.lo/BACKLOG.md` Now section and `.lo/work/` directory.

5. **Determine diff base:** Find the integration base for this branch (`main`, `0.3.2`, etc.). Store as `DIFF_BASE` for all `git diff` operations.

### Gate 2: EARS Requirements Audit

*Only runs if `ears-requirements.md` exists in the work directory (`.lo/work/f{NNN}-slug/ears-requirements.md`).*

1. Parse all `REQ-*` requirement IDs and their statements
2. For each requirement, verify it was addressed:
   - Check plan task references (tasks citing `REQ-*` IDs marked `[x]`)
   - Scan changed files (`git diff --name-only $DIFF_BASE...HEAD`) for matching behavior
   - Mark each as: **covered**, **partial**, or **uncovered**
3. Report coverage summary
4. **Uncovered or partial requirements:**
   - Ask the user: **implement now**, **defer**, or **out of scope**
   - If "implement now" → stop pipeline, redirect to `/lo:work`
   - If "defer" or "out of scope" → note the decision, proceed
   - Update ears file status to `updated` and add a `## Deferred` section

This gate is informational — it surfaces gaps but lets the user decide.

### Gate 3: Run Tests

Detect the project's test runner and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed without tests.

### Gate 4: Reviewer

Invoke the `reviewer` subagent (defined in `.claude-plugin/agents/reviewer.md`) to review the diff for quality issues.

1. Get the diff: `git diff $DIFF_BASE...HEAD`
2. Dispatch the `reviewer` subagent using the Agent tool with `subagent_type: "reviewer"`, passing the diff and changed file list
3. The reviewer checks for:
   - **Secrets**: API keys, tokens, passwords, connection strings
   - **Security**: injection, auth issues, OWASP top 10
   - **Dead code**: unused imports, unreachable branches, commented-out blocks
   - **Obvious bugs**: off-by-one, null derefs, missing error handling

4. **CLEAN** → proceed
5. **ISSUES FOUND** → present issues to user. Critical/high severity: stop. Medium/low: warn, ask whether to proceed.

### Gate 5: Commit + Push

**Commit:**
1. Stage changes: `git add` relevant files (avoid blindly adding all)
2. Draft commit message based on item ID and name
3. Present for user approval
4. Commit

**Push (Explore/Closed — fast mode):**
1. If on a feature branch, merge to main first: `git checkout main && git merge <branch>`
2. Push: `git push origin main`

**Push (Build/Open — release mode):**
1. Push feature branch: `git push -u origin <feature-branch>`
2. Do NOT merge to main — `/lo:release ship` handles that.

If push fails, stop and report.

### Gate 6: Wrap-up

**Update BACKLOG.md:**

*Explore/Closed:*
- For features: update status in BACKLOG.md to `Status: done -> YYYY-MM-DD`
- For tasks: mark done `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD`
- Delete the work directory `.lo/work/f{NNN}-slug/` (git history preserves everything)
- Update `updated:` date in BACKLOG.md

*Build/Open:* Leave work directories and BACKLOG.md unchanged — `/lo:release ship` needs these artifacts for the changelog.

**Prompt:**

    Shipped: f{NNN} "<name>"

    [Explore/Closed]: Pushed to main
    [Build/Open]: Branch: origin/<branch> (pushed)

    Update the stream? Run /lo:stream to capture this milestone.
    Anything reusable worth capturing? Run /lo:solution, or "no" to skip.

## Pipeline Summary

**Explore/Closed — fast mode:**

    Ship complete: f{NNN} "<name>"
      EARS:     [N/N covered | skipped]
      Tests:    passed (N tests)
      Reviewer: clean
      Commit:   <hash> "<message>"
      Pushed:   main
      Backlog:  marked done

**Build/Open — release mode:**

    Ship complete: f{NNN} "<name>"
      EARS:     [N/N covered | skipped]
      Tests:    passed (N tests)
      Reviewer: clean
      Commit:   <hash> "<message>"
      Pushed:   origin/<branch>
      Next:     /lo:release ship to finalize

## Error Recovery

    Ship stopped at Gate N: <gate-name>
    Item: f{NNN} "<name>"
    Issue: [what failed]
    Fix: [suggestion]
    After fixing, run /lo:ship again.

Pipeline always restarts from Gate 1 (gates are cheap, ensures consistency).

## Examples

### Explore — fast mode

    User: /lo:ship

    Gate 1: Pre-flight — Explore, fast mode ✓
    Gate 2: EARS — 22/22 covered ✓
    Gate 3: Tests — 47 passed ✓
    Gate 4: Reviewer — clean ✓
    Gate 5: Commit + Push — abc1234, pushed to main ✓
    Gate 6: Wrap-up — backlog updated ✓

    Shipped: f003 "User Authentication"

### Build/Open — release mode

    User: /lo:ship

    Gate 1: Pre-flight — Build, release mode ✓
    Gate 2: EARS — 22/22 covered ✓
    Gate 3: Tests — 47 passed ✓
    Gate 4: Reviewer — clean ✓
    Gate 5: Commit + Push — abc1234, origin/feat/f003-user-auth ✓
    Gate 6: Wrap-up ✓

    Shipped: f003 "User Authentication"
    Run /lo:release ship to finalize.
