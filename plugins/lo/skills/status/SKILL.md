---
name: status
description: Manages project lifecycle transitions. Updates PROJECT.md status and triggers transition-specific automation (test scaffolding, CI setup, branch protection). Use when user says "status", "change status", "move to explore", "move to build", "go to open", "close project", "/status", or "/lo:status".
metadata:
  version: 0.3.2
  author: LORF
---

# LO Status Manager

Manages project lifecycle transitions in `.lo/PROJECT.md`. Each transition can trigger automation appropriate to the new phase.

## When to Use

- User invokes `/lo:status`
- User says "change status", "move to build", "go to open", "close this project"

## Critical Rules

- `.lo/PROJECT.md` MUST exist. If it doesn't, tell the user to run `/lo:new` first.
- ALWAYS read the current status before making changes.
- ALWAYS confirm the transition with the user before applying.
- Status values: `Explore` | `Build` | `Open` | `Closed`
- Update the PROJECT.md frontmatter `status` field only. Do not alter the body.

## Status Lifecycle

```
Explore → Build → Open → Closed
```

Backward transitions are allowed (e.g., `Open` → `Build` if rework is needed) but should prompt a confirmation: "This moves the project backward. Are you sure?"

## Modes

Detect mode from arguments. `/lo:status` with no args → show current status. `/lo:status Explore` → transition to Explore. `/lo:status Build` → transition to Build. `/lo:status Open` → transition to Open. `/lo:status Closed` → transition to Closed.

### Mode 1: Show Status

Arguments: none

Read `.lo/PROJECT.md` frontmatter and display:

    Project: <title>
    Status: <current-status>
    State: <public|private>

### Mode 2: Transition to `Build`

Arguments: `Build`

This is the major transition — the project is becoming real. Multiple automation steps follow.

1. Read `.lo/PROJECT.md`, confirm current status
2. Update `status: "Build"` in frontmatter
3. Announce:

        Status changed: <old-status> → Build

        The project is now in Build phase. This unlocks:
          - Test coverage planning
          - CI/CD pipeline setup
          - Branch protection + auto-merge
          - Public documentation

4. **Ask the user what to set up:**

        What do you want to configure?

        1. All of the below (recommended)
        2. Scan codebase and create a test coverage plan
        3. Reconcile GitHub automation (CodeRabbit, CI, branch protection, auto-merge)
        4. Create README and public docs (if missing)
        5. Skip all — just change the status

    Allow multiple selections. Proceed with selected items in order.

#### Step A: Scan Codebase for Test Coverage

Scan the project for testable logic:

- **Include:** Functions with business logic, parsers, validators, data transformations, state machines, API handlers with logic, utilities
- **Exclude:** Config files, type definitions, UI components (unless they have logic), markdown, simple re-exports, thin wrappers around libraries

For each testable file/function, note:
- File path
- What to test (function name, behavior)
- Priority: `high` (core logic, error-prone), `medium` (helpers, utilities), `low` (nice to have)

Create a backlog feature and work plan:

1. Determine next feature ID from `.lo/BACKLOG.md`
2. Add to BACKLOG.md:

        ### f{NNN} — Test Coverage
        Retroactive test coverage for core project logic. Generated during Explore → Build transition.
        Status: active -> .lo/work/f{NNN}-test-coverage/

3. Create `.lo/work/f{NNN}-test-coverage/001-test-coverage.md`:

        ---
        status: pending
        feature_id: "f{NNN}"
        feature: test-coverage
        phase: 1
        ---

        ## Objective
        Add test coverage to core project logic identified during Build transition.

        ## Tasks
        - [ ] [high] Test <file>: <function/behavior> description
        - [ ] [high] Test <file>: <function/behavior> description
        - [ ] [medium] Test <file>: <function/behavior> description
        ...

    Order tasks by priority (high first).

4. Report:

        Created: f{NNN} — Test Coverage
        Plan: .lo/work/f{NNN}-test-coverage/001-test-coverage.md
        Tasks: N files identified (X high, Y medium, Z low priority)

        Run /lo:work f{NNN} to start writing tests.

#### Step B: Reconcile GitHub Automation

Run the sync script to reconcile all GitHub automation for the new status:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If the project has a `build` script in package.json, ask the user:

        CI build check detected (bun run build). Include in CI?

          1. Yes (recommended for Next.js, static sites, bundled libraries)
          2. No (APIs, scripts, or packages where tests are sufficient)

If the user says no, run with `--no-build`:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix --no-build
```

The script reads the just-updated PROJECT.md status and reconciles:
- `.coderabbit.yaml` (reviews enabled/disabled)
- `.github/workflows/ci.yml` (active/dormant, detected capabilities)
- `.github/workflows/auto-merge.yml` (created/removed)
- Branch protection (1 reviewer + checks / removed via API)
- Auto-merge repo setting (enabled/disabled via API)

Present the script's output to the user. If any items show `error`, investigate and report.

#### Step C: Create README and Public Docs

1. Check if `README.md` exists at the repo root
2. If missing, generate one from `.lo/PROJECT.md`:
   - Title from frontmatter
   - Description from frontmatter
   - Body from PROJECT.md content
   - Stack/topics from frontmatter
   - Install/usage instructions (prompt user for these if unclear)

3. Present the generated README for user review before writing.
4. If README already exists, skip and report "README.md already exists."

#### Final Summary

After all selected steps complete:

    Build transition complete for "<project-title>"

      Status:     Build
      Tests:      f{NNN} — N files to cover. Run /lo:work f{NNN} to start.
      GitHub:     lo-github-sync applied (see output above)
      Docs:       README.md [created | already exists | skipped]

### Mode 3: Transition to `Open`

Arguments: `Open`

1. Read `.lo/PROJECT.md`, confirm current status
2. Update `status: "Open"` in frontmatter
3. Run `lo-github-sync.sh --fix` to reconcile GitHub automation for the new status.
4. Report:

        Status changed: <old-status> → Open

### Mode 4: Transition to `Closed`

Arguments: `Closed`

1. Read `.lo/PROJECT.md`, confirm current status
2. Update `status: "Closed"` in frontmatter
3. Run `lo-github-sync.sh --fix` to reconcile GitHub automation for the new status.
4. Report:

        Status changed: <old-status> → Closed

### Mode 5: Transition to `Explore`

Arguments: `Explore`

1. Read `.lo/PROJECT.md`, confirm current status. This is a backward transition — confirm with user.
2. Update `status: "Explore"` in frontmatter
3. Run `lo-github-sync.sh --fix` to reconcile GitHub automation for the new status.
4. Report:

        Status changed: <old-status> → Explore
