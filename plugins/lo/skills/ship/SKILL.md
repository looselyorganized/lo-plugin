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

Ships completed work. Detects what to do from project status and branch name. One command, three modes.

<critical>
Fast mode (Explore/Closed) commits directly to main. It NEVER creates pull requests.
Only Feature mode and Release mode create PRs.
</critical>

## When to Use

- User invokes `/lo:ship`
- User says "ship it", "ready to merge", "done with"
- Work has been completed via `/lo:work`
- Ready to finalize a release (on the release branch)

## Progress Checklist

Copy this checklist and update it as you proceed. It tracks your mode and gate progress:

```
Ship Progress:
  Mode: [pending detection]
  Item: [pending detection]
  - [ ] Gate 1: Pre-flight
  - [ ] Gate 2: EARS audit
  - [ ] Gate 3: Tests
  - [ ] Gate 4: Reviewer
  - [ ] Gate 5: Ship (mode-specific)
  - [ ] Gate 6: Wrap-up
```

---

## Gate 1: Pre-flight

1. **Read project status:**

```bash
head -20 .lo/PROJECT.md
```

Extract the `status` field from frontmatter.

2. **Detect branch:**

```bash
git branch --show-current
```

3. **Determine mode** using this table:

| Status | Branch | Mode |
|--------|--------|------|
| Explore or Closed | any branch | **fast** |
| Build or Open | feature/fix branch (e.g. `feat/f003-auth`) | **feature** |
| Build or Open | semver branch (e.g. `0.4.0`) | **release** |

4. **Update your checklist** with the detected mode. From this point forward, follow ONLY the sections marked for your mode.

5. **Working tree status:**

```bash
git status
```

If uncommitted changes exist, ask whether to include or stash.

6. **Identify the item:** Map branch name to feature/task ID. Cross-reference with `.lo/BACKLOG.md` and `.lo/work/`. For release mode, the "item" is the release itself.

7. **Determine diff base:**

```bash
# fast mode: diff against main~N or the merge-base
git merge-base main HEAD

# feature mode: diff against the base branch (release branch or main)
git merge-base $(git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || echo main) HEAD

# release mode: diff against main
git merge-base main HEAD
```

Store the result as `DIFF_BASE`.

---

## Gate 2: EARS Requirements Audit

*Skip if mode is **release** — individual features already passed EARS during their own ship.*

*Skip if no `ears-requirements.md` exists in the work directory.*

1. Parse all `REQ-*` requirement IDs and their statements
2. For each requirement, verify it was addressed:
   - Check plan task references (tasks citing `REQ-*` IDs marked `[x]`)
   - Scan changed files for matching behavior:
   ```bash
   git diff --name-only $DIFF_BASE...HEAD
   ```
   - Mark each as: **covered**, **partial**, or **uncovered**
3. Report coverage summary
4. **Uncovered or partial:** Ask the user — implement now, defer, or out of scope.

---

## Gate 3: Run Tests

Detect the project's test runner and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed.

---

## Gate 4: Reviewer

Invoke the `reviewer` subagent (defined in `.claude-plugin/agents/reviewer.md`).

1. Get the diff:
```bash
git diff $DIFF_BASE...HEAD
```
2. Dispatch the `reviewer` subagent, passing the diff and changed file list
3. The reviewer checks for: secrets, security (OWASP), dead code, obvious bugs
4. **CLEAN** → proceed
5. **ISSUES FOUND** → present to user. Critical/high: stop. Medium/low: warn, ask.

---

## Gate 5 + 6: Ship (mode-specific)

Follow ONLY the section matching your detected mode. Do not read the other mode sections.

---

<fast-mode>
### FAST MODE (Explore/Closed)

You are in **fast mode**. Push directly to main. No PR. No auto-merge.

**Commit:**

1. Stage changes: `git add` relevant files
2. Draft commit message based on item ID and name
3. Present for user approval
4. Commit

**Push to main:**

If currently on a feature branch, merge to main first:

```bash
git checkout main
git merge <branch> --no-edit
git push origin main
```

If already on main:

```bash
git push origin main
```

**Wrap-up:**

1. Mark done in BACKLOG.md — use `[done] YYYY-MM-DD` (no version tag in Explore):

```
- [x] f{NNN} Feature Name
  Description.
  [done] YYYY-MM-DD
```

2. Delete the work directory if it exists:

```bash
git rm -r .lo/work/<item>/
```

3. Update `updated:` date in BACKLOG.md frontmatter

4. Commit and push cleanup:

```bash
git add .lo/BACKLOG.md
git commit -m "chore: mark <item> done, clean up work artifacts"
git push origin main
```

5. If a feature branch was merged, delete it:

```bash
git branch -d <branch>
```

**Report:**

```
Ship complete: <item> "<name>"
  Tests:    passed (N tests)
  Reviewer: clean
  Commit:   <hash> "<message>"
  Pushed:   main
  Backlog:  marked done
```

</fast-mode>

---

<feature-mode>
### FEATURE MODE (Build/Open + feature branch)

You are in **feature mode**. Push the feature branch and open a PR.

**Commit:**

1. Stage changes: `git add` relevant files
2. Draft commit message based on item ID and name
3. Present for user approval
4. Commit

**Push and open PR:**

```bash
git push -u origin <feature-branch>
```

```bash
gh pr create \
  --base <release-branch-or-main> \
  --head <feature-branch> \
  --title "<commit message title>" \
  --body "<brief item summary>"
```

```bash
gh pr merge <PR-number> --auto --merge
```

**Wrap-up:**

- Leave work directories and BACKLOG.md unchanged — release ship needs them for changelog.
- Report:

```
Ship complete: <item> "<name>"
  EARS:     [N/N covered | skipped]
  Tests:    passed (N tests)
  Reviewer: clean
  Commit:   <hash> "<message>"
  PR:       #NNN opened, auto-merge enabled
```

</feature-mode>

---

<release-mode>
### RELEASE MODE (Build/Open + semver branch)

You are in **release mode**. Generate changelog, clean up, push, and open PR to main.

**Generate Changelog:**

1. Read `.lo/work/*/` — plan files, EARS requirements, feature names
2. Read BACKLOG.md — active features and tasks
3. Read commits:
```bash
git log main..<version> --pretty=format:"%H|%ad|%s" --date=short
```
4. Write a rich changelog — what was built and why, not just commit messages
5. Group into categories:

| Prefix/pattern | Category |
|---------------|----------|
| `feat:`, `feat(*):` | Added |
| `fix:`, `fix(*):` | Fixed |
| `chore:`, `refactor:` | Changed |
| `docs:` | Documentation |
| `BREAKING CHANGE:`, `!:` | Breaking |

6. Write or update `CHANGELOG.md`. Present entry for user review.
7. Commit:
```bash
git add CHANGELOG.md
git commit -m "docs: changelog for <version>"
```

**Create stream milestone:**

This runs **before cleanup** so work artifacts are still available for context.

1. Gather context for the stream entry:
   - Version number
   - Feature names from `.lo/work/*/` and BACKLOG.md
   - Key decisions and summaries from plan files in `.lo/work/*/`
2. Draft a stream entry using the XML format (see stream skill `references/stream-format.md`):
   ```markdown
   <entry>
   date: YYYY-MM-DD
   title: "Release title"
   version: "<version>"
   <description>
   1-3 sentences. Public voice.
   </description>
   </entry>
   ```
3. Present for user review — the user edits the narrative voice
4. Prepend to `.lo/STREAM.md` after the YAML frontmatter (newest entries first)
5. Commit:
```bash
git add .lo/STREAM.md
git commit -m "docs: stream milestone for v<version>"
```

**Clean up work artifacts:**

1. Scan `.lo/work/` for directories related to this release
2. Delete each work directory (git history preserves everything)
3. Update BACKLOG.md: features → `[done] v<version> YYYY-MM-DD`, tasks → checked + `[done] v<version> YYYY-MM-DD`
4. Update `updated:` date in BACKLOG.md
5. Commit:
```bash
git add .lo/
git commit -m "chore: clean up work artifacts for v<version>"
```

**Push and open PR:**

```bash
git push -u origin <version>
```

```bash
gh pr create \
  --base main \
  --head <version> \
  --title "release: v<version>" \
  --body "<changelog summary>"
```

```bash
gh pr merge <PR-number> --auto --merge
```

Use `--merge` (not `--squash`) to preserve branch history.

**Wrap-up:**

Report and stop. Do NOT poll or wait for the PR to merge.

```
Release: v<version>
  Tests:     passed (N tests)
  Reviewer:  clean
  Changelog: generated
  Stream:    milestone created
  Cleanup:   N work dirs removed
  PR:        #NNN opened, auto-merge enabled

  After the PR merges, run: /lo:ship tag
```

</release-mode>

---

## Post-ship Prompt

After reporting, prompt based on mode:

**Fast mode and Feature mode:**
```
Shipped: <item> "<name>"

Worth a milestone? Run /lo:stream to capture it.
Anything reusable? Run /lo:solution, or "no" to skip.
```

**Release mode:** Stream milestone already created during the pipeline. Only prompt for solution:
```
Shipped: v<version>

Anything reusable? Run /lo:solution, or "no" to skip.
```

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

```
Release shipped: v<version>

  Tag:       v<version>
  Changelog: CHANGELOG.md updated
  Stream:    milestone already captured
  Cleaned:   work artifacts removed, branches deleted
```

---

## Error Recovery

If any gate fails:

```
Ship stopped at Gate N: <gate-name>
  Item:  <item> "<name>"
  Mode:  [fast | feature | release]
  Issue: [what failed]
  Fix:   [suggestion]

  After fixing, run /lo:ship again.
```

---

## Examples

<example name="explore-fast-mode">
User: /lo:ship (on feat/f003-auth, project status: Explore)

Gate 1: Pre-flight — status=Explore, branch=feat/f003-auth → **fast mode** ✓
Gate 2: EARS — skipped (no ears-requirements.md) ✓
Gate 3: Tests — 47 passed ✓
Gate 4: Reviewer — clean ✓
Gate 5+6: Fast mode ship
  - Committed: abc1234 "feat: user authentication"
  - Merged feat/f003-auth → main
  - Pushed to main
  - Backlog: f003 marked done
  - Deleted branch feat/f003-auth

Ship complete: f003 "User Authentication"
</example>

<example name="build-feature-mode">
User: /lo:ship (on feat/f003-auth, project status: Build)

Gate 1: Pre-flight — status=Build, branch=feat/f003-auth → **feature mode** ✓
Gate 2: EARS — 22/22 covered ✓
Gate 3: Tests — 47 passed ✓
Gate 4: Reviewer — clean ✓
Gate 5+6: Feature mode ship
  - Committed: abc1234 "feat: user authentication"
  - Pushed feat/f003-auth
  - PR #15 opened, auto-merge enabled

Ship complete: f003 "User Authentication"
</example>

<example name="build-release-mode">
User: /lo:ship (on branch 0.4.0, project status: Build)

Gate 1: Pre-flight — status=Build, branch=0.4.0 → **release mode** ✓
Gate 2: EARS — skipped (release mode) ✓
Gate 3: Tests — 12 passed ✓
Gate 4: Reviewer — clean ✓
Gate 5+6: Release mode ship
  - Changelog generated, reviewed
  - Stream milestone created, reviewed
  - 2 work dirs removed, backlog updated
  - Pushed 0.4.0
  - PR #42 opened, auto-merge enabled

After the PR merges, run: /lo:ship tag
</example>

<example name="tag-after-merge">
User: /lo:ship tag

Tagged: v0.4.0
Branch 0.4.0 deleted (local + remote)
Release shipped: v0.4.0
</example>
