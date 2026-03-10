---
name: status
description: Manages project lifecycle transitions and visibility state. Updates PROJECT.md status and triggers transition-specific automation (test scaffolding, CI setup, branch protection). Toggles public/private visibility. Use when user says "status", "change status", "move to explore", "move to build", "go to open", "close project", "make public", "make private", "/status", or "/lo:status".
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
Backward transitions (any move toward an earlier status in explore→build→open→closed) ALWAYS require explicit user confirmation before proceeding.
ALWAYS read the current status from PROJECT.md before making any changes.
</critical>

## When to Use

- User invokes `/lo:status`
- User says "change status", "move to build", "go to open", "close this project"

## Status Lifecycle

```
Explore → Build → Open → Closed
```

Status values are lowercase: `explore`, `build`, `open`, `closed`.

## Modes

Detect from arguments:
- `/lo:status` with no args → **show status**
- `/lo:status build` → **transition to build** (complex — has sub-steps)
- `/lo:status open` or `closed` or `explore` → **simple transition**
- `/lo:status public` or `private` → **set visibility** (direct)
- `/lo:status state` → **toggle visibility** (prompts for choice)

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
2. If already `build`, report and stop
3. If current status is `open` or `closed`, ask for explicit confirmation before proceeding (backward transition). Stop until user confirms.
4. Update `status: "build"` in frontmatter
5. Announce:

```
Status changed: <old-status> → build

The project is now in build phase. This unlocks:
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
  Retroactive test coverage for core project logic. Generated during explore → build transition.
  [active](.lo/work/f{NNN}-test-coverage/)
```

3. Create `.lo/work/f{NNN}-test-coverage/001-test-coverage.md`:

```markdown
---
status: pending
feature_id: "f{NNN}"
feature: "Test Coverage"
phase: 1
---

## Objective
Add test coverage to core project logic identified during Build transition.

## Tasks
- [ ] 1. [high] Test <file>: <function/behavior> description
- [ ] 2. [medium] Test <file>: <function/behavior> description
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

If the sync script doesn't exist, warn and skip:

```
GitHub sync script not found. Skipping automation reconciliation.
You can set up CI/CD manually or add the script later.
```

If the project has a `build` script in package.json, ask **before running the script**:

```
CI build check detected (bun run build). Include in CI?

1. Yes (recommended for Next.js, static sites, bundled libraries)
2. No (APIs, scripts, or packages where tests are sufficient)
```

Then run the sync script with the appropriate flag:

If yes (or no build script in package.json):

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If no:

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
   - Stack from frontmatter
   - Prompt user for install/usage instructions if unclear
3. Present for user review before writing
4. If README already exists, skip: `README.md already exists.`

</build-step-c>

### Final Summary

After all selected steps complete:

```
Build transition complete for "<project-title>"

  Status:     build
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
   - The handled stages progress in order: Open → Explore → Closed
   - A backward transition occurs when the move goes to an earlier stage. The cases that require confirmation are:
     - **Closed → Open**
     - **Explore → Open**
     - **Closed → Explore**
   - If any of these cases match, prompt the user and block until confirmed:

```
This moves the project backward from <current> to <target>. Are you sure?
```

**Do not proceed until the user confirms.**

3. Update `status: "<target>"` in frontmatter

4. Run GitHub automation sync:

   If the sync script doesn't exist, warn and skip:

   ```
   GitHub sync script not found. Skipping automation sync.
   ```

   Otherwise, run:

   ```bash
   "$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
   ```

5. Report:

```
Status changed: <old-status> → <new-status>
```

</simple-transition>

---

<visibility-toggle>
## Visibility Toggle (public, private, state)

This section handles changing the `state` field in PROJECT.md between `public` and `private`.

### Direct set: `/lo:status public` or `/lo:status private`

1. Read `.lo/PROJECT.md`, note current `state` value
2. If already the requested state, report and stop:

```
State is already <state>. No changes made.
```

3. Update `state: "<target>"` in frontmatter
4. Report:

```
State changed: <old-state> → <new-state>
```

### Prompted toggle: `/lo:status state`

1. Read `.lo/PROJECT.md`, note current `state` value
2. Prompt:

```
Current state: <current-state>

Switch to:
1. public — visible in project listings, README published
2. private — hidden from listings, internal only

Choose (1/2):
```

3. Update `state: "<chosen>"` in frontmatter
4. Report:

```
State changed: <old-state> → <new-state>
```

</visibility-toggle>

---

## Examples

<example name="show-status">
User: /lo:status

Project: LO Plugin
Status: build
State: public
</example>

<example name="transition-to-build">
User: /lo:status build

Status changed: explore → build

What do you want to configure?
1. All of the below (recommended)
...

User picks 1 → runs Steps A, B, C

Build transition complete for "LO Plugin"
  Status:     build
  Tests:      f008 — 12 files to cover
  GitHub:     lo-github-sync applied
  Docs:       README.md created
</example>

<example name="set-visibility-direct">
User: /lo:status public

State changed: private → public
</example>

<example name="toggle-visibility">
User: /lo:status state

Current state: public

Switch to:
1. public — visible in project listings, README published
2. private — hidden from listings, internal only

Choose (1/2):

User picks 2 → state updated

State changed: public → private
</example>

<example name="backward-transition">
User: /lo:status explore

This moves the project backward from build to explore. Are you sure?

User confirms → status updated

Status changed: build → explore
</example>
