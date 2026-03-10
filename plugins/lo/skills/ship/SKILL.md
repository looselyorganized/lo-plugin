---
name: ship
description: Quality pipeline for shipping completed work. Detects context automatically — Explore/Closed pushes to main, Build/Open on a feature branch pushes the branch, Build/Open on a semver release branch finalizes the release (changelog, PR, tag). Use when user says "ship it", "ready to merge", "ship this", "done with", "mark done", "/ship", or when work is complete.
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

Ships completed work. Detects what to do from project status and branch name. One command for everything.

| Context | Behavior |
|---------|----------|
| Explore/Closed | Merge to main (if needed) and push |
| Build/Open + feature branch | Commit and push feature branch |
| Build/Open + semver branch | **Release ship** — changelog, cleanup, PR to main, tag |

## When to Use

- User invokes `/lo:ship`
- User says "ship it", "ready to merge", "done with"
- Work has been completed via `/lo:work`
- Ready to finalize a release (on the release branch)

## Critical Rules

- Run every gate in order. If any gate fails, stop and report.
- Prompt for stream update and solution capture after shipping — respect "no".

## Pipeline Gates

1. Pre-flight
2. EARS audit (if applicable)
3. Tests
4. Reviewer (secrets, security, dead code)
5. Commit + Push
6. Wrap-up

**Release ship** (semver branch) adds between gates 4 and 5:
- Changelog generation
- Work artifact cleanup

---

### Gate 1: Pre-flight

1. **Read project status:** Read `.lo/PROJECT.md` frontmatter `status` field.

2. **Detect mode from branch:** Check `git branch --show-current`.

   | Status | Branch | Mode |
   |--------|--------|------|
   | Explore/Closed | any | **Fast mode** — commit, push to main |
   | Build/Open | feature/fix branch | **Feature mode** — commit, push branch |
   | Build/Open | semver branch (e.g. `0.4.0`) | **Release mode** — full release pipeline |

3. **Working tree status:** Check `git status`. If uncommitted changes, ask whether to include or stash.

4. **Identify the item:** Map branch name to feature/task ID. Cross-reference with `.lo/BACKLOG.md` and `.lo/work/` directory. For release mode, the "item" is the release itself.

5. **Determine diff base:** Find the integration base (`main`, release branch, etc.). Store as `DIFF_BASE`.

### Gate 2: EARS Requirements Audit

*Only runs if `ears-requirements.md` exists in the work directory.*

1. Parse all `REQ-*` requirement IDs and their statements
2. For each requirement, verify it was addressed:
   - Check plan task references (tasks citing `REQ-*` IDs marked `[x]`)
   - Scan changed files (`git diff --name-only $DIFF_BASE...HEAD`) for matching behavior
   - Mark each as: **covered**, **partial**, or **uncovered**
3. Report coverage summary
4. **Uncovered or partial:** Ask the user — implement now, defer, or out of scope.

*Skipped in release mode — individual features already passed EARS during their own ship.*

### Gate 3: Run Tests

Detect the project's test runner and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed.

### Gate 4: Reviewer

Invoke the `reviewer` subagent (defined in `.claude-plugin/agents/reviewer.md`) to review the diff.

1. Get the diff: `git diff $DIFF_BASE...HEAD`
2. Dispatch the `reviewer` subagent, passing the diff and changed file list
3. The reviewer checks for: secrets, security (OWASP), dead code, obvious bugs
4. **CLEAN** → proceed
5. **ISSUES FOUND** → present to user. Critical/high: stop. Medium/low: warn, ask.

### Release Mode: Changelog + Cleanup

*Only runs when on a semver branch (release mode). Inserted between Gate 4 and Gate 5.*

**Generate Changelog:**

1. Read `.lo/work/*/` — plan files, EARS requirements, feature names
2. Read BACKLOG.md — active features and tasks worked on
3. Read commits: `git log main..<version> --pretty=format:"%H|%ad|%s" --date=short`
4. Use all three sources to write a rich changelog — what was built and why, not just commit messages
5. Group into categories:

   | Prefix/pattern | Category |
   |---------------|----------|
   | `feat:`, `feat(*):` | Added |
   | `fix:`, `fix(*):` | Fixed |
   | `chore:`, `refactor:` | Changed |
   | `docs:` | Documentation |
   | `BREAKING CHANGE:`, `!:` | Breaking |

6. Write or update `CHANGELOG.md`. Present entry for user review.
7. Commit: `git commit -m "docs: changelog for <version>"`

**Clean up work artifacts:**

1. Scan `.lo/work/` for directories related to this release
2. Delete each work directory (git history preserves everything)
3. Update BACKLOG.md: features → `[done](v<version>) YYYY-MM-DD`, tasks → checked + `[done](v<version>) YYYY-MM-DD`
4. Update `updated:` date in BACKLOG.md
5. Commit: `git commit -m "chore: clean up work artifacts for v<version>"`

### Gate 5: Commit + Push

**Commit** (fast mode and feature mode only — release mode already committed above):
1. Stage changes: `git add` relevant files
2. Draft commit message based on item ID and name
3. Present for user approval
4. Commit

**Push:**

| Mode | Action |
|------|--------|
| Fast mode | Merge to main if on feature branch, then `git push origin main` |
| Feature mode | `git push -u origin <feature-branch>` |
| Release mode | `git push -u origin <version>`, open PR: `gh pr create --base main --head <version> --title "release: v<version>" --body "<changelog summary>"`, enable auto-merge: `gh pr merge <PR> --auto --merge` |

Use `--merge` (not `--squash`) for release PRs to preserve branch history.

If push fails, stop and report.

### Gate 6: Wrap-up

**Fast mode (Explore/Closed):**
- Mark done in BACKLOG.md (`[done] YYYY-MM-DD` — no version in Explore), delete `.lo/work/` directory, update dates
- Commit cleanup: `git add .lo/BACKLOG.md && git rm -r .lo/work/<item>/` then `git commit -m "chore: mark <item> done, clean up work artifacts"`
- Push: `git push origin main`

**Feature mode (Build/Open + feature branch):**
- Leave work directories and BACKLOG.md unchanged — release ship needs them for changelog

**Release mode (Build/Open + semver branch):**
- Cleanup already done above. Report PR URL and stop:

      Release PR opened: <url>
      Auto-merge enabled — will merge when CI and reviews pass.

      After the PR merges, run: /lo:ship tag

Do NOT poll or wait. The user resumes when the PR has merged.

**Prompt (all modes):**

    Shipped: <item> "<name>"

    Update the stream? Run /lo:stream to capture this milestone.
    Anything reusable? Run /lo:solution, or "no" to skip.

---

## Tag (resume point)

`/lo:ship tag` finishes a release after the PR has merged.

```bash
git checkout main
git pull origin main
git tag -a v<version> -m "v<version>"
git push origin --tags
```

Delete the release branch:

```bash
git branch -d <version>
git push origin --delete <version>
```

Report:

    Release shipped: v<version>

      Tag:       v<version>
      Changelog: CHANGELOG.md updated
      Cleaned:   work artifacts removed, branches deleted

    Next: /lo:stream to capture this as a milestone.

---

## Pipeline Summary

**Fast mode (Explore/Closed):**

    Ship complete: f{NNN} "<name>"
      Tests:    passed (N tests)
      Reviewer: clean
      Commit:   <hash> "<message>"
      Pushed:   main
      Backlog:  marked done

**Feature mode (Build/Open + feature branch):**

    Ship complete: f{NNN} "<name>"
      EARS:     [N/N covered | skipped]
      Tests:    passed (N tests)
      Reviewer: clean
      Commit:   <hash> "<message>"
      Pushed:   origin/<branch>

**Release mode (Build/Open + semver branch):**

    Release: v<version>
      Tests:     passed (N tests)
      Reviewer:  clean
      Changelog: generated
      Cleanup:   N work dirs removed
      PR:        #NNN opened, auto-merge enabled
      After merge: /lo:ship tag

## Error Recovery

    Ship stopped at Gate N: <gate-name>
    Item: <item> "<name>"
    Mode: [fast | feature | release]
    Issue: [what failed]
    Fix: [suggestion]
    After fixing, run /lo:ship again.

## Examples

### Explore — fast mode

    User: /lo:ship (on feat/f003-auth, project status: Explore)

    Gate 1: Pre-flight — Explore, fast mode ✓
    Gate 3: Tests — 47 passed ✓
    Gate 4: Reviewer — clean ✓
    Gate 5: Commit + Push — abc1234, pushed to main ✓
    Gate 6: Wrap-up — backlog updated ✓

    Shipped: f003 "User Authentication"

### Build/Open — feature mode

    User: /lo:ship (on feat/f003-auth, project status: Build)

    Gate 1: Pre-flight — Build, feature mode ✓
    Gate 2: EARS — 22/22 covered ✓
    Gate 3: Tests — 47 passed ✓
    Gate 4: Reviewer — clean ✓
    Gate 5: Commit + Push — abc1234, origin/feat/f003-user-auth ✓
    Gate 6: Wrap-up ✓

    Shipped: f003 "User Authentication"

### Build/Open — release mode

    User: /lo:ship (on branch 0.4.0, project status: Build)

    Gate 1: Pre-flight — Build, release mode ✓
    Gate 3: Tests — 12 passed ✓
    Gate 4: Reviewer — clean ✓
    Changelog: generated, reviewed ✓
    Cleanup: 2 work dirs removed, backlog updated ✓
    Gate 5: Push + PR — #42 opened, auto-merge enabled ✓

    After the PR merges, run: /lo:ship tag

### Tagging after merge

    User: /lo:ship tag

    Tagged: v0.4.0
    Branch 0.4.0 deleted (local + remote)
    Release shipped: v0.4.0
