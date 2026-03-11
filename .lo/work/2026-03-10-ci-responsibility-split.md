# CI Responsibility Split Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove per-PR audit from CI, replace with scheduled weekly audit for Open projects, update all references.

**Architecture:** Remove audit job from reusable CI workflow. Add scheduled audit workflow generation to sync script. Update skill and doc references. No per-repo changes needed today (no Open projects).

**Tech Stack:** GitHub Actions (YAML), Bash, Markdown

---

### Task 1: Remove audit job from reusable CI workflow

**Files:**
- Modify: `ci/.github/workflows/reusable-ci.yml`

Remove the `has-audit` input (lines 22-25) and the entire `audit` job (lines 107-121).

Verify: should have 5 inputs (status, has-lint, has-test, has-build, supabase-url, supabase-key) and 4 jobs (gate, lint, test, build).

---

### Task 2: Update sync script — remove has-audit, add scheduled audit

**Files:**
- Modify: `scripts/lo-github-sync.sh`

1. Remove `has-audit: true` generation from `reconcile_ci()` (2 lines)
2. Remove audit from capabilities description (1 line)
3. Add `reconcile_scheduled_audit()` function — creates `audit.yml` (weekly cron) for Open, deletes for non-Open

---

### Task 3: Update status skill — Open wizard wording

**Files:**
- Modify: `plugins/lo/skills/status/SKILL.md`

Three replacements:
- "Dependency auditing in CI" → "Scheduled weekly dependency auditing"
- "CI with dependency audit" → "CI, scheduled audit"
- "has-audit: true for dependency scanning" → "weekly scheduled audit workflow (audit.yml)"

---

### Task 4: Update CLAUDE.md — stage table and sync description

**Files:**
- Modify: `CLAUDE.md`

- Add `audit.yml` to sync script file list
- Remove `+ audit` from Open CI column
- Replace `has-audit` explanation with scheduled audit note

---

### Task 5: Push all changes

Push ci repo and lo-plugin repo.

## Implementation

Implemented in v0.5.0 release branch. See commits on the `0.5.0` branch.
