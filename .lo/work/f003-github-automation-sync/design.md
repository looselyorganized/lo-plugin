---
status: pending
feature_id: "f003"
feature: github-automation-sync
phase: design
---

# f003: GitHub Automation Sync

Standardize all GitHub automation (CodeRabbit, CodeQL, CI, auto-merge, branch protection) across LO repos, driven entirely by PROJECT.md status. Zero manual steps on project creation or status transitions.

## Permission Matrix

| Automation | Explore | Build | Open | Closed |
|-----------|---------|-------|------|--------|
| CodeRabbit reviews | disabled | enabled | enabled | disabled |
| CodeQL scanning | disabled | enabled | enabled | disabled |
| CI checks (reusable) | dormant | active | active | dormant |
| Auto-merge workflow | absent | present | present | absent |
| Branch protection | none | 1 reviewer + checks | 1 reviewer + checks | none |
| Auto-merge repo setting | disabled | enabled | enabled | disabled |

## Architecture

### `lo-github-sync.sh` — the reconciliation script

Single Bash script checked into `lo-plugin/scripts/lo-github-sync.sh`. Called by `/lo:status` and `/lo:new` automatically. Can be run standalone with `--fix` to audit and repair drift.

```
Usage: lo-github-sync.sh [--fix]

Reads .lo/PROJECT.md status, determines target state, reconciles:
  - .coderabbit.yaml
  - .github/workflows/ci.yml (if managed)
  - .github/workflows/auto-merge.yml
  - CodeQL default setup (GitHub API)
  - Branch protection (GitHub API)
  - Auto-merge repo setting (GitHub API)

Without --fix: dry-run, reports what's wrong
With --fix: applies all changes
```

### What the script does

**1. Read state**
- Parse `status` from `.lo/PROJECT.md` frontmatter
- Detect repo owner/name from `git remote get-url origin`
- Detect CI capabilities from `package.json` scripts (`lint`, `test`, `build`)
- Detect if ci.yml is managed (contains `looselyorganized/ci/.github/workflows/reusable-ci.yml`) or custom
- Detect Supabase env vars from `.env.example` / `.env.local` / `env.d.ts`

**2. Determine target state**
- `active = (status == "build" || status == "open")` (case-insensitive)
- If active: everything enabled. If not: everything disabled/removed.

**3. Reconcile each automation**

#### .coderabbit.yaml
- Active: write `reviews.enabled: true`
- Inactive: write `reviews.enabled: false`
- Always overwrite (file is fully managed)

#### .github/workflows/ci.yml
- If managed (reusable workflow reference found):
  - Active: write with detected capabilities (`has-lint`, `has-test`, `has-build`, env vars)
  - Inactive: write with just `status: explore` (dormant)
- If custom (no reusable workflow reference): don't touch
- If missing: create as managed

#### .github/workflows/auto-merge.yml
- Active: create if missing
- Inactive: delete if present

#### CodeQL default setup (API)
- Active: enable via `PATCH repos/{owner}/{repo}/code-scanning/default-setup` with `state: configured`
- Inactive: disable via `state: not-configured`
- Handle repos where Code Security isn't available (free plan private repos) gracefully

#### Branch protection (API)
- Active: enable with 1 required reviewer + detected CI check names
  - For managed CI: derive check names from calling job name + capabilities (e.g., `ci / Unit Tests`, `ci / Lint`)
  - For custom CI: read job names from ci.yml directly
  - If no CI: just require 1 reviewer, no status checks
- Inactive: delete branch protection entirely

#### Auto-merge repo setting (API)
- Active: enable via `PATCH repos/{owner}/{repo}` with `allow_auto_merge: true`
- Inactive: disable with `allow_auto_merge: false`

**4. Report**
```
lo-github-sync: <repo> (status: build)

  .coderabbit.yaml          reviews enabled    [ok | fixed]
  .github/workflows/ci.yml  build, has-test    [ok | fixed | custom]
  auto-merge.yml             present            [ok | fixed | created]
  CodeQL                     configured         [ok | fixed | skipped]
  Branch protection          1 reviewer + test  [ok | fixed]
  Auto-merge setting         enabled            [ok | fixed]
```

### Skill integration

#### `/lo:new`
After scaffolding `.lo/`, call `lo-github-sync.sh --fix`. New projects start as `explore`, so this creates `.coderabbit.yaml` (disabled) and a dormant `ci.yml`. Nothing else.

#### `/lo:status`
After updating PROJECT.md status, call `lo-github-sync.sh --fix`. The script reads the new status and reconciles everything. The skill doesn't need transition-specific logic for GitHub automation — the script handles it all.

#### `/lo:ship`
No changes. Ship already calls `gh pr merge --auto --squash`. Auto-merge works because the repo setting and workflow are in place.

### Handling edge cases

- **Private repos on free plan**: CodeQL and branch protection may not be available. Script checks and reports `skipped` instead of failing.
- **No git remote**: Script skips API calls, only writes local files. Reports `skipped (no remote)`.
- **Custom CI (nexus)**: Detected by absence of reusable workflow reference. Script leaves ci.yml alone but still reads it for check names when setting branch protection.
- **Platform's `pipeline` job name**: Script reads the actual job name from ci.yml, doesn't assume `ci`.

## Files to create/modify

1. **`lo-plugin/scripts/lo-github-sync.sh`** — New. The reconciliation script.
2. **`lo-plugin/plugins/lo/skills/status/SKILL.md`** — Remove inline GitHub automation steps (Steps B, C, auto-merge generation). Replace with: "Run `lo-github-sync.sh --fix`".
3. **`lo-plugin/plugins/lo/skills/new/SKILL.md`** — Add Step 7b: "Run `lo-github-sync.sh --fix`" after CI scaffold step.
4. **Every repo** — One-time fix by running `lo-github-sync.sh --fix` in each.

## Immediate repo fixes needed

| Repo | Status | What's wrong |
|------|--------|-------------|
| lo-plugin | build | Missing ci.yml, missing .coderabbit.yaml, no CodeQL |
| nexus | build | Missing .coderabbit.yaml, no CodeQL |
| platform | build | Missing .coderabbit.yaml, no CodeQL |
| content-webhook | build | Missing auto-merge.yml, missing .coderabbit.yaml |
| agent-dev-brief | open | Missing everything (CI, auto-merge, branch protection, .coderabbit.yaml, CodeQL) |
| cr-agent | explore | Missing .coderabbit.yaml, CodeQL enabled (shouldn't be) |
| claude-dashboard | explore | Missing ci.yml, missing .coderabbit.yaml |
| telemetry-exporter | explore | `Explore` typo in ci.yml, missing .coderabbit.yaml |
| yellowages | explore | Missing ci.yml, missing .coderabbit.yaml |
