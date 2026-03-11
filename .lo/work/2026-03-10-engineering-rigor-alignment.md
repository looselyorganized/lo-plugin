# Engineering Rigor Alignment Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Align LO plugin skills with progressive stage-based automation — Explore is fast, Build adds guardrails, Open adds production rigor.

**Architecture:** Stage-aware conditional blocks inside existing skills. No new files. The sync script gets a one-line addition for Open CI. All changes are markdown edits except the shell script.

**Tech Stack:** Markdown (Claude Code skills), Bash (sync script)

**Design doc:** `docs/plans/2026-03-10-engineering-rigor-alignment-design.md`

---

### Task 1: Ship skill — Stage-aware Gate 2 (EARS)

**Files:**
- Modify: `plugins/lo/skills/ship/SKILL.md:101-117`

**Step 1: Add status skip to Gate 2**

Replace the current Gate 2 header and skip rules:

```markdown
## Gate 2: EARS Requirements Audit

*Skip if mode is **release** — individual features already passed EARS during their own ship.*

*Skip if no `ears-requirements.md` exists in the work directory.*
```

With:

```markdown
## Gate 2: EARS Requirements Audit

*Skip if status is **Explore** or **Closed** — no formal requirements tracking at these stages.*

*Skip if mode is **release** — individual features already passed EARS during their own ship.*

*Skip if no `ears-requirements.md` exists in the work directory.*
```

The rest of Gate 2 (lines 107-117) stays unchanged.

**Step 2: Verify**

Read the file and confirm the three skip conditions appear in order: status check, release check, no-file check.

---

### Task 2: Ship skill — Stage-aware Gate 3 (Tests)

**Files:**
- Modify: `plugins/lo/skills/ship/SKILL.md:120-127`

**Step 1: Replace Gate 3 with status-conditional blocks**

Replace the entire Gate 3 section:

```markdown
## Gate 3: Run Tests

Detect the project's test runner and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests:** Warn user, ask whether to proceed.
```

With:

```markdown
## Gate 3: Run Tests

Follow ONLY the block matching the project status detected in Gate 1.

<test-gate-explore>
**Explore / Closed** — Skip this gate entirely. No output needed.
</test-gate-explore>

<test-gate-build>
**Build** — Detect the project's test runner and run tests.

- **Pass:** Report count, proceed.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests found:** Proceed. Note "No test runner detected" in the ship report — this is expected, not a warning.
</test-gate-build>

<test-gate-open>
**Open** — Detect the project's test runner and run tests. Then run dependency audit.

Tests:
- **Pass:** Report count, continue to audit.
- **Fail:** Stop. Report failures. Do not continue.
- **No tests found:** Stop. "Open-status projects require tests. Add tests before shipping, or move the project back to Build status."

Dependency audit:
```bash
# Detect package manager and run audit
npm audit --audit-level=critical 2>/dev/null || \
pnpm audit --audit-level=critical 2>/dev/null || \
bun pm audit 2>/dev/null || \
pip audit 2>/dev/null || \
echo "No supported package manager found for audit"
```

- **Clean:** Report "Audit: clean", proceed.
- **Critical vulnerabilities found:** Stop. Report vulnerabilities. Do not continue.
- **No package manager:** Proceed with a note.
</test-gate-open>
```

**Step 2: Verify**

Read the file and confirm three conditional blocks exist with correct stage labels.

---

### Task 3: Ship skill — Stage-aware Gate 4 (Reviewer)

**Files:**
- Modify: `plugins/lo/skills/ship/SKILL.md:130-142` (line numbers will have shifted after Task 2)

**Step 1: Replace Gate 4 with status-conditional blocks**

Replace the entire Gate 4 section:

```markdown
## Gate 4: Reviewer

Invoke the `reviewer` subagent (defined in `.claude-plugin/agents/reviewer.md`).

1. Get the diff:
```bash
git diff $DIFF_BASE...HEAD
```
2. Dispatch the `reviewer` subagent, passing the diff and changed file list
3. The reviewer checks for: secrets, security (OWASP), dead code, obvious bugs
4. **CLEAN** → proceed
5. **ISSUES FOUND** → present to user. Critical/high: stop. Medium/low: warn, ask.
```

With:

```markdown
## Gate 4: Reviewer

*Skip if status is **Explore** or **Closed** — no code review at these stages.*

Invoke the `reviewer` subagent (defined in `.claude-plugin/agents/reviewer.md`).

1. Get the diff:
```bash
git diff $DIFF_BASE...HEAD
```
2. Dispatch the `reviewer` subagent, passing the diff and changed file list
3. The reviewer checks for: secrets, security (OWASP), dead code, obvious bugs
4. **CLEAN** → proceed
5. **ISSUES FOUND** → present to user. Critical/high: stop. Medium/low: warn, ask.
```

**Step 2: Verify**

Read the file and confirm the skip line is present.

---

### Task 4: Ship skill — Update progress checklist and examples

**Files:**
- Modify: `plugins/lo/skills/ship/SKILL.md` (checklist near top, examples near bottom)

**Step 1: Update progress checklist**

Replace:

```
Ship Progress:
  Mode: [pending detection]
  Item: [pending detection]
  - [ ] Gate 1: Pre-flight
  - [ ] Gate 2: EARS audit
  - [ ] Gate 3: Tests
  - [ ] Gate 4: Reviewer
  - [ ] Gate 5: Ship (mode-specific)
  - [ ] Gate 6: Wrap-up
```

With:

```
Ship Progress:
  Mode: [pending detection]
  Status: [pending detection]
  Item: [pending detection]
  - [ ] Gate 1: Pre-flight
  - [ ] Gate 2: EARS audit (skip: Explore/Closed)
  - [ ] Gate 3: Tests (skip: Explore/Closed)
  - [ ] Gate 4: Reviewer (skip: Explore/Closed)
  - [ ] Gate 5: Ship (mode-specific)
  - [ ] Gate 6: Wrap-up
```

**Step 2: Update Explore fast-mode example**

Replace the explore-fast-mode example:

```markdown
<example name="explore-fast-mode">
User: /lo:ship (on feat/f003-auth, project status: Explore)

Gate 1: Pre-flight — status=Explore, branch=feat/f003-auth → **fast mode** ✓
Gate 2: EARS — skipped (no ears-requirements.md) ✓
Gate 3: Tests — 47 passed ✓
Gate 4: Reviewer — clean ✓
Gate 5+6: Fast mode ship
  - Committed: abc1234 "feat: user authentication"
  - Merged feat/f003-auth → main
  - Pushed to main
  - Backlog: f003 marked done
  - Deleted branch feat/f003-auth

Ship complete: f003 "User Authentication"
</example>
```

With:

```markdown
<example name="explore-fast-mode">
User: /lo:ship (on feat/f003-auth, project status: Explore)

Gate 1: Pre-flight — status=Explore, branch=feat/f003-auth → **fast mode** ✓
Gate 2: EARS — skipped (Explore) ✓
Gate 3: Tests — skipped (Explore) ✓
Gate 4: Reviewer — skipped (Explore) ✓
Gate 5+6: Fast mode ship
  - Committed: abc1234 "feat: user authentication"
  - Merged feat/f003-auth → main
  - Pushed to main
  - Backlog: f003 marked done
  - Deleted branch feat/f003-auth

Ship complete: f003 "User Authentication"
</example>
```

**Step 3: Update fast-mode report template**

In the fast-mode section, replace the report:

```
Ship complete: <item> "<name>"
  Tests:    passed (N tests)
  Reviewer: clean
  Commit:   <hash> "<message>"
  Pushed:   main
  Backlog:  marked done
```

With:

```
Ship complete: <item> "<name>"
  Commit:   <hash> "<message>"
  Pushed:   main
  Backlog:  marked done
```

(Remove Tests and Reviewer lines — they didn't run in Explore.)

**Step 4: Commit**

```bash
git add plugins/lo/skills/ship/SKILL.md
git commit -m "feat: stage-aware ship gates — Explore skips Gates 2-4, Open adds audit"
```

---

### Task 5: Status skill — Open transition wizard

**Files:**
- Modify: `plugins/lo/skills/status/SKILL.md:39-43` (mode detection)
- Modify: `plugins/lo/skills/status/SKILL.md:220-264` (simple-transition section)

**Step 1: Update mode detection**

Replace:

```markdown
- `/lo:status open` or `closed` or `explore` → **simple transition**
```

With:

```markdown
- `/lo:status open` → **transition to open** (complex — has sub-steps)
- `/lo:status closed` or `explore` → **simple transition**
```

**Step 2: Update simple-transition section**

Replace the opening of the simple-transition section:

```markdown
<simple-transition>
## Simple Transition (Open, Closed, Explore)

This section handles transitions to Open, Closed, and Explore. These are simpler than Build — they update the status and run the sync script.
```

With:

```markdown
<simple-transition>
## Simple Transition (Closed, Explore)

This section handles transitions to Closed and Explore. These are simpler — they update the status and run the sync script.
```

**Step 3: Add the Open transition wizard**

Insert a new section between `</transition-build>` and `<simple-transition>`. The full content:

```markdown
<transition-open>
## Transition to Open

The project is going live — real users, real data. Multiple automation steps follow.

### Pre-flight

1. Read `.lo/PROJECT.md`, note current status
2. If already `open`, report and stop
3. If current status is `closed`, ask for explicit confirmation before proceeding (backward transition). Stop until user confirms.
4. Update `status: "open"` in frontmatter
5. Announce:

```
Status changed: <old-status> → open

The project is now in open phase. This unlocks:
  - Railway PR deploy verification
  - Dependency auditing in CI
  - Error tracking setup
  - Uptime monitoring setup
  - Rate limiting check
```

### Select automation steps

Ask the user what to set up:

```
What do you want to configure?

1. All of the below (recommended)
2. Reconcile GitHub automation (CodeRabbit, CI with dependency audit, branch protection)
3. Verify Railway PR deploys are enabled
4. Set up error tracking (Sentry or similar)
5. Set up uptime monitoring
6. Add rate limiting check
7. Skip all — just change the status
```

Allow multiple selections. Run selected steps in order.

<open-step-a>
### Step A: Reconcile GitHub Automation

If the sync script doesn't exist, warn and skip:

```
GitHub sync script not found. Skipping automation reconciliation.
```

Otherwise, run:

```bash
"$(git rev-parse --show-toplevel)/scripts/lo-github-sync.sh" --fix
```

Present the script's output. The script now generates Open-specific CI with `has-audit: true` for dependency scanning. If any items show `error`, investigate and report.

</open-step-a>

<open-step-b>
### Step B: Verify Railway PR Deploys

Check if the project has Railway infrastructure by reading `.lo/PROJECT.md` frontmatter `infrastructure` field.

**If Railway is not in infrastructure:** Skip with note:

```
No Railway infrastructure detected. Skipping PR deploy verification.
```

**If Railway detected:**

```
Railway PR deploys let you test every pull request in an isolated environment before merging.

Is Railway PR deploy enabled for this project?

1. Yes — already configured
2. No — I'll set it up (opens Railway dashboard)
3. Skip — not needed for this project
```

If "No": Report the steps to enable it:

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

If "No": Determine next task ID from `.lo/BACKLOG.md` and add:

```markdown
- [ ] t{NNN} Set up error tracking
  Add error tracking (Sentry, LogRocket, or similar) to capture runtime errors in production. Triggered by Open transition.
```

Report:

```
Added: t{NNN} — Set up error tracking
```

</open-step-c>

<open-step-d>
### Step D: Set Up Uptime Monitoring

```
Do you have uptime monitoring for this project? (Railway health checks, Better Stack, UptimeRobot, etc.)

1. Yes — already configured
2. No — add a backlog task to set it up
3. Skip
```

If "No": Determine next task ID from `.lo/BACKLOG.md` and add:

```markdown
- [ ] t{NNN} Set up uptime monitoring
  Add uptime monitoring to detect downtime before users report it. Railway health checks, Better Stack, or UptimeRobot. Triggered by Open transition.
```

Report:

```
Added: t{NNN} — Set up uptime monitoring
```

</open-step-d>

<open-step-e>
### Step E: Rate Limiting Check

```
Do your public endpoints have rate limiting?

1. Yes — already configured
2. No — add a backlog task to set it up
3. Skip — no public endpoints
```

If "No": Determine next task ID from `.lo/BACKLOG.md` and add:

```markdown
- [ ] t{NNN} Add rate limiting to public endpoints
  Add basic rate limiting (per-IP) to auth endpoints and public API routes. Triggered by Open transition.
```

Report:

```
Added: t{NNN} — Add rate limiting
```

</open-step-e>

### Final Summary

After all selected steps complete:

```
Open transition complete for "<project-title>"

  Status:     open
  GitHub:     lo-github-sync applied (see output above)
  Railway:    PR deploys [verified | task added | skipped | not detected]
  Tracking:   [configured | t{NNN} added | skipped]
  Uptime:     [configured | t{NNN} added | skipped]
  Rate limit: [configured | t{NNN} added | skipped]
```

</transition-open>
```

**Step 4: Update examples**

Add an Open transition example after the existing examples:

```markdown
<example name="transition-to-open">
User: /lo:status open

Status changed: build → open

What do you want to configure?
1. All of the below (recommended)
...

User picks 1 → runs Steps A through E

Open transition complete for "My Project"
  Status:     open
  GitHub:     lo-github-sync applied
  Railway:    PR deploys verified
  Tracking:   t012 added
  Uptime:     t013 added
  Rate limit: configured
</example>
```

**Step 5: Commit**

```bash
git add plugins/lo/skills/status/SKILL.md
git commit -m "feat: Open transition wizard with Railway PR deploys, tracking, monitoring"
```

---

### Task 6: Status skill — Build conditional infra steps

**Files:**
- Modify: `plugins/lo/skills/status/SKILL.md` (build transition section)

**Step 1: Update the Build menu**

Replace the menu in the "Select automation steps" section:

```markdown
```
What do you want to configure?

1. All of the below (recommended)
2. Scan codebase and create a test coverage plan
3. Reconcile GitHub automation (CodeRabbit, CI, branch protection, auto-merge)
4. Create README and public docs (if missing)
5. Skip all — just change the status
```
```

With:

```markdown
Scan `.lo/PROJECT.md` frontmatter for `infrastructure` and `stack` to determine which optional steps to show.

```
What do you want to configure?

1. All of the below (recommended)
2. Scan codebase and create a test coverage plan
3. Reconcile GitHub automation (CodeRabbit, CI, branch protection, auto-merge)
4. Create README and public docs (if missing)
5. Verify database backups and migrations     ← only if infrastructure includes a database (Supabase, Railway Postgres, Prisma, Drizzle, etc.)
6. Add health check endpoint                  ← only if stack includes an API framework (Hono, Express, Fastify, Next.js, etc.)
7. Skip all — just change the status
```

Items 5-6 are **conditionally visible** — omit them from the menu if the project has no database or no server. Adjust numbering accordingly.
```

**Step 2: Add Step D (database) after build-step-c closing tag**

Insert after `</build-step-c>`:

```markdown
<build-step-d>
### Step D: Verify Database Backups and Migrations

*Only shown if `.lo/PROJECT.md` infrastructure includes a database.*

Check the project for database-related setup:

**Migrations in version control:**

```bash
# Check for common migration directories
ls -d supabase/migrations/ prisma/ drizzle/ alembic/ migrations/ 2>/dev/null
```

- If found: Report which migration tool is detected and that it's in version control. ✓
- If not found: Ask the user:

```
No migration directory found in version control. Do you use a migration tool?

1. Yes — I'll add it (add backlog task)
2. No database migrations needed
3. Skip
```

If task needed, add to BACKLOG.md:

```markdown
- [ ] t{NNN} Add database migrations to version control
  Ensure schema changes are tracked via migration files. Triggered by Build transition.
```

**Automated backups:**

```
Do you have automated database backups enabled?
(Supabase Pro has daily backups by default. Railway Postgres plugins include backups.)

1. Yes — already configured
2. No — add a backlog task
3. Skip
```

If task needed, add to BACKLOG.md:

```markdown
- [ ] t{NNN} Enable automated database backups
  Configure daily automated backups for production database. Triggered by Build transition.
```

</build-step-d>

<build-step-e>
### Step E: Health Check Endpoint

*Only shown if project stack includes an API framework.*

```bash
# Search for existing health check
grep -r "health" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l . 2>/dev/null | head -5
```

- If a health route is found: Report it. ✓
- If not found:

```
No health check endpoint detected. A /health route that returns 200 lets Railway and monitoring tools verify your service is running.

1. Add a backlog task to create /health endpoint
2. Skip — not needed
```

If task needed, add to BACKLOG.md:

```markdown
- [ ] t{NNN} Add health check endpoint
  Create a /health endpoint returning 200 OK for monitoring and Railway health checks. Triggered by Build transition.
```

</build-step-e>
```

**Step 3: Update Final Summary**

Replace the Build transition final summary:

```markdown
```
Build transition complete for "<project-title>"

  Status:     build
  Tests:      f{NNN} — N files to cover. Run /lo:work f{NNN} to start.
  GitHub:     lo-github-sync applied (see output above)
  Docs:       README.md [created | already exists | skipped]
```
```

With:

```markdown
```
Build transition complete for "<project-title>"

  Status:     build
  Tests:      f{NNN} — N files to cover. Run /lo:work f{NNN} to start.
  GitHub:     lo-github-sync applied (see output above)
  Docs:       README.md [created | already exists | skipped]
  Database:   [migrations ✓, backups ✓ | t{NNN} added | skipped | not detected]
  Health:     [/health found | t{NNN} added | skipped | not detected]
```
```

**Step 4: Commit**

```bash
git add plugins/lo/skills/status/SKILL.md
git commit -m "feat: Build transition adds conditional DB backup and health check steps"
```

---

### Task 7: Sync script — Add `has-audit` for Open status

**Files:**
- Modify: `scripts/lo-github-sync.sh:146-171`

**Step 1: Add has-audit to CI generation**

In the `reconcile_ci()` function, after the line that conditionally adds `has-build`:

```bash
    if [[ "$HAS_BUILD" == "true" ]]; then TARGET="${TARGET}
      has-build: true"; fi
```

Add:

```bash
    if [[ "$STATUS" == "open" ]]; then TARGET="${TARGET}
      has-audit: true"; fi
```

**Step 2: Update the description variable**

After the existing capabilities line:

```bash
    [[ "$HAS_BUILD" == "true" ]] && CAPS="${CAPS}, build"
```

Add:

```bash
    [[ "$STATUS" == "open" ]] && CAPS="${CAPS}, audit"
```

**Step 3: Commit**

```bash
git add scripts/lo-github-sync.sh
git commit -m "feat: sync script adds has-audit to CI for Open-status projects"
```

---

### Task 8: New skill — .gitignore verification

**Files:**
- Modify: `plugins/lo/skills/new/SKILL.md` (between Step 2 and Step 3)

**Step 1: Add Step 2h after Step 2g**

Insert after the `#### 2g: Auto-fill from Codebase` section (before `### Step 3: Create Directory Structure`):

```markdown
#### 2h: Verify .gitignore

Check if `.gitignore` exists at the repo root.

**If missing:** Generate a default based on detected stack:

| Stack | Default .gitignore entries |
|-------|---------------------------|
| Node/Bun | `node_modules/`, `.env`, `.env.local`, `.env*.local`, `.next/`, `dist/`, `.turbo/` |
| Rust | `target/`, `.env` |
| Go | `.env`, `bin/` |
| Python | `__pycache__/`, `.env`, `venv/`, `.venv/`, `dist/`, `*.egg-info/` |
| Any | `.env`, `.DS_Store` |

Always include `.env` and `.DS_Store`. Add stack-specific entries on top. Present the proposed `.gitignore` to the user for review before writing.

**If exists:** Check whether `.env` is covered:

```bash
grep -q '\.env' .gitignore
```

If `.env` is not in `.gitignore`, warn:

```
Your .gitignore doesn't exclude .env files. This risks committing secrets.
Add .env to .gitignore?
```

If user confirms, append `.env` to the file.

**If exists and covers .env:** No action needed.
```

**Step 2: Commit**

```bash
git add plugins/lo/skills/new/SKILL.md
git commit -m "feat: /lo:new verifies .gitignore exists and covers .env"
```

---

### Task 9: Stream skill — Broaden quality gate

**Files:**
- Modify: `plugins/lo/skills/stream/SKILL.md:19-21` (critical block)
- Modify: `plugins/lo/skills/stream/SKILL.md:143-154` (what qualifies/doesn't qualify)

**Step 1: Update the critical block quality gate**

Replace:

```markdown
<critical>
Quality gate: would you post this? If you wouldn't put it on the project page or tweet it, it's not a stream entry. Git history already captures the small stuff.
Never create duplicate entries. Always read existing stream entries first.
</critical>
```

With:

```markdown
<critical>
Quality gate: would this be interesting to someone following the project? Milestones, key decisions, pivots, and lessons learned all qualify. Routine fixes, config changes, and dependency updates do not. Git history already captures the small stuff.
Never create duplicate entries. Always read existing stream entries first.
</critical>
```

**Step 2: Update the "What qualifies" list**

Replace:

```markdown
**What qualifies:**
- A version release (always)
- A major feature landing that changes how the project works
- A research article published
- A significant architectural decision or pivot
```

With:

```markdown
**What qualifies:**
- A version release (always)
- A major feature landing that changes how the project works
- A research article published
- A significant architectural decision or pivot
- A lesson learned or challenge overcome that other builders would find useful
```

**Step 3: Commit**

```bash
git add plugins/lo/skills/stream/SKILL.md
git commit -m "feat: broaden stream quality gate to include decisions and lessons"
```

---

### Task 10: Update design doc with completion note

**Files:**
- Modify: `docs/plans/2026-03-10-engineering-rigor-alignment-design.md`

**Step 1: Add completion note**

Add at the bottom of the design doc:

```markdown

## Implementation

Implemented in v0.5.0 release branch. See commits on the `0.5.0` branch.
```

**Step 2: Final commit**

```bash
git add docs/plans/2026-03-10-engineering-rigor-alignment-design.md
git commit -m "docs: mark engineering rigor design as implemented"
```
