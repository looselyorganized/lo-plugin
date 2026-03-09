---
name: release
description: Manages versioned releases with release branches, changelogs, and git tags. Creates release branches for new versions, generates changelogs from commits, and merges to main with a tag. Only active for projects in Build or Open status. Use when user says "new release", "start release", "release this", "cut a release", "ship release", "changelog", or "/lo:release".
---

# LO Release

Manages the release lifecycle for versioned projects. Creates release branches, tracks work, generates changelogs, and tags releases on main. Only available for projects in `Build` or `Open` status — in `Explore`, ship directly to main without versions.

## When to Use

- User invokes `/lo:release`
- User says "new release", "start release", "cut a release", "changelog"
- A batch of features/tasks is ready to be grouped into a versioned release

## When NOT to Use

- Project is in `Explore` status — versions add overhead without value at this stage
- Single hotfix — just use `/lo:ship` directly on a fix branch

## Critical Rules

- `.lo/PROJECT.md` MUST exist with status `Build` or `Open`. If status is `Explore`, tell the user: "Releases require Build or Open status. In Explore, ship directly to main."
- The canonical version lives in `plugins/lo/.claude-plugin/plugin.json` (for this plugin) or wherever the project declares its version. Read it — don't guess.
- Version format is semver: `MAJOR.MINOR.PATCH` (e.g., `0.3.2`, `1.0.0`).
- Release branches are named by version number only: `0.3.2`, `0.4.0`, `1.0.0`. No `release/` prefix.
- Never force-push to main. Releases merge forward.
- CHANGELOG.md is generated, not maintained by hand. See `references/changelog-format.md`.

## Modes

Detect from arguments:
- `/lo:release` with no args → show current release status
- `/lo:release 0.3.2` → start a new release at version 0.3.2
- `/lo:release bump patch` → auto-increment patch version, start release
- `/lo:release bump minor` → auto-increment minor version, start release
- `/lo:release bump major` → auto-increment major version, start release
- `/lo:release ship` → finalize current release (changelog, merge, tag)

---

## Starting a Release

### Step 1: Pre-flight

1. Read `.lo/PROJECT.md` — verify status is `Build` or `Open`
2. Read the project's version source to determine current version
3. Check `git status` — working tree must be clean
4. Check current branch — must be on `main`

If any check fails, report and stop.

### Step 2: Determine Version

**If version provided** (`/lo:release 0.3.2`): Validate it's valid semver and greater than current version.

**If bump requested** (`/lo:release bump patch`): Calculate next version from current.

| Current | bump patch | bump minor | bump major |
|---------|-----------|-----------|-----------|
| 0.3.1   | 0.3.2     | 0.4.0     | 1.0.0     |
| 1.2.3   | 1.2.4     | 1.3.0     | 2.0.0     |

**If no version:** Show current version and ask:

    Current version: 0.3.1

    1. Patch (0.3.2) — bug fixes, small changes
    2. Minor (0.4.0) — new features, backward compatible
    3. Major (1.0.0) — breaking changes
    4. Custom version

### Step 3: Create Release Branch

```bash
git checkout -b <version>
```

Confirm:

    Release started: <version>
    Branch: <version>

    All work branches from here. /lo:work creates feature branches off this release branch,
    and /lo:ship merges them back into it. Main is untouched until /lo:release ship.
    When ready to finalize: /lo:release ship

### Step 4: Update Version References

Update the version in the project's version source. The canonical version lives in one place — don't duplicate it across files.

For the lo-plugin: `plugins/lo/.claude-plugin/plugin.json` → `"version": "<new-version>"`

For other projects, detect version sources:
- `package.json` → `"version"`
- `Cargo.toml` → `version`
- `pyproject.toml` → `version`
- Plugin manifests, config files

Present the list of files that will be updated and confirm before writing.

Commit the version bump:

    git add <version-files>
    git commit -m "chore: bump version to <version>"

---

## Showing Release Status

When invoked with no args (`/lo:release`):

1. Check if currently on a version branch (branch name matches semver pattern)
2. If on a release branch:

        Release in progress: <version>
        Branch: <version>
        Commits since branch: N

        Files changed:
          M plugins/lo/skills/plan/SKILL.md
          A plugins/lo/skills/release/SKILL.md

        Finalize with: /lo:release ship

3. If on main:

        No release in progress.
        Current version: <version>

        Start one with: /lo:release bump [patch|minor|major]

---

## Shipping a Release

`/lo:release ship` finalizes the current release: generates changelog, merges to main, tags.

### Progress Tracking

At pipeline start, create a task list using `TaskCreate` so the user sees live progress. One task per gate:

1. Pre-flight (tests)
2. Generate changelog
3. Push + open PR (auto-merge enabled)
4. Wait for merge (CI + CodeRabbit)
5. Tag
6. Clean up
7. Report

Mark each `in_progress` when starting, `completed` when passed. If a gate fails, mark it `failed` and stop.

### Gate 1: Pre-flight

1. Verify you're on a release branch (branch name is semver)
2. Check working tree is clean
3. Run tests locally — all must pass. If tests fail, stop.

Note: CI validation happens via the PR in Gate 3 — the PR's CI run validates the integrated release branch against main. Do NOT use `gh run list --branch` as a substitute; those runs may be from feature PRs, not from the release branch itself.

### Gate 2: Generate Changelog

**Read work artifacts first.** `/lo:ship` in Build/Open preserves `.lo/work/` directories so the changelog has full context. Before generating, scan:

1. **Work directories:** Read `.lo/work/*/` — plan files, EARS requirements, feature names
2. **BACKLOG.md:** Active features and open tasks that were worked on
3. **Git commits:** Gather all commits on this branch since it diverged from main:

    ```bash
    git log main..<version> --pretty=format:"%H|%ad|%s" --date=short
    ```

Use all three sources to write a richer changelog — not just commit message classification, but what was actually built and why.

4. Group commits into categories:

    | Prefix/pattern | Category |
    |---------------|----------|
    | `feat:`, `feat(*):`  | Added |
    | `fix:`, `fix(*):` | Fixed |
    | `chore:`, `refactor:`, `cleanup:` | Changed |
    | `docs:` | Documentation |
    | `BREAKING CHANGE:`, `!:` | Breaking |

    Commits that don't match a pattern → `Changed`.

5. Write or update `CHANGELOG.md` at repo root. See `references/changelog-format.md` for the format.

6. Present the changelog entry to the user for review:

        Changelog for <version>:

        ### Added
        - EARS requirements as optional contract in plan → work → ship chain (f003)

        ### Changed
        - Updated work skill to read EARS alongside plans

        Looks good? Edit anything?

7. Commit the changelog:

    ```bash
    git add CHANGELOG.md
    git commit -m "docs: changelog for <version>"
    ```

### Gate 3: Push + Open PR

🔒 Releases MUST go through a pull request. Never merge locally to main or push directly to main.

1. Push the release branch to origin:

    ```bash
    git push -u origin <version>
    ```

2. Open a PR targeting main:

    ```bash
    gh pr create --base main --head <version> \
      --title "release: v<version>" \
      --body "$(cat <<'PREOF'
    ## Release v<version>

    <changelog summary — copy the Generated changelog entry from Gate 2>

    ---
    Generated by `/lo:release ship`
    PREOF
    )"
    ```

3. Enable auto-merge so the PR merges automatically when CI and reviews pass:

    ```bash
    gh pr merge <PR-NUMBER> --auto --merge
    ```

    Use `--merge` (not `--squash`) to preserve the release branch history.

4. Report the PR URL:

        PR opened: <url>
        Auto-merge enabled — will merge when CI and CodeRabbit pass.

If push or PR creation fails, stop and report.

### Gate 4: Wait for Merge

The PR merge is fully autonomous — CI runs, CodeRabbit reviews, and cr-agent fixes any CodeRabbit feedback automatically (up to 3 rounds). Auto-merge fires when both CI and CodeRabbit approve.

Poll until the PR reaches a terminal state. Set a maximum wait of 15 minutes (30 polls at 30s intervals). If the PR hasn't merged by then, stop and hand back the PR URL for the user to follow up async.

```bash
gh pr view <PR-NUMBER> --json state -q '.state'
```

Poll every 30 seconds:

- `MERGED` → proceed to Gate 5
- `OPEN` → continue polling (CI running, CodeRabbit reviewing, or cr-agent fixing)
- `CLOSED` (not merged) → stop. Report and ask user to investigate.

While polling, check for cr-agent activity to keep the user informed:

```bash
gh pr view <PR-NUMBER> --json reviews --jq '.reviews[-1].author.login'
```

Report status updates as they happen:

    Waiting for PR #<N> to merge...
      CI: running / passed / failed
      CodeRabbit: pending / reviewing / approved / changes requested
      CR-Agent: fixing (round N) / idle

If CI fails, stop and report — auto-merge won't fire and cr-agent only fixes CodeRabbit comments, not CI failures.

When resuming after a merged PR, the pipeline detects we're on main with the release already merged and skips Gates 1-4, continuing from Gate 5.

### Gate 5: Tag

After the PR has merged:

```bash
git checkout main
git pull origin main
git tag -a v<version> -m "v<version>"
git push origin --tags
```

### Gate 6: Clean Up

Now that the changelog is written and merged, clean up all release artifacts.

**Work directories:**
1. Scan `.lo/work/` for directories related to this release's features and tasks
2. Delete each work directory (git history preserves everything)
3. For features: update status in BACKLOG.md to `Status: done -> YYYY-MM-DD`, update `updated:` date
4. For tasks: mark done in BACKLOG.md (`- [x] t{NNN} ~~description~~ -> YYYY-MM-DD`), update `updated:` date

**Branches:**
1. Delete the local release branch:

    ```bash
    git branch -d <version>
    ```

2. Delete the remote release branch:

    ```bash
    git push origin --delete <version>
    ```

3. Delete remote feature branches that were merged into this release:

    ```bash
    git push origin --delete <feature-branch>
    ```

    List the branches being deleted and confirm before proceeding.

**Commit the cleanup via PR (do not push directly to main):**

```bash
git checkout -b chore/cleanup-v<version>
git add .lo/
git commit -m "chore: clean up work artifacts for v<version>"
git push -u origin chore/cleanup-v<version>
gh pr create --base main --head chore/cleanup-v<version> \
  --title "chore: clean up work artifacts for v<version>" \
  --body "Post-release cleanup for v<version>"
gh pr merge --auto --squash
```

### Gate 7: Report

    Release shipped: v<version>

      PR:        <url> (merged)
      Tag:       v<version>
      Changelog: CHANGELOG.md updated
      Branch:    <version> merged to main via PR and deleted
      CI:        passed
      Review:    CodeRabbit approved
      Cleaned:   N work directories removed, N branches deleted
      Backlog:   N tasks marked done

      Changelog entry:
        [summary of what was added/changed/fixed]

    Next: /lo:stream to capture this as a milestone.
    Anything reusable worth capturing? Run /lo:solution, or "no" to skip.

---

## Changelog Integration

The changelog is **generated from commits**, not maintained by hand. Each release appends a new version block at the top of `CHANGELOG.md`. The format follows Keep a Changelog conventions — see `references/changelog-format.md`.

If `CHANGELOG.md` doesn't exist, create it with the header and first version entry.

## Error Recovery

    Release stopped at Gate N: <gate-name>
    Version: <version>
    Branch: <version>
    Issue: [what failed]
    Fix: [suggestion]
    After fixing, run /lo:release ship again.

Pipeline restarts from Gate 1 on retry (gates are cheap).

## How Release Fits the Workflow

```
/lo:release 0.3.2          → creates release branch
  /lo:plan f003             → plans feature (commits land on 0.3.2)
  /lo:work f003             → executes plan
  /lo:ship                  → ships feature to 0.3.2 branch
  /lo:plan t005             → plans task
  /lo:work t005             → executes task
  /lo:ship                  → ships task to 0.3.2 branch
/lo:release ship            → changelog, merge to main, tag v0.3.2
  /lo:stream                → capture release as milestone
```

Release wraps the version lifecycle. Plan/work/ship stay focused on features and tasks — they don't know or care about versions. Release handles the branch, the version bump, and the final merge.

## Examples

### Starting a patch release

    User: /lo:release bump patch

    Current version: 0.3.1
    Next patch: 0.3.2

    Creating release branch...

    Release started: 0.3.2
    Branch: 0.3.2
    Version bumped in: plugin.json, 12 skill files

    Work on this branch. Finalize with /lo:release ship.

### Shipping a release

    User: /lo:release ship

    Gate 1: Pre-flight — on branch 0.3.2, clean tree, tests pass ✓
    Gate 2: Changelog generated ✓

    Changelog for 0.3.2:

    ### Added
    - EARS requirements as optional contract in plan → work → ship chain
    - /lo:release skill for versioned release management

    ### Changed
    - Work skill reads EARS alongside plans
    - Ship skill audits EARS coverage at Gate 2

    Looks good?

    User: yes

    Gate 3: PR opened — github.com/org/repo/pull/42 (auto-merge enabled) ✓
    Gate 4: CI passed, CodeRabbit approved, PR merged ✓
    Gate 5: Tagged v0.3.2, pushed tags ✓
    Gate 6: Clean up — 2 work dirs removed, 3 branches deleted ✓
    Gate 7: Report ✓

    Release shipped: v0.3.2
