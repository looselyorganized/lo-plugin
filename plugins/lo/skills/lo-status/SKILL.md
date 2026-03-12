---
name: lo-status
description: Project dashboard and lifecycle management. Shows project status, open work, and recommends next actions. Handles transitions between explore, build, open, and closed with automation wizards (CI/CD setup, test scaffolding, branch protection). Use when user says "status", "what's next", "where am I", "move to build", "go to open", or "/lo:status".
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
metadata:
  author: looselyorganized
  version: 0.6.0
---

# LO Status

Project dashboard and lifecycle management. Two modes: dashboard (no args) shows where you are and what to do next; transition (with status name) moves the project through its lifecycle with automation wizards.

## Critical Rules

- ALWAYS read `.lo/project.yml` before making any changes.
- Backward transitions (moving toward an earlier status in explore, build, open, closed) ALWAYS require explicit user confirmation before proceeding.
- Use `last_feature` / `last_task` counters from BACKLOG.md frontmatter when adding backlog items. Never scan entries for the next ID.
- If `.lo/` does not exist, stop and tell the user: "Run /lo:setup first."

## Mode Detection

Detect from arguments:

- `/lo:status` (no args) → **Dashboard mode**
- `/lo:status build` → **Transition to build** (complex wizard)
- `/lo:status open` → **Transition to open** (complex wizard)
- `/lo:status explore` or `closed` → **Simple transition**
- `/lo:status public` or `private` → **Visibility toggle** (direct set)
- `/lo:status state` → **Visibility toggle** (prompted)

Follow ONLY the section matching the detected mode.

---

<dashboard>
## Dashboard Mode (no args)

When invoked with no arguments, show a project dashboard.

1. Read `.lo/project.yml` for title, status, state
2. Read `.lo/BACKLOG.md` for open items
3. Scan `.lo/work/` for active work directories
4. Scan `.lo/park/` for parked capture files

Categorize each BACKLOG.md item:
- **Active** — has `[active]` status line pointing to `.lo/work/`
- **Parked** — has `[parked]` status line pointing to `.lo/park/`
- **Backlog** — no status line

For active items, read plan files to determine progress (e.g., "phase 2 of 3").

Display:

```
Project: <title>
Status: <status> | State: <state>

Active:
  f009 Image Generation — phase 2 of 3

Parked:
  f010 Real-time Collab — .lo/park/f010-collab.md

Backlog:
  t015 Fix button color

Suggested next:
  Continue f009? → /lo:work f009
  Pick up f010? → /lo:plan f010
```

Suggested-next: prioritize active items (suggest `/lo:work`), then parked (suggest `/lo:plan`), then backlog features (suggest `/lo:plan`) or tasks (suggest `/lo:work`).

If every section is empty:

```
Project: <title>
Status: <status> | State: <state>

Nothing in the backlog. Add ideas with /lo:park or start planning with /lo:plan.
```

</dashboard>

---

<transition-build>
## Transition to Build

The major transition — the project is becoming real.

### Pre-flight

1. Read `.lo/project.yml`, note current status
2. If already `build`, report and stop
3. If `open` or `closed`, backward transition — require explicit confirmation
4. Update `status: "build"` in project.yml
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

Ask two questions first: "Does this project use a database?" and "Does this project have an API server?" — answers control which optional steps appear.

Present the menu:

```
What do you want to configure?

1. All of the below (recommended)
2. Scan codebase and create a test coverage plan
3. Reconcile GitHub automation (CodeRabbit, CI, branch protection, auto-merge)
4. Create README and public docs (if missing)
5. Verify database backups and migrations     ← only if database
6. Add health check endpoint                  ← only if API server

7. Skip all — just change the status
```

Items 5-6 are conditionally visible. Omit from the menu if the user said no. Adjust numbering accordingly.

Allow multiple selections. Run selected steps in order.

<build-step-a>
### Step A: Scan Codebase for Test Coverage

Scan the project for testable logic:

- **Include:** Functions with business logic, parsers, validators, data transformations, state machines, API handlers, utilities
- **Exclude:** Config files, type definitions, UI layout, markdown, thin wrappers

For each testable file/function, note: file path, what to test, priority (high/medium/low).

1. Read `last_feature` from `.lo/BACKLOG.md` frontmatter, increment by 1
2. Add to BACKLOG.md:

```markdown
- [ ] f{NNN} Test Coverage
  Retroactive test coverage for core project logic. Generated during explore → build transition.
  [active](.lo/work/f{NNN}-test-coverage/)
```

3. Update `last_feature` counter in frontmatter
4. Create `.lo/work/f{NNN}-test-coverage/001-test-coverage.md`:

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

5. Report:

```
Created: f{NNN} — Test Coverage
Plan: .lo/work/f{NNN}-test-coverage/001-test-coverage.md
Tasks: N files identified (X high, Y medium, Z low priority)

Run /lo:work f{NNN} to start writing tests.
```

</build-step-a>

<build-step-b>
### Step B: Reconcile GitHub Automation

If the sync script does not exist, warn and skip:

```
GitHub sync script not found. Skipping automation reconciliation.
You can set up CI/CD manually or add the script later.
```

If the project has a `build` script in package.json, ask before running:

```
CI build check detected (bun run build). Include in CI?

1. Yes (recommended for Next.js, static sites, bundled libraries)
2. No (APIs, scripts, or packages where tests are sufficient)
```

Then run the sync script:

If yes (or no build script in package.json):

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

If no:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix --no-build
```

Present the script output. If any items show `error`, investigate and report.

</build-step-b>

<build-step-c>
### Step C: Create README and Public Docs

1. Check if `README.md` exists at repo root
2. If missing, generate from available sources:
   - Title and description from `.lo/project.yml`
   - Stack/architecture context from `package.json` and `CLAUDE.md`
   - Prompt user for install/usage instructions if unclear
3. Present for user review before writing
4. If README already exists, skip: `README.md already exists.`

</build-step-c>

<build-step-d>
### Step D: Verify Database Backups and Migrations

Only shown if the user indicated the project uses a database.

**Migrations in version control:**

Check for migration artifacts (supabase/migrations/, prisma/migrations/, drizzle .sql/.ts files, alembic/versions/, migrations/).

- If found: report which migration tool is detected and that it is in version control.
- If not found, ask:

```
No migration directory found in version control. Do you use a migration tool?

1. Yes — I'll add it (add backlog task)
2. No database migrations needed
3. Skip
```

If task needed: read `last_task` from BACKLOG.md frontmatter, increment, add:

```markdown
- [ ] t{NNN} Add database migrations to version control
  Ensure schema changes are tracked via migration files. Triggered by Build transition.
```

Update `last_task` counter in frontmatter.

**Automated backups:**

```
Do you have automated database backups enabled?
(Supabase Pro has daily backups by default. Railway Postgres plugins include backups.)

1. Yes — already configured
2. No — add a backlog task
3. Skip
```

If task needed: read `last_task`, increment, add:

```markdown
- [ ] t{NNN} Enable automated database backups
  Configure daily automated backups for production database. Triggered by Build transition.
```

Update `last_task` counter.

</build-step-d>

<build-step-e>
### Step E: Health Check Endpoint

Only shown if the user indicated the project has an API server.

Search for common health endpoint paths (/health, healthz, readyz) in source files.

- If found: show the matching lines and ask the user to confirm it is a health endpoint.
- If not found:

```
No health check endpoint detected. A /health route that returns 200 lets
Railway and monitoring tools verify your service is running.

1. Add a backlog task to create /health endpoint
2. Skip — not needed
```

If task needed: read `last_task` from BACKLOG.md frontmatter, increment, add:

```markdown
- [ ] t{NNN} Add health check endpoint
  Create a /health endpoint returning 200 OK for monitoring and Railway health checks. Triggered by Build transition.
```

Update `last_task` counter.

</build-step-e>

### Build Summary

After all selected steps complete:

```
Build transition complete for "<project-title>"

  Status:     build
  Tests:      f{NNN} — N files to cover. Run /lo:work f{NNN} to start.
  GitHub:     lo-github-sync applied (see output above)
  Docs:       README.md [created | already exists | skipped]
  Database:   [migrations found | t{NNN} added | skipped | not applicable]
  Health:     [/health found | t{NNN} added | skipped | not applicable]
```

</transition-build>

---

<transition-open>
## Transition to Open

The project is going live — real users, real data.

### Pre-flight

1. Read `.lo/project.yml`, note current status
2. If already `open`, report and stop
3. If `explore`, block: "Projects must go through Build before Open. Run `/lo:status build` first."
4. If `closed`, backward transition — require explicit confirmation
5. Update `status: "open"` in project.yml
6. Announce:

```
Status changed: <old-status> → open

The project is now in open phase. This unlocks:
  - Railway PR deploy verification
  - Scheduled weekly dependency auditing
  - Error tracking setup
  - Uptime monitoring setup
  - Rate limiting check
```

### Select automation steps

```
What do you want to configure?

1. All of the below (recommended)
2. Reconcile GitHub automation (CodeRabbit, CI, scheduled audit, branch protection)
3. Verify Railway PR deploys are enabled
4. Set up error tracking (Sentry or similar)
5. Set up uptime monitoring
6. Add rate limiting check
7. Skip all — just change the status
```

Allow multiple selections. Run selected steps in order.

<open-step-a>
### Step A: Reconcile GitHub Automation

If the sync script does not exist, warn and skip:

```
GitHub sync script not found. Skipping automation reconciliation.
```

Otherwise, run:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

Present the output. The script generates a weekly scheduled audit workflow (audit.yml) for Open-status projects. If any items show `error`, investigate and report.

</open-step-a>

<open-step-b>
### Step B: Verify Railway PR Deploys

Ask the user: "Does this project deploy to Railway?"

If no, skip:

```
No Railway infrastructure detected. Skipping PR deploy verification.
```

If yes:

```
Railway PR deploys let you test every pull request in an isolated environment before merging.

Is Railway PR deploy enabled for this project?

1. Yes — already configured
2. No — I'll set it up (opens Railway dashboard)
3. Skip — not needed for this project
```

If "No", report the steps:

```
To enable Railway PR deploys:
  1. Open your Railway project dashboard
  2. Go to Settings → General
  3. Enable "PR Deploys"
  4. Each PR will get its own ephemeral environment

PR deploys serve as your staging environment — no separate staging service needed.
```

</open-step-b>

<open-step-c>
### Step C: Set Up Error Tracking

```
Do you have error tracking set up for this project? (Sentry, LogRocket, Highlight, etc.)

1. Yes — already configured
2. No — add a backlog task to set it up
3. Skip
```

If "No": read `last_task` from BACKLOG.md frontmatter, increment, add:

```markdown
- [ ] t{NNN} Set up error tracking
  Add error tracking (Sentry, LogRocket, or similar) to capture runtime errors in production. Triggered by Open transition.
```

Update `last_task` counter. Report: `Added: t{NNN} — Set up error tracking`

</open-step-c>

<open-step-d>
### Step D: Set Up Uptime Monitoring

```
Do you have uptime monitoring for this project? (Railway health checks, Better Stack, UptimeRobot, etc.)

1. Yes — already configured
2. No — add a backlog task to set it up
3. Skip
```

If "No": read `last_task` from BACKLOG.md frontmatter, increment, add:

```markdown
- [ ] t{NNN} Set up uptime monitoring
  Add uptime monitoring to detect downtime before users report it. Railway health checks, Better Stack, or UptimeRobot. Triggered by Open transition.
```

Update `last_task` counter. Report: `Added: t{NNN} — Set up uptime monitoring`

</open-step-d>

<open-step-e>
### Step E: Rate Limiting Check

```
Do your public endpoints have rate limiting?

1. Yes — already configured
2. No — add a backlog task to set it up
3. Skip — no public endpoints
```

If "No": read `last_task` from BACKLOG.md frontmatter, increment, add:

```markdown
- [ ] t{NNN} Add rate limiting to public endpoints
  Add basic rate limiting (per-IP) to auth endpoints and public API routes. Triggered by Open transition.
```

Update `last_task` counter. Report: `Added: t{NNN} — Add rate limiting`

</open-step-e>

### Open Summary

After all selected steps complete:

```
Open transition complete for "<project-title>"

  Status:     open
  GitHub:     lo-github-sync applied (see output above)
  Railway:    PR deploys [verified | manual setup | skipped | not detected]
  Tracking:   [configured | t{NNN} added | skipped]
  Uptime:     [configured | t{NNN} added | skipped]
  Rate limit: [configured | t{NNN} added | skipped]
```

</transition-open>

---

<simple-transition>
## Simple Transition (Explore, Closed)

Handles transitions to explore and closed.

1. Read `.lo/project.yml`, note current status
2. If already at the target status, report and stop
3. Check for backward transition (lifecycle progresses: explore, build, open, closed). Any move to an earlier status requires explicit confirmation:

   ```
   This moves the project backward from <current> to <target>. Are you sure?
   ```

   Do not proceed until the user confirms.

4. For closed: warn that this archives the project. Confirm with user.
5. Update `status: "<target>"` in project.yml
6. Run `lo-github-sync.sh --fix` if available. If not found, skip with: "GitHub sync script not found. Skipping automation sync."
7. Report:

```
Status changed: <old-status> → <new-status>
```

</simple-transition>

---

<visibility-toggle>
## Visibility Toggle (public, private, state)

Handles changing the `state` field in project.yml.

### Direct set: `/lo:status public` or `/lo:status private`

1. Read `.lo/project.yml`, note current `state`
2. If already the requested state: "State is already <state>. No changes made."
3. Update `state: "<target>"` in project.yml
4. Report: `State changed: <old-state> → <new-state>`

### Prompted toggle: `/lo:status state`

1. Read `.lo/project.yml`, note current `state`
2. Prompt:

```
Current state: <current-state>

Switch to:
1. public — visible in project listings, README published
2. private — hidden from listings, internal only

Choose (1/2):
```

3. Update `state: "<chosen>"` in project.yml
4. Report: `State changed: <old-state> → <new-state>`

</visibility-toggle>

---

## Error Handling

- `.lo/` does not exist → "Run /lo:setup first."
- Invalid transition (e.g., explore directly to open) → "Projects must go through Build before Open. Run `/lo:status build` first."
- Already at target status → report current status, no changes
- `lo-github-sync.sh` not found → skip automation, report what was skipped
- Sync script fails → report the error, continue (transition is still valid without automation)
- BACKLOG.md missing when adding items → create from template with counters at 0

## Examples

<example name="dashboard-view">
User: /lo:status

Project: Nexus
Status: build | State: public

Active:
  f009 Image Generation — phase 2 of 3

Parked:
  f010 Real-time Collab — .lo/park/f010-collab.md

Backlog:
  t015 Fix button color

Suggested next:
  Continue f009? → /lo:work f009
  Pick up f010? → /lo:plan f010
</example>

<example name="dashboard-empty">
User: /lo:status

Project: New Project
Status: explore | State: private

Nothing in the backlog. Add ideas with /lo:park or start planning with /lo:plan.
</example>

<example name="transition-to-build">
User: /lo:status build

Status changed: explore → build

What do you want to configure?
1. All of the below (recommended)
...

User picks 1 → runs Steps A through E

Build transition complete for "Nexus"
  Status:     build
  Tests:      f008 — 12 files to cover
  GitHub:     lo-github-sync applied
  Docs:       README.md created
  Database:   migrations found
  Health:     t012 added
</example>

<example name="transition-to-open">
User: /lo:status open

Status changed: build → open

What do you want to configure?
1. All of the below (recommended)
...

User picks 1 → runs Steps A through E

Open transition complete for "Nexus"
  Status:     open
  GitHub:     lo-github-sync applied
  Railway:    PR deploys verified
  Tracking:   t013 added
  Uptime:     t014 added
  Rate limit: configured
</example>

<example name="visibility-toggle">
User: /lo:status public

State changed: private → public
</example>

<example name="backward-transition">
User: /lo:status explore

This moves the project backward from build to explore. Are you sure?

User: yes

Status changed: build → explore
</example>

<example name="blocked-skip-transition">
User: /lo:status open

(current status is explore)

Projects must go through Build before Open. Run `/lo:status build` first.
</example>
