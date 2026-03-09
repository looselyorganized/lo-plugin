---
name: release
description: Manages versioned releases with release branches, changelogs, and git tags. Creates release branches for new versions, generates changelogs from commits, and merges to main with a tag. Only active for projects in Build or Open status. Use when user says "new release", "start release", "release this", "cut a release", "ship release", "changelog", or "/lo:release".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# LO Release

Manages the release lifecycle for versioned projects. Creates release branches, generates changelogs, opens PRs to main, and tags releases. Only available for `Build` or `Open` status — in `Explore`, ship directly to main without versions.

## When to Use

- User invokes `/lo:release`
- User says "new release", "start release", "cut a release", "changelog"
- A batch of features/tasks is ready to be grouped into a versioned release

## When NOT to Use

- Project is in `Explore` status — versions add overhead without value at this stage
- Single hotfix — just use `/lo:ship` directly on a fix branch

## Critical Rules

- `.lo/PROJECT.md` MUST exist with status `Build` or `Open`. If `Explore`, tell the user.
- The canonical version lives in `plugins/lo/.claude-plugin/plugin.json` (for this plugin) or wherever the project declares its version. Read it — don't guess.
- Version format is semver: `MAJOR.MINOR.PATCH`.
- Release branches are named by version number only: `0.3.2`, `0.4.0`. No `release/` prefix.
- Never force-push to main. Releases merge forward via PR.
- CHANGELOG.md is generated, not maintained by hand. See `references/changelog-format.md`.

## Modes

- `/lo:release` → show current release status
- `/lo:release 0.3.2` → start a new release at version 0.3.2
- `/lo:release bump patch|minor|major` → auto-increment, start release
- `/lo:release ship` → finalize current release
- `/lo:release tag` → tag after PR has merged (resume point)

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

    Work branches from here. /lo:ship merges features back into it.
    When ready to finalize: /lo:release ship

### Step 4: Update Version References

Update the version in the project's version source. Present files that will change and confirm before writing.

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
        Finalize with: /lo:release ship

3. If on main:

        No release in progress.
        Current version: <version>
        Start one with: /lo:release bump [patch|minor|major]

---

## Shipping a Release

`/lo:release ship` finalizes the current release.

### Step 1: Pre-flight

1. Verify you're on a release branch (branch name is semver)
2. Check working tree is clean
3. Run tests — all must pass. If tests fail, stop.

### Step 2: Generate Changelog

Read work artifacts for context. `/lo:ship` in Build/Open preserves `.lo/work/` directories so the changelog has full context. Scan:

1. **Work directories:** Read `.lo/work/*/` — plan files, EARS requirements, feature names
2. **BACKLOG.md:** Active features and open tasks that were worked on
3. **Git commits:** `git log main..<version> --pretty=format:"%H|%ad|%s" --date=short`

Use all three sources to write a richer changelog — not just commit message classification, but what was actually built and why.

Group commits into categories:

| Prefix/pattern | Category |
|---------------|----------|
| `feat:`, `feat(*):` | Added |
| `fix:`, `fix(*):` | Fixed |
| `chore:`, `refactor:` | Changed |
| `docs:` | Documentation |
| `BREAKING CHANGE:`, `!:` | Breaking |

Write or update `CHANGELOG.md`. Present the entry for user review. Commit:

```bash
git add CHANGELOG.md
git commit -m "docs: changelog for <version>"
```

### Step 3: Clean up work artifacts

Clean up before the PR so everything ships in one commit:

1. Scan `.lo/work/` for directories related to this release
2. Delete each work directory (git history preserves everything)
3. Update BACKLOG.md: features → `Status: done -> YYYY-MM-DD`, tasks → `- [x] t{NNN} ~~description~~ -> YYYY-MM-DD`
4. Update `updated:` date in BACKLOG.md
5. Commit:

```bash
git add .lo/
git commit -m "chore: clean up work artifacts for v<version>"
```

### Step 4: Push + Open PR

Releases MUST go through a pull request. Never merge locally to main.

```bash
git push -u origin <version>
gh pr create --base main --head <version> \
  --title "release: v<version>" \
  --body "<changelog summary>"
gh pr merge <PR-NUMBER> --auto --merge
```

Use `--merge` (not `--squash`) to preserve release branch history.

Report and stop:

    Release PR opened: <url>
    Auto-merge enabled — will merge when CI and reviews pass.

    After the PR merges, run: /lo:release tag

Do NOT poll or wait. The user resumes when the PR has merged.

### Step 5: Tag

`/lo:release tag` (or `/lo:release ship` after the PR has merged) finishes the release.

Detect state: if on a release branch and the PR is merged, or if on main with the release commits present:

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

      PR:        <url> (merged)
      Tag:       v<version>
      Changelog: CHANGELOG.md updated
      Cleaned:   work artifacts removed, branches deleted

    Next: /lo:stream to capture this as a milestone.
    Anything reusable? Run /lo:solution, or "no" to skip.

---

## Changelog Integration

The changelog is **generated from commits**, not maintained by hand. Each release appends a new version block at the top of `CHANGELOG.md`. See `references/changelog-format.md`.

If `CHANGELOG.md` doesn't exist, create it with the header and first version entry.

## Error Recovery

    Release stopped: <step>
    Version: <version>
    Branch: <version>
    Issue: [what failed]
    Fix: [suggestion]
    After fixing, run /lo:release ship again.

## How Release Fits the Workflow

```
/lo:release 0.3.2          → creates release branch
  /lo:plan f003             → plans feature
  /lo:work f003             → executes plan
  /lo:ship                  → ships feature to 0.3.2 branch
/lo:release ship            → changelog, cleanup, PR to main
  (PR merges via CI/auto-merge)
/lo:release tag             → tag v0.3.2, delete branch
  /lo:stream                → capture release as milestone
```

## Examples

### Starting a release

    User: /lo:release bump minor

    Current version: 0.3.2 → Next minor: 0.4.0
    Release started: 0.4.0
    Branch: 0.4.0
    Version bumped in: plugin.json

    Work on this branch. Finalize with /lo:release ship.

### Shipping a release

    User: /lo:release ship

    Tests: 12 passed ✓
    Changelog: generated, reviewed ✓
    Cleanup: 2 work dirs removed, backlog updated ✓
    PR: #42 opened, auto-merge enabled ✓

    After the PR merges, run: /lo:release tag

### Tagging after merge

    User: /lo:release tag

    Tagged: v0.4.0
    Branch 0.4.0 deleted (local + remote)

    Release shipped: v0.4.0
