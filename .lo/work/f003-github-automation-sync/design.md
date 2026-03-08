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
| CI checks (gate + tests + build*) | off | on | on | off |
| CodeRabbit reviews | off | on | on | off |
| Branch protection | none | 1 reviewer + checks | 1 reviewer + checks | none |
| Auto-merge workflow | absent | present | present | absent |
| Auto-merge repo setting | disabled | enabled | enabled | disabled |

*Build job is optional — prompted during `/lo:status` Build transition. Recommended for projects that produce compiled artifacts (Next.js, static sites, bundled libraries). Not needed for APIs, scripts, or simple packages where tests already prove the code works. Lint dropped from CI (handled by Claude Code + CodeRabbit). CodeQL dropped (redundant with CodeRabbit at current scale).

## Architecture

### `lo-github-sync.sh` — the reconciliation script

Single Bash script checked into `lo-plugin/scripts/lo-github-sync.sh`. Called by `/lo:status` and `/lo:new` automatically. Can be run standalone with `--fix` to audit and repair drift.

```
Usage: lo-github-sync.sh [--fix]

Reads .lo/PROJECT.md status, determines target state, reconciles:
  - .coderabbit.yaml
  - .github/workflows/ci.yml (if managed)
  - .github/workflows/auto-merge.yml
  - Branch protection (GitHub API)
  - Auto-merge repo setting (GitHub API)

Without --fix: dry-run, reports what's wrong
With --fix: applies all changes
```

### What the script does

**1. Read state**
- Parse `status` from `.lo/PROJECT.md` frontmatter
- Detect repo owner/name from `git remote get-url origin`
- Detect CI capabilities from `package.json` scripts (`test`, `build`) — lint is excluded from CI
- `has-build` is auto-detected but the skill prompts the user to confirm (see Skill integration below)
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
  Branch protection          1 reviewer + test  [ok | fixed]
  Auto-merge setting         enabled            [ok | fixed]
```

### Skill integration

#### `/lo:new`
After scaffolding `.lo/`, call `lo-github-sync.sh --fix`. New projects start as `explore`, so this creates `.coderabbit.yaml` (disabled) and a dormant `ci.yml`. Nothing else.

#### `/lo:status`
After updating PROJECT.md status, call `lo-github-sync.sh --fix`. The script reads the new status and reconciles everything. The skill doesn't need transition-specific logic for GitHub automation — the script handles it all.

**Build transition prompt for `has-build`:** When transitioning to Build, if a `build` script is detected in package.json, the skill asks:

```
CI build check detected (bun run build). Include in CI?

  1. Yes (recommended for Next.js, static sites, bundled libraries)
  2. No (APIs, scripts, or packages where tests are sufficient)
```

If the user says no, pass `--no-build` to the script to skip `has-build` even though it's detected. For Open transitions or re-runs, the script uses whatever is already in ci.yml.

#### `/lo:ship`
No changes. Ship already calls `gh pr merge --auto --squash`. Auto-merge works because the repo setting and workflow are in place.

### Handling edge cases

- **Private repos on free plan**: Branch protection may not be available. Script checks and reports `skipped` instead of failing.
- **No git remote**: Script skips API calls, only writes local files. Reports `skipped (no remote)`.
- **Custom CI (nexus)**: Detected by absence of reusable workflow reference. Script leaves ci.yml alone but still reads it for check names when setting branch protection.
- **Platform's `pipeline` job name**: Script reads the actual job name from ci.yml, doesn't assume `ci`.

## Files to create/modify

1. **`lo-plugin/scripts/lo-github-sync.sh`** — New. The reconciliation script.
2. **`lo-plugin/plugins/lo/skills/status/SKILL.md`** — Remove inline GitHub automation steps (Steps B, C, auto-merge generation). Replace with: "Run `lo-github-sync.sh --fix`".
3. **`lo-plugin/plugins/lo/skills/new/SKILL.md`** — Add Step 7b: "Run `lo-github-sync.sh --fix`" after CI scaffold step.
4. **Every repo** — One-time fix by running `lo-github-sync.sh --fix` in each.

## Immediate repo fixes needed

| Repo | Status | Vis | What's wrong |
|------|--------|-----|-------------|
| lo-plugin | Build | pub | Missing ci.yml, missing .coderabbit.yaml |
| nexus | Build | priv | Custom CI (ok), missing .coderabbit.yaml |
| platform | Build | priv | Missing .coderabbit.yaml |
| content-webhook | Build | pub | Missing auto-merge.yml, missing .coderabbit.yaml |
| agent-dev-brief | Open | pub | Missing everything (CI, auto-merge, branch protection, .coderabbit.yaml) |
| cr-agent | Explore | priv | Missing .coderabbit.yaml |
| claude-dashboard | Explore | pub | Missing ci.yml, missing .coderabbit.yaml |
| telemetry-exporter | Explore | priv | Case mismatch in ci.yml (`Explore` vs `explore`), missing .coderabbit.yaml |
| yellowages | Explore | priv | Missing ci.yml, missing .coderabbit.yaml |

Note: CodeQL removed from scope (redundant with CodeRabbit at current scale). Existing CodeQL configs on cr-agent and telemetry-exporter can be left as-is or manually disabled.
