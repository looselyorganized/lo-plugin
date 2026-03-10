---
name: status
description: Manages project lifecycle transitions. Updates PROJECT.md status and triggers transition-specific automation (test scaffolding, CI setup, branch protection). Use when user says "status", "change status", "move to explore", "move to build", "go to open", "close project", "/status", or "/lo:status".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
---

# LO Status Manager

Manages project lifecycle transitions in `.lo/PROJECT.md`. Each transition triggers automation appropriate to the new phase.

<critical>
Backward transitions (Open→Build, Build→Explore) ALWAYS require explicit user confirmation before proceeding.
ALWAYS read the current status from PROJECT.md before making any changes.
</critical>

## When to Use

- User invokes `/lo:status`
- User says "change status", "move to build", "go to open", "close this project"

## Status Lifecycle

```
Explore → Build → Open → Closed
```

Status values are capitalized: `Explore`, `Build`, `Open`, `Closed`.

## Modes

Detect from arguments:
- `/lo:status` with no args → **show status**
- `/lo:status Build` → **transition to Build** (complex — has sub-steps)
- `/lo:status Open` or `Closed` or `Explore` → **simple transition**

Follow ONLY the section matching the detected mode.

---

<show-status>
## Show Status (no args)

Read `.lo/PROJECT.md` frontmatter and display:

```
Project: <title>
Status: <current-status>
State: <public|private>
```

</show-status>

---

<transition-build>
## Transition to Build

This is the major transition — the project is becoming real. Multiple automation steps follow.

### Pre-flight

1. Read `.lo/PROJECT.md`, note current status
2. If already `Build`, report and stop
3. Update `status: "Build"` in frontmatter
4. Announce:

```
Status changed: <old-status> → Build

The project is now in Build phase. This unlocks:
  - Test coverage planning
  - CI/CD pipeline setup
  - Branch protection + auto-merge
  - Public documentation
```

### Select automation steps

Ask the user what to set up:

```
What do you want to configure?

1. All of the below (recommended)
2. Scan codebase and create a test coverage plan
3. Reconcile GitHub automation (CodeRabbit, CI, branch protection, auto-merge)
4. Create README and public docs (if missing)
5. Skip all — just change the status
```

Allow multiple selections. Run selected steps in order.

<build-step-a>
### Step A: Scan Codebase for Test Coverage

Scan the project for testable logic:

- **Include:** Functions with business logic, parsers, validators, data transformations, state machines, API handlers, utilities
- **Exclude:** Config files, type definitions, UI layout, markdown, thin wrappers

For each testable file/function, note: file path, what to test, priority (`high`/`medium`/`low`).

1. Determine next feature ID from `.lo/BACKLOG.md`
2. Add to BACKLOG.md:

```markdown
- [ ] f{NNN} Test Coverage
  Retroactive test coverage for core project logic. Generated during Explore → Build transition.
  [active](.lo/work/f{NNN}-test-coverage/)
```

3. Create `.lo/work/f{NNN}-test-coverage/001-test-coverage.md`:

```markdown
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
- [ ] [medium] Test <file>: <function/behavior> description
```

Order tasks by priority (high first).

4. Report:

```
Created: f{NNN} — Test Coverage
Plan: .lo/work/f{NNN}-test-coverage/001-test-coverage.md
Tasks: N files identified (X high, Y medium, Z low priority)

Run /lo:work f{NNN} to start writing tests.
```

</build-step-a>

<build-step-b>
### Step B: Reconcile GitHub Automation

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If the script doesn't exist, warn and skip:

```
GitHub sync script not found. Skipping automation reconciliation.
You can set up CI/CD manually or add the script later.
```

If the project has a `build` script in package.json, ask:

```
CI build check detected (bun run build). Include in CI?

1. Yes (recommended for Next.js, static sites, bundled libraries)
2. No (APIs, scripts, or packages where tests are sufficient)
```

If no, run with `--no-build`:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix --no-build
```

Present the script's output. If any items show `error`, investigate and report.

</build-step-b>

<build-step-c>
### Step C: Create README and Public Docs

1. Check if `README.md` exists at repo root
2. If missing, generate from `.lo/PROJECT.md`:
   - Title and description from frontmatter
   - Body from PROJECT.md content
   - Stack/topics from frontmatter
   - Prompt user for install/usage instructions if unclear
3. Present for user review before writing
4. If README already exists, skip: `README.md already exists.`

</build-step-c>

### Final Summary

After all selected steps complete:

```
Build transition complete for "<project-title>"

  Status:     Build
  Tests:      f{NNN} — N files to cover. Run /lo:work f{NNN} to start.
  GitHub:     lo-github-sync applied (see output above)
  Docs:       README.md [created | already exists | skipped]
```

</transition-build>

---

<simple-transition>
## Simple Transition (Open, Closed, Explore)

This section handles transitions to Open, Closed, and Explore. These are simpler than Build — they update the status and run the sync script.

1. Read `.lo/PROJECT.md`, note current status

2. **Check for backward transition:**
   - Open → Build, Build → Explore, or any move toward Explore/Build from a later stage
   - If backward: confirm with user before proceeding

```
This moves the project backward from <current> to <target>. Are you sure?
```

**Do not proceed until the user confirms.**

3. Update `status: "<target>"` in frontmatter

4. Run GitHub automation sync:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If the script doesn't exist, warn and skip.

5. Report:

```
Status changed: <old-status> → <new-status>
```

</simple-transition>

---

## Examples

<example name="show-status">
User: /lo:status

Project: LO Plugin
Status: Build
State: public
</example>

<example name="transition-to-build">
User: /lo:status Build

Status changed: Explore → Build

What do you want to configure?
1. All of the below (recommended)
...

User picks 1 → runs Steps A, B, C

Build transition complete for "LO Plugin"
  Status:     Build
  Tests:      f008 — 12 files to cover
  GitHub:     lo-github-sync applied
  Docs:       README.md created
</example>

<example name="backward-transition">
User: /lo:status Explore

This moves the project backward from Build to Explore. Are you sure?

User confirms → status updated

Status changed: Build → Explore
</example>
