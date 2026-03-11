# CI Responsibility Split — Design

Eliminates duplicated checks between the local `/lo:ship` pipeline and CI. Each layer owns what it's good at — no overlap.

## Problem

Tests and `npm audit` run both locally during `/lo:ship` and again in CI on the PR. For a solo dev using an agent-driven pipeline, the local run already catches everything CI will catch. CI minutes aren't free, and the duplication adds no safety.

## Principle

**Local pipeline** = fast feedback + LLM-powered gates (security sweep, code review, EARS). Runs before push.
**CI** = clean-environment mechanical checks + authoritative merge gate. Runs on PR.
**Scheduled jobs** = drift detection (new CVEs in dependencies). Runs on a cron.

No check runs in more than one layer.

## Responsibility Matrix

| Check | Local ship | CI (per-PR) | Scheduled | Rationale |
|-------|-----------|-------------|-----------|-----------|
| Tests | Gate 3 | Unit Tests job | — | CI is authoritative clean-env check. Local is fast feedback. **Keep both** — only mechanical check that catches real regressions. |
| `npm audit` | Gate 3 (Open) | — | Weekly (Open) | Audit results depend on *when* you run (new CVEs), not *what code* changed. Local handles pre-push. Scheduled catches drift. |
| Lint | — | Lint job | — | CI-only. Fast, formatting consistency. |
| Build | — | Build job | — | CI-only. Verifies artifact in clean env. |
| LLM security sweep | Gate 5 | — | — | Can't run in CI. Local only. |
| Code review | Gate 4 | — | — | Can't run in CI. Local only. |
| EARS audit | Gate 2 | — | — | Can't run in CI. Local only. |

## Changes

### 1. Reusable CI workflow (`ci/.github/workflows/reusable-ci.yml`)

Remove the `audit` job and `has-audit` input. Remaining jobs: Gate, Lint, Unit Tests, Build.

### 2. Sync script (`lo-plugin/scripts/lo-github-sync.sh`)

- Stop generating `has-audit: true` in ci.yml for Open projects
- Add `reconcile_scheduled_audit` function:
  - Open → generate `.github/workflows/audit.yml` (weekly cron, `npm audit --audit-level=critical`)
  - Non-open → delete `audit.yml` if it exists
  - Same create/delete pattern as `auto-merge.yml`

### 3. Ship skill (`plugins/lo/skills/ship/SKILL.md`)

No change. `npm audit` stays in Gate 3 for Open projects as local fast feedback.

### 4. Status skill (`plugins/lo/skills/status/SKILL.md`)

Update Open transition wizard: reference "scheduled dependency audit" instead of "CI dependency audit".

### 5. CLAUDE.md

Update stage-aware behavior table: remove "audit" from CI column, add note about scheduled audit for Open.

### 6. Historical docs

No changes to CHANGELOG.md, STREAM.md, or prior design docs — they're accurate records of what shipped in v0.5.0.

## Files Changed

| File | Change | Size |
|------|--------|------|
| `ci/.github/workflows/reusable-ci.yml` | Remove audit job + has-audit input | Small |
| `scripts/lo-github-sync.sh` | Remove has-audit from ci.yml, add reconcile_scheduled_audit | Medium |
| `plugins/lo/skills/status/SKILL.md` | Update Open wizard wording | Small |
| `CLAUDE.md` | Update stage table | Small |

## Out of Scope

- Tests remain in both local and CI (intentional defense-in-depth)
- No per-repo changes needed today (no Open projects exist)
- Lint detection in sync script (future enhancement)
