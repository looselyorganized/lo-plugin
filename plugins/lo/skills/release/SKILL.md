---
name: release
description: Manages versioned releases with release branches, changelogs, and git tags. Creates release branches for new versions, generates changelogs from commits, and merges to main with a tag. Only active for projects in Build or Open status. Use when user says "new release", "start release", "release this", "cut a release", "ship release", "changelog", or "/lo:release".
metadata:
  version: 0.3.2
  author: LORF
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

    Work on this branch. Features and tasks land here via /lo:plan → /lo:work → /lo:ship.
    When ready to finalize: /lo:release ship

### Step 4: Update Version References

Update the version in all project version sources. For the lo-plugin, this means:

1. `plugins/lo/.claude-plugin/plugin.json` → `"version": "<new-version>"`
2. All `plugins/lo/skills/*/SKILL.md` → `version: <new-version>` in metadata

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

### Gate 1: Pre-flight

1. Verify you're on a release branch (branch name is semver)
2. Check working tree is clean
3. Run tests — all must pass. If tests fail, stop.

### Gate 2: Generate Changelog

1. Gather all commits on this branch since it diverged from main:

    ```bash
    git log main..<version> --pretty=format:"%H|%ad|%s" --date=short
    ```

2. Group commits into categories. Read each commit message and classify:

    | Prefix/pattern | Category |
    |---------------|----------|
    | `feat:`, `feat(*):`  | Added |
    | `fix:`, `fix(*):` | Fixed |
    | `chore:`, `refactor:`, `cleanup:` | Changed |
    | `docs:` | Documentation |
    | `BREAKING CHANGE:`, `!:` | Breaking |

    Commits that don't match a pattern → `Changed`.

3. Write or update `CHANGELOG.md` at repo root. See `references/changelog-format.md` for the format.

4. Present the changelog entry to the user for review:

        Changelog for <version>:

        ### Added
        - EARS requirements as optional contract in plan → work → ship chain

        ### Changed
        - Updated work skill to read EARS alongside plans

        Looks good? Edit anything?

5. Commit the changelog:

    ```bash
    git add CHANGELOG.md
    git commit -m "docs: changelog for <version>"
    ```

### Gate 3: Merge to Main

```bash
git checkout main
git merge <version> --no-ff -m "release: <version>"
```

If merge conflicts occur, stop and report. Do not force.

### Gate 4: Tag

```bash
git tag -a v<version> -m "v<version>"
```

### Gate 5: Push

```bash
git push origin main --tags
```

### Gate 6: Clean Up

1. Delete the local release branch:

    ```bash
    git branch -d <version>
    ```

2. Delete the remote release branch:

    ```bash
    git push origin --delete <version>
    ```

### Gate 7: Report

    Release shipped: v<version>

      Tag:       v<version>
      Changelog: CHANGELOG.md updated
      Branch:    <version> merged to main and deleted

      Changelog entry:
        [summary of what was added/changed/fixed]

    Next: /lo:stream to capture this as a milestone.

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

    Gate 1: Pre-flight — on branch 0.3.2, clean tree ✓
    Gate 1: Tests — 47 passed ✓
    Gate 2: Changelog generated ✓

    Changelog for 0.3.2:

    ### Added
    - EARS requirements as optional contract in plan → work → ship chain
    - /lo:release skill for versioned release management

    ### Changed
    - Work skill reads EARS alongside plans
    - Ship skill audits EARS coverage at Gate 1.5

    Looks good?

    User: yes

    Gate 3: Merged to main ✓
    Gate 4: Tagged v0.3.2 ✓
    Gate 5: Pushed main + tags ✓
    Gate 6: Branch 0.3.2 deleted ✓

    Release shipped: v0.3.2
