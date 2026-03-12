---
name: lo-ship
description: Quality pipeline for shipping completed work. Detects mode automatically from project status and branch name — fast mode pushes to main, feature mode opens a PR, release mode generates changelog and finalizes the release. Prunes done items from backlog. Use when user says "ship it", "done", "ready to merge", "push this", or "/lo:ship".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Agent
metadata:
  author: looselyorganized
  version: 0.6.0
---

# LO Ship

Ships completed work. Detects what to do from project status and branch name. One command, three modes. Also starts releases.

<critical>
Fast mode (Explore/Closed) commits directly to main. It NEVER creates pull requests.
Only Feature mode and Release mode create PRs.
</critical>

## When to Use

- `/lo:ship` — ship current work (mode auto-detected)
- `/lo:ship release <version>` — start a new release
- `/lo:ship release bump patch|minor|major` — start release with auto-increment
- `/lo:ship tag` — post-merge: tag release, delete branch

## Starting a Release

When invoked as `/lo:ship release <version>` or `/lo:ship release bump <level>`:

1. Read `.lo/project.yml` — verify status is `build` or `open`
2. Find version source: `plugin.json`, `package.json`, or similar
3. Determine version (explicit or bump from current)
4. Create release branch: `git checkout -b <version>`
5. Update version in source file, commit: `chore: bump version to <version>`
6. Push branch: `git push -u origin <version>`
7. Report:
   ```
   Release started: <version>
   Branch: <version>

   Work on this branch, then run /lo:ship to finalize.
   ```

If no version provided, show current version and ask for bump level.

---

## Gate 1: Pre-flight

1. Read `.lo/project.yml` → extract status
2. Detect branch: `git branch --show-current`
3. Determine mode:

| Status | Branch | Mode |
|--------|--------|------|
| explore or closed | any | **fast** |
| build or open | feature/fix branch | **feature** |
| build or open | semver branch | **release** |

4. Check working tree — if uncommitted changes, ask whether to include or stash
5. Identify the item: map branch name to feature/task ID, cross-reference BACKLOG.md
6. Determine diff base: `git merge-base <base-branch> HEAD`

---

## Gate 2: EARS Requirements Audit

*Skip if: Explore, Closed, or Release mode (features already passed EARS individually).*
*Skip if: no `ears-requirements.md` exists in the work directory.*

1. Parse all `REQ-*` IDs from the EARS document
2. Verify each was addressed — check plan tasks marked `[x]` and changed files
3. Report coverage: **covered**, **partial**, or **uncovered**
4. Uncovered or partial → ask user: implement now, defer, or out of scope

---

## Gate 3: Run Tests

<test-gate-explore>
**Explore / Closed** — Skip entirely.
</test-gate-explore>

<test-gate-build>
**Build** — Detect test runner, run tests.
- Pass → proceed. Fail → stop. No tests found → proceed with note.
</test-gate-build>

<test-gate-open>
**Open** — Run tests AND dependency audit.
- Tests: Pass → continue. Fail → stop. No tests → hard stop ("Open requires tests").
- Audit: `npm audit --audit-level=critical` (or equivalent). Critical vulns → stop.
</test-gate-open>

---

## Gate 4: Reviewer

*Skip if: Explore or Closed.*

1. Get diff: `git diff $DIFF_BASE...HEAD`
2. Dispatch the `reviewer` subagent with the diff and changed file list
3. Reviewer checks: secrets, security (OWASP), dead code, obvious bugs
4. Clean → proceed. Issues → present to user. Critical/high: stop. Medium/low: warn, ask.

---

## Gate 5: README Staleness

*Skip if: Explore or Closed.*

1. Check if README.md exists — if missing, warn and ask
2. Compare dates — if code changed 30+ days after README, flag as potentially stale
3. User decides: update, skip, or confirm current

---

## Gate 6 + 7: Ship (mode-specific)

Follow ONLY the section matching your detected mode.

---

<fast-mode>
### FAST MODE (Explore/Closed)

Push directly to main. No PR.

**Commit:**
1. Stage changes, draft commit message, present for approval, commit

**Push:**
- If on a feature branch: merge to main first, then push
- If on main: push directly

**Backlog + cleanup:**
1. Mark current item done in BACKLOG.md: `[done] YYYY-MM-DD`
2. **Prune all done items** from BACKLOG.md:
   - Remove ALL entries marked `[done]` (including previously-done items)
   - Keep `last_feature` and `last_task` frontmatter counters intact
   - Clean up any empty section headers left behind
3. Delete `.lo/park/<id>-*.md` if it exists for the shipped item
4. Delete `.lo/work/<id>-slug/` if it exists
5. Update `updated:` date in BACKLOG.md frontmatter
6. Commit cleanup: `chore: mark <item> done, prune backlog`
7. Push to main
8. Delete feature branch if one was merged

**Report:**
```
Ship complete: <item> "<name>"
  Commit: <hash> "<message>"
  Pushed: main
  Backlog: pruned
```
</fast-mode>

---

<feature-mode>
### FEATURE MODE (Build/Open + feature branch)

Push the feature branch and open a PR.

**Commit:**
1. Stage changes, draft commit message, present for approval, commit

**Push and PR:**
```bash
git push -u origin <feature-branch>
gh pr create --base <release-branch-or-main> --head <feature-branch> \
  --title "<message>" --body "<item summary>"
gh pr merge <PR> --auto --merge
```

**Cleanup:**
- Leave BACKLOG.md unchanged — release ship needs the entries for changelog
- Delete `.lo/park/<id>-*.md` if it exists (park was consumed by plan)

**Report:**
```
Ship complete: <item> "<name>"
  EARS: [N/N covered | skipped]
  Tests: passed (N tests)
  Reviewer: clean
  Commit: <hash>
  PR: #NNN opened, auto-merge enabled
```
</feature-mode>

---

<release-mode>
### RELEASE MODE (Build/Open + semver branch)

Generate changelog, clean up, push, and open PR to main.

**Generate changelog:**
1. Read `.lo/work/*/` plan files, BACKLOG.md features/tasks, and git commits
2. Synthesize into categorized changelog (Added/Changed/Fixed/Removed) — see `references/changelog-format.md`
3. Present for user review, then write/update `CHANGELOG.md`
4. Commit: `docs: changelog for <version>`

**Create stream milestone:**
Run BEFORE cleanup (work artifacts still available for context):
1. Draft stream entry with version, feature names, key decisions
2. Present for user review
3. Prepend to `.lo/STREAM.md`
4. Commit: `docs: stream milestone for v<version>`

**Backlog + cleanup:**
1. Mark release items done: `[done] v<version> YYYY-MM-DD`
2. **Prune all done items** from BACKLOG.md (same logic as fast mode)
3. Delete `.lo/park/` files for all shipped items
4. Delete `.lo/work/` directories for all shipped items
5. Update `updated:` date in BACKLOG.md
6. Commit: `chore: clean up work artifacts for v<version>`

**Push and PR:**
```bash
git push -u origin <version>
gh pr create --base main --head <version> \
  --title "release: v<version>" --body "<changelog summary>"
gh pr merge <PR> --auto --merge
```

**Report:**
```
Release: v<version>
  Changelog: generated
  Stream: milestone created
  Cleanup: N work dirs removed, backlog pruned
  PR: #NNN opened, auto-merge enabled

  After the PR merges, run: /lo:ship tag
```
</release-mode>

---

## Post-ship Prompt

<post-ship>
After reporting:

**Fast mode and Feature mode:**
```
Worth a milestone? → /lo:stream
Anything reusable? → /lo:solution
("no" to skip)
```

**Release mode:** Stream was already captured in the pipeline.
```
Anything reusable? → /lo:solution
("no" to skip)
```
</post-ship>

---

## Tag (resume point)

`/lo:ship tag` finishes a release after the PR has merged.

```bash
git checkout main
git pull origin main
git tag -a v<version> -m "v<version>"
git push origin --tags
git branch -d <version>
git push origin --delete <version>
```

Report:
```
Release shipped: v<version>
  Tag: v<version>
  Branch <version> deleted
```

---

## Error Recovery

If any gate fails:
```
Ship stopped at Gate N: <gate-name>
  Item: <item> "<name>"
  Mode: [fast | feature | release]
  Issue: [what failed]
  Fix: [suggestion]

  After fixing, run /lo:ship again.
```

---

## Examples

<example name="explore-fast">
User: /lo:ship (project: explore, branch: feat/f003-auth)

Gate 1: fast mode (Explore)
Gates 2-5: skipped
Gate 6+7: commit → merge to main → push → prune backlog → delete branch

Ship complete: f003 "User Authentication"
</example>

<example name="build-feature">
User: /lo:ship (project: build, branch: feat/f003-auth)

Gate 1: feature mode
Gate 2: EARS 22/22 covered
Gate 3: 47 tests passed
Gate 4: reviewer clean
Gate 5: README current
Gate 6+7: commit → push branch → PR #15 → auto-merge

Ship complete: f003 "User Authentication"
</example>

<example name="build-release">
User: /lo:ship (project: build, branch: 0.6.0)

Gate 1: release mode
Gates 2-5: tests passed, reviewer clean
Gate 6+7: changelog → stream milestone → prune backlog → cleanup work dirs → PR #42

After the PR merges, run: /lo:ship tag
</example>

<example name="start-release">
User: /lo:ship release bump minor

Current: 0.5.0 → Next: 0.6.0
Branch: 0.6.0
Version bumped in: plugin.json

Work on this branch, then /lo:ship to finalize.
</example>
