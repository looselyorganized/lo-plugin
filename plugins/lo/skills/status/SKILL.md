---
name: status
description: Manages project lifecycle transitions. Updates PROJECT.md status and triggers transition-specific automation (test scaffolding, CI setup, branch protection). Use when user says "status", "change status", "move to build", "go to open", "close project", "/status", or "/lo:status".
metadata:
  version: 0.2.0
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
- Status values: `explore` | `build` | `open` | `closed`
- Update the PROJECT.md frontmatter `status` field only. Do not alter the body.

## Status Lifecycle

```
explore → build → open → closed
```

Backward transitions are allowed (e.g., `open` → `build` if rework is needed) but should prompt a confirmation: "This moves the project backward. Are you sure?"

## Modes

Detect mode from arguments. `/lo:status` with no args → show current status. `/lo:status build` → transition to build. `/lo:status open` → transition to open. `/lo:status closed` → transition to closed.

### Mode 1: Show Status

Arguments: none

Read `.lo/PROJECT.md` frontmatter and display:

    Project: <title>
    Status: <current-status>
    Classification: <public|private>

### Mode 2: Transition to `build`

Arguments: `build`

This is the major transition — the project is becoming real. Multiple automation steps follow.

1. Read `.lo/PROJECT.md`, confirm current status
2. Update `status: "build"` in frontmatter
3. Announce:

        Status changed: <old-status> → build

        The project is now in build phase. This unlocks:
          - Test coverage planning
          - CI/CD pipeline setup
          - Branch protection + auto-merge
          - Public documentation

4. **Ask the user what to set up:**

        What do you want to configure?

        1. All of the below (recommended)
        2. Scan codebase and create a test coverage plan
        3. Generate GitHub Actions test workflow
        4. Enable branch protection + auto-merge
        5. Create README and public docs (if missing)
        6. Skip all — just change the status

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
        Retroactive test coverage for core project logic. Generated during explore → build transition.
        Status: active -> .lo/work/f{NNN}-test-coverage/

3. Create `.lo/work/f{NNN}-test-coverage/001-test-coverage.md`:

        ---
        status: pending
        feature_id: "f{NNN}"
        feature: test-coverage
        phase: 1
        ---

        ## Objective
        Add test coverage to core project logic identified during build transition.

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

#### Step B: Generate GitHub Actions Test Workflow

Detect the project's test runner and package manager by scanning:
- `package.json` → look for `test`, `test:*` scripts, detect bun/npm/pnpm/yarn
- `Cargo.toml` → `cargo test`
- `pyproject.toml` / `setup.py` → `pytest`
- Existing test files → infer framework (vitest, jest, bun test, etc.)

Generate `.github/workflows/test.yml`:

**For a Bun/TypeScript project:**

```yaml
name: Tests
on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install
      - run: bun test
```

**For a Python project:**

```yaml
name: Tests
on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: pytest
```

Adapt the workflow to match the actual project setup. If the project has environment variables needed for tests (e.g., database URLs), add a comment noting they'll need to be configured as GitHub Secrets.

If `.github/workflows/` directory doesn't exist, create it.

Present the generated workflow to the user for review before writing.

#### Step C: Enable Branch Protection + Auto-Merge

**These are GitHub API operations that modify repo settings. Ask the user before running each one.**

1. Present what will happen:

        I'll configure the following on this repo:

        1. Enable auto-merge (allows PRs to merge automatically when checks pass)
        2. Branch protection on main:
           - Require pull request before merging
           - Require Ellipsis review check to pass
           - Require test workflow to pass (if generated in Step B)

        These use the GitHub API and modify repo settings.
        Proceed? (yes/no)

2. If approved, run:

    **Enable auto-merge:**
    ```bash
    gh api repos/{owner}/{repo} --method PATCH --field allow_auto_merge=true
    ```

    **Enable branch protection:**
    ```bash
    gh api repos/{owner}/{repo}/branches/main/protection --method PUT \
      --input - <<EOF
    {
      "required_status_checks": {
        "strict": true,
        "contexts": ["Tests"]
      },
      "enforce_admins": false,
      "required_pull_request_reviews": {
        "required_approving_review_count": 1
      },
      "restrictions": null
    }
    EOF
    ```

    Note: The `"contexts"` array should match the workflow job name from Step B. If no test workflow was generated, omit `required_status_checks`.

3. Report results:

        Auto-merge: enabled
        Branch protection on main: enabled
          - Required checks: Tests, Ellipsis
          - Required reviewers: 1

#### Step D: Create README and Public Docs

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

      Status:     build
      Tests:      f{NNN} — N files to cover. Run /lo:work f{NNN} to start.
      CI:         .github/workflows/test.yml [created | skipped]
      Protection: branch protection [enabled | skipped] + auto-merge [enabled | skipped]
      Docs:       README.md [created | already exists | skipped]

### Mode 3: Transition to `open`

Arguments: `open`

1. Read `.lo/PROJECT.md`, confirm current status
2. Update `status: "open"` in frontmatter
3. Report:

        Status changed: <old-status> → open

### Mode 4: Transition to `closed`

Arguments: `closed`

1. Read `.lo/PROJECT.md`, confirm current status
2. Update `status: "closed"` in frontmatter
3. Report:

        Status changed: <old-status> → closed
