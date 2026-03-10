---
name: release
description: Starts a versioned release by creating a release branch and bumping the version. Only for Build or Open status projects. Use when user says "new release", "start release", "cut a release", or "/lo:release". To finalize a release, use /lo:ship on the release branch.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# LO Release

Starts versioned releases. Creates a release branch, bumps the version, and hands off. Finalizing a release is just `/lo:ship` on the release branch — ship detects the semver branch and does the right thing.

## When to Use

- User invokes `/lo:release`
- User says "new release", "start release", "cut a release"

## When NOT to Use

- Project is in `Explore` status — ship directly to main, no versions needed
- Finalizing a release — use `/lo:ship` on the release branch

## Critical Rules

- `.lo/PROJECT.md` MUST exist with status `Build` or `Open`. If `Explore`, tell the user.
- The canonical version lives in the project's version source (e.g., `plugin.json`, `package.json`). Read it — don't guess.
- Version format is semver: `MAJOR.MINOR.PATCH`.
- Release branches are named by version number only: `0.3.2`, `0.4.0`. No `release/` prefix.

## Modes

- `/lo:release` → show current release status
- `/lo:release 0.3.2` → start a new release at version 0.3.2
- `/lo:release bump patch|minor|major` → auto-increment, start release

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

### Step 4: Update Version References

Update the version in the project's version source. Present files that will change and confirm before writing.

Commit the version bump:

```bash
git add <version-files>
git commit -m "chore: bump version to <version>"
```

Report:

    Release started: <version>
    Branch: <version>
    Version bumped in: <files>

    Work on this branch. Features branch off it, /lo:ship merges them back.
    When ready to finalize: /lo:ship (on this branch)

---

## Showing Release Status

When invoked with no args (`/lo:release`):

1. Check if currently on a version branch (branch name matches semver pattern)
2. If on a release branch:

        Release in progress: <version>
        Branch: <version>
        Commits since branch: N
        Finalize with: /lo:ship

3. If on main:

        No release in progress.
        Current version: <version>
        Start one with: /lo:release bump [patch|minor|major]

---

## How Release Fits the Workflow

```
/lo:release 0.4.0          → creates release branch, bumps version
  /lo:plan f003             → plans feature
  /lo:work f003             → executes plan
  /lo:ship                  → ships feature to release branch
/lo:ship                    → on release branch: changelog, cleanup, PR to main
  (PR merges via CI/auto-merge)
/lo:ship tag                → tag v0.4.0, delete branch
```

## Examples

### Starting a release

    User: /lo:release bump minor

    Current version: 0.3.2 → Next minor: 0.4.0
    Release started: 0.4.0
    Branch: 0.4.0
    Version bumped in: plugin.json

    Work on this branch. Finalize with /lo:ship.

### Showing status

    User: /lo:release

    Release in progress: 0.4.0
    Branch: 0.4.0
    Commits since branch: 5
    Finalize with: /lo:ship
