# f003: GitHub Automation Sync — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Single script (`lo-github-sync.sh`) that reconciles all GitHub automation (CodeRabbit, CodeQL, CI, auto-merge, branch protection) to match PROJECT.md status. Skills call it automatically. Zero manual steps.

**Architecture:** Bash script reads `.lo/PROJECT.md` status, determines active (build/open) vs inactive (explore/closed), writes local config files and makes GitHub API calls to reconcile. Skills (`/lo:status`, `/lo:new`) call it after updating status. `--fix` applies changes, without it is dry-run.

**Tech Stack:** Bash, gh CLI, yq-style grep parsing, GitHub REST API

---

### Task 1: Create `lo-github-sync.sh` — State Detection

**Files:**
- Create: `scripts/lo-github-sync.sh`

**Step 1: Create the script with argument parsing and state detection**

```bash
#!/usr/bin/env bash
set -euo pipefail

# lo-github-sync.sh — Reconcile GitHub automation to match PROJECT.md status
# Usage: lo-github-sync.sh [--fix]
#   Without --fix: dry-run, reports what needs to change
#   With --fix: applies all changes

FIX=false
for arg in "$@"; do
  case "$arg" in
    --fix) FIX=true ;;
    *) echo "Unknown argument: $arg"; echo "Usage: lo-github-sync.sh [--fix]"; exit 1 ;;
  esac
done

# ── Colors ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()      { echo -e "  ${GREEN}ok${NC}       $1"; }
fixed()   { echo -e "  ${CYAN}fixed${NC}    $1"; }
skipped() { echo -e "  ${YELLOW}skipped${NC}  $1"; }
dryrun()  { echo -e "  ${YELLOW}dryrun${NC}  $1"; }
err()     { echo -e "  ${RED}error${NC}    $1"; }

# ── Read PROJECT.md status ────────────────────────────────────────────────
if [[ ! -f ".lo/PROJECT.md" ]]; then
  echo "No .lo/PROJECT.md found. Run /lo:new first."
  exit 1
fi

STATUS=$(grep -m1 '^status:' .lo/PROJECT.md | sed 's/status:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}/\1/' | tr '[:upper:]' '[:lower:]' | xargs)
if [[ -z "$STATUS" ]]; then
  echo "Could not parse status from .lo/PROJECT.md"
  exit 1
fi

# Active = build or open
ACTIVE=false
if [[ "$STATUS" == "build" || "$STATUS" == "open" ]]; then
  ACTIVE=true
fi

# ── Detect repo owner/name from git remote ────────────────────────────────
REMOTE=""
OWNER=""
REPO=""
HAS_REMOTE=false
if git remote get-url origin &>/dev/null; then
  REMOTE=$(git remote get-url origin)
  # Handle both HTTPS and SSH URLs
  OWNER_REPO=$(echo "$REMOTE" | sed -E 's#.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$#\1#')
  OWNER=$(echo "$OWNER_REPO" | cut -d/ -f1)
  REPO=$(echo "$OWNER_REPO" | cut -d/ -f2)
  HAS_REMOTE=true
fi

# ── Detect CI capabilities from package.json ──────────────────────────────
HAS_LINT=false
HAS_TEST=false
HAS_BUILD=false
if [[ -f "package.json" ]]; then
  SCRIPTS=$(cat package.json | grep -A 100 '"scripts"' | grep -B 0 '}' -m1 | head -20 || true)
  if echo "$SCRIPTS" | grep -q '"lint"'; then HAS_LINT=true; fi
  if echo "$SCRIPTS" | grep -q '"test"'; then HAS_TEST=true; fi
  if echo "$SCRIPTS" | grep -q '"build"'; then HAS_BUILD=true; fi
fi

# ── Detect Supabase env vars ──────────────────────────────────────────────
SUPABASE_URL=""
SUPABASE_KEY=""
for envfile in .env.example .env.template .env.local.example env.d.ts; do
  if [[ -f "$envfile" ]]; then
    URL_MATCH=$(grep -oE 'https://[a-z0-9]+\.supabase\.co' "$envfile" 2>/dev/null | head -1 || true)
    KEY_MATCH=$(grep -oE 'sb_publishable_[A-Za-z0-9_-]+' "$envfile" 2>/dev/null | head -1 || true)
    if [[ -n "$URL_MATCH" && -z "$SUPABASE_URL" ]]; then SUPABASE_URL="$URL_MATCH"; fi
    if [[ -n "$KEY_MATCH" && -z "$SUPABASE_KEY" ]]; then SUPABASE_KEY="$KEY_MATCH"; fi
  fi
done

# ── Detect if ci.yml is managed or custom ─────────────────────────────────
CI_MANAGED=false
CI_EXISTS=false
CI_JOB_NAME=""
if [[ -f ".github/workflows/ci.yml" ]]; then
  CI_EXISTS=true
  if grep -q 'looselyorganized/ci/.github/workflows/reusable-ci.yml' .github/workflows/ci.yml; then
    CI_MANAGED=true
    CI_JOB_NAME=$(grep -E '^\s+\w+:' .github/workflows/ci.yml | grep -B1 'uses:' | head -1 | sed 's/[: ]//g' || echo "ci")
  else
    # Custom CI — read job names for branch protection
    CI_JOB_NAME="custom"
  fi
fi

echo ""
echo "lo-github-sync: ${OWNER}/${REPO} (status: ${STATUS}, active: ${ACTIVE})"
if [[ "$FIX" == "false" ]]; then
  echo -e "${YELLOW}DRY RUN — pass --fix to apply changes${NC}"
fi
echo ""
```

**Step 2: Make it executable and verify it parses state correctly**

Run from a repo with `.lo/PROJECT.md`:
```bash
chmod +x scripts/lo-github-sync.sh
cd /Users/bigviking/Documents/github/projects/lo/content-webhook
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
```

Expected: prints repo name, status `build`, active `true`, then exits.

**Step 3: Commit**

```bash
git add scripts/lo-github-sync.sh
git commit -m "feat(f003): add lo-github-sync.sh state detection"
```

---

### Task 2: Add `.coderabbit.yaml` reconciliation

**Files:**
- Modify: `scripts/lo-github-sync.sh`

**Step 1: Add coderabbit reconciliation function**

Append before the final report section:

```bash
# ── .coderabbit.yaml ─────────────────────────────────────────────────────
reconcile_coderabbit() {
  local TARGET_ENABLED="false"
  if [[ "$ACTIVE" == "true" ]]; then TARGET_ENABLED="true"; fi

  local TARGET_CONTENT="# Auto-generated by lo-github-sync — do not edit manually
reviews:
  enabled: ${TARGET_ENABLED}"

  if [[ -f ".coderabbit.yaml" ]]; then
    CURRENT=$(cat .coderabbit.yaml)
    if [[ "$CURRENT" == "$TARGET_CONTENT" ]]; then
      ok ".coderabbit.yaml          reviews.enabled: ${TARGET_ENABLED}"
      return
    fi
  fi

  if [[ "$FIX" == "true" ]]; then
    echo "$TARGET_CONTENT" > .coderabbit.yaml
    fixed ".coderabbit.yaml          reviews.enabled: ${TARGET_ENABLED}"
  else
    dryrun ".coderabbit.yaml          reviews.enabled: ${TARGET_ENABLED}"
  fi
}

reconcile_coderabbit
```

**Step 2: Test dry-run and fix modes**

```bash
cd /Users/bigviking/Documents/github/projects/lo/content-webhook
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
# Should show: dryrun .coderabbit.yaml reviews.enabled: true

/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh --fix
# Should show: fixed .coderabbit.yaml reviews.enabled: true
cat .coderabbit.yaml
# Should show reviews.enabled: true

/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
# Should now show: ok .coderabbit.yaml reviews.enabled: true
```

**Step 3: Commit**

```bash
git add scripts/lo-github-sync.sh
git commit -m "feat(f003): add .coderabbit.yaml reconciliation"
```

---

### Task 3: Add CI workflow reconciliation

**Files:**
- Modify: `scripts/lo-github-sync.sh`

**Step 1: Add CI reconciliation function**

```bash
# ── .github/workflows/ci.yml ─────────────────────────────────────────────
reconcile_ci() {
  # Custom CI — don't touch
  if [[ "$CI_EXISTS" == "true" && "$CI_MANAGED" == "false" ]]; then
    ok ".github/workflows/ci.yml   custom (not managed)"
    return
  fi

  # Build target content
  local TARGET=""
  if [[ "$ACTIVE" == "true" ]]; then
    TARGET="# Auto-generated by lo-github-sync — do not edit manually
name: CI
on:
  pull_request:
    branches: [main]
jobs:
  ci:
    uses: looselyorganized/ci/.github/workflows/reusable-ci.yml@main
    with:
      status: ${STATUS}"
    if [[ "$HAS_LINT" == "true" ]]; then TARGET="${TARGET}
      has-lint: true"; fi
    if [[ "$HAS_TEST" == "true" ]]; then TARGET="${TARGET}
      has-test: true"; fi
    if [[ "$HAS_BUILD" == "true" ]]; then TARGET="${TARGET}
      has-build: true"; fi
    if [[ -n "$SUPABASE_URL" ]]; then TARGET="${TARGET}
      supabase-url: ${SUPABASE_URL}"; fi
    if [[ -n "$SUPABASE_KEY" ]]; then TARGET="${TARGET}
      supabase-key: ${SUPABASE_KEY}"; fi

    local DESC="${STATUS}"
    [[ "$HAS_LINT" == "true" ]] && DESC="${DESC}, lint"
    [[ "$HAS_TEST" == "true" ]] && DESC="${DESC}, test"
    [[ "$HAS_BUILD" == "true" ]] && DESC="${DESC}, build"
  else
    TARGET="# Auto-generated by lo-github-sync — do not edit manually
name: CI
on:
  pull_request:
    branches: [main]
jobs:
  ci:
    uses: looselyorganized/ci/.github/workflows/reusable-ci.yml@main
    with:
      status: ${STATUS}"
    local DESC="${STATUS} (dormant)"
  fi

  if [[ "$CI_EXISTS" == "true" ]]; then
    CURRENT=$(cat .github/workflows/ci.yml)
    if [[ "$CURRENT" == "$TARGET" ]]; then
      ok ".github/workflows/ci.yml   ${DESC}"
      return
    fi
  fi

  if [[ "$FIX" == "true" ]]; then
    mkdir -p .github/workflows
    echo "$TARGET" > .github/workflows/ci.yml
    fixed ".github/workflows/ci.yml   ${DESC}"
  else
    dryrun ".github/workflows/ci.yml   ${DESC}"
  fi
}

reconcile_ci
```

**Step 2: Test against a repo with existing managed CI**

```bash
cd /Users/bigviking/Documents/github/projects/lo/content-webhook
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
```

Expected: shows dryrun or ok for ci.yml with detected capabilities.

**Step 3: Test against a repo with no CI**

```bash
cd /Users/bigviking/Documents/github/projects/lo/claude-dashboard
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
```

Expected: shows dryrun for ci.yml with `explore (dormant)`.

**Step 4: Commit**

```bash
git add scripts/lo-github-sync.sh
git commit -m "feat(f003): add CI workflow reconciliation"
```

---

### Task 4: Add auto-merge workflow reconciliation

**Files:**
- Modify: `scripts/lo-github-sync.sh`

**Step 1: Add auto-merge reconciliation function**

```bash
# ── .github/workflows/auto-merge.yml ─────────────────────────────────────
reconcile_auto_merge_workflow() {
  local TARGET_CONTENT='# Auto-generated by lo-github-sync — do not edit manually
name: Auto-merge
on:
  pull_request:
    types: [opened]
    branches: [main]

jobs:
  enable-auto-merge:
    runs-on: ubuntu-latest
    steps:
      - name: Enable auto-merge (squash)
        env:
          GH_TOKEN: ${{ github.token }}
          PR_NUMBER: ${{ github.event.number }}
          REPO: ${{ github.repository }}
        run: gh pr merge "$PR_NUMBER" --auto --squash --repo "$REPO"'

  if [[ "$ACTIVE" == "true" ]]; then
    if [[ -f ".github/workflows/auto-merge.yml" ]]; then
      CURRENT=$(cat .github/workflows/auto-merge.yml)
      if [[ "$CURRENT" == "$TARGET_CONTENT" ]]; then
        ok "auto-merge.yml             present"
        return
      fi
    fi
    if [[ "$FIX" == "true" ]]; then
      mkdir -p .github/workflows
      echo "$TARGET_CONTENT" > .github/workflows/auto-merge.yml
      fixed "auto-merge.yml             present"
    else
      dryrun "auto-merge.yml             needs creation"
    fi
  else
    if [[ -f ".github/workflows/auto-merge.yml" ]]; then
      if [[ "$FIX" == "true" ]]; then
        rm .github/workflows/auto-merge.yml
        fixed "auto-merge.yml             removed"
      else
        dryrun "auto-merge.yml             needs removal"
      fi
    else
      ok "auto-merge.yml             absent"
    fi
  fi
}

reconcile_auto_merge_workflow
```

**Step 2: Test both active and inactive repos**

```bash
# Active repo — should want to create
cd /Users/bigviking/Documents/github/projects/lo/content-webhook
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh

# Inactive repo — should be ok (absent)
cd /Users/bigviking/Documents/github/projects/lo/cr-agent
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
```

**Step 3: Commit**

```bash
git add scripts/lo-github-sync.sh
git commit -m "feat(f003): add auto-merge workflow reconciliation"
```

---

### Task 5: Add GitHub API reconciliation (CodeQL, branch protection, auto-merge setting)

**Files:**
- Modify: `scripts/lo-github-sync.sh`

**Step 1: Add CodeQL reconciliation**

```bash
# ── CodeQL default setup (API) ────────────────────────────────────────────
reconcile_codeql() {
  if [[ "$HAS_REMOTE" == "false" ]]; then
    skipped "CodeQL                     no remote"
    return
  fi

  # Check current state
  local CURRENT_STATE
  CURRENT_STATE=$(gh api "repos/${OWNER}/${REPO}/code-scanning/default-setup" --jq '.state' 2>/dev/null || echo "unavailable")

  if [[ "$CURRENT_STATE" == "unavailable" ]]; then
    skipped "CodeQL                     not available (plan/permissions)"
    return
  fi

  if [[ "$ACTIVE" == "true" ]]; then
    if [[ "$CURRENT_STATE" == "configured" ]]; then
      ok "CodeQL                     configured"
      return
    fi
    if [[ "$FIX" == "true" ]]; then
      gh api "repos/${OWNER}/${REPO}/code-scanning/default-setup" \
        --method PATCH \
        --input - <<< '{"state": "configured"}' >/dev/null 2>&1 \
        && fixed "CodeQL                     configured" \
        || err "CodeQL                     failed to configure"
    else
      dryrun "CodeQL                     needs configuration"
    fi
  else
    if [[ "$CURRENT_STATE" == "not-configured" ]]; then
      ok "CodeQL                     not configured"
      return
    fi
    if [[ "$FIX" == "true" ]]; then
      gh api "repos/${OWNER}/${REPO}/code-scanning/default-setup" \
        --method PATCH \
        --input - <<< '{"state": "not-configured"}' >/dev/null 2>&1 \
        && fixed "CodeQL                     disabled" \
        || err "CodeQL                     failed to disable"
    else
      dryrun "CodeQL                     needs disabling"
    fi
  fi
}

reconcile_codeql
```

**Step 2: Add auto-merge repo setting reconciliation**

```bash
# ── Auto-merge repo setting (API) ─────────────────────────────────────────
reconcile_auto_merge_setting() {
  if [[ "$HAS_REMOTE" == "false" ]]; then
    skipped "Auto-merge setting         no remote"
    return
  fi

  local CURRENT
  CURRENT=$(gh api "repos/${OWNER}/${REPO}" --jq '.allow_auto_merge' 2>/dev/null || echo "unknown")

  if [[ "$ACTIVE" == "true" ]]; then
    if [[ "$CURRENT" == "true" ]]; then
      ok "Auto-merge setting         enabled"
      return
    fi
    if [[ "$FIX" == "true" ]]; then
      gh api "repos/${OWNER}/${REPO}" --method PATCH \
        --input - <<< '{"allow_auto_merge": true}' >/dev/null 2>&1 \
        && fixed "Auto-merge setting         enabled" \
        || err "Auto-merge setting         failed to enable"
    else
      dryrun "Auto-merge setting         needs enabling"
    fi
  else
    if [[ "$CURRENT" == "false" ]]; then
      ok "Auto-merge setting         disabled"
      return
    fi
    if [[ "$FIX" == "true" ]]; then
      gh api "repos/${OWNER}/${REPO}" --method PATCH \
        --input - <<< '{"allow_auto_merge": false}' >/dev/null 2>&1 \
        && fixed "Auto-merge setting         disabled" \
        || err "Auto-merge setting         failed to disable"
    else
      dryrun "Auto-merge setting         needs disabling"
    fi
  fi
}

reconcile_auto_merge_setting
```

**Step 3: Add branch protection reconciliation**

```bash
# ── Branch protection (API) ───────────────────────────────────────────────
reconcile_branch_protection() {
  if [[ "$HAS_REMOTE" == "false" ]]; then
    skipped "Branch protection          no remote"
    return
  fi

  # Check current state
  local CURRENT_STATUS
  CURRENT_STATUS=$(gh api "repos/${OWNER}/${REPO}/branches/main/protection" --jq '.required_pull_request_reviews.required_approving_review_count' 2>/dev/null || echo "none")

  if [[ "$ACTIVE" == "true" ]]; then
    # Build the required checks list
    local CHECKS="[]"
    local CHECK_DESC="1 reviewer"

    if [[ "$CI_EXISTS" == "true" ]]; then
      local CHECKS_ARRAY=()

      if [[ "$CI_MANAGED" == "true" ]]; then
        # Managed CI: derive check names from job name + capabilities
        local JOB=$CI_JOB_NAME
        [[ -z "$JOB" ]] && JOB="ci"
        [[ "$HAS_LINT" == "true" ]] && CHECKS_ARRAY+=("{\"context\": \"${JOB} / Lint\"}")
        [[ "$HAS_TEST" == "true" ]] && CHECKS_ARRAY+=("{\"context\": \"${JOB} / Unit Tests\"}")
        [[ "$HAS_BUILD" == "true" ]] && CHECKS_ARRAY+=("{\"context\": \"${JOB} / Build\"}")
      else
        # Custom CI: read job names directly from ci.yml
        while IFS= read -r job_name; do
          [[ -n "$job_name" ]] && CHECKS_ARRAY+=("{\"context\": \"${job_name}\"}")
        done < <(grep -E '^\s+[a-zA-Z_-]+:' .github/workflows/ci.yml | grep -v 'uses:\|name:\|on:\|branches:\|jobs:' | sed 's/[: ]//g' | head -5)
      fi

      if [[ ${#CHECKS_ARRAY[@]} -gt 0 ]]; then
        CHECKS=$(printf '%s,' "${CHECKS_ARRAY[@]}")
        CHECKS="[${CHECKS%,}]"
        CHECK_DESC="1 reviewer + checks"
      fi
    fi

    if [[ "$CURRENT_STATUS" == "1" ]]; then
      ok "Branch protection          ${CHECK_DESC}"
      return
    fi

    if [[ "$FIX" == "true" ]]; then
      local PAYLOAD
      if [[ "$CHECKS" == "[]" ]]; then
        PAYLOAD='{
          "required_status_checks": null,
          "enforce_admins": false,
          "required_pull_request_reviews": {
            "required_approving_review_count": 1
          },
          "restrictions": null
        }'
      else
        PAYLOAD="{
          \"required_status_checks\": {
            \"strict\": true,
            \"checks\": ${CHECKS}
          },
          \"enforce_admins\": false,
          \"required_pull_request_reviews\": {
            \"required_approving_review_count\": 1
          },
          \"restrictions\": null
        }"
      fi

      gh api "repos/${OWNER}/${REPO}/branches/main/protection" \
        --method PUT \
        --input - <<< "$PAYLOAD" >/dev/null 2>&1 \
        && fixed "Branch protection          ${CHECK_DESC}" \
        || err "Branch protection          failed (may need Team plan)"
    else
      dryrun "Branch protection          ${CHECK_DESC}"
    fi
  else
    if [[ "$CURRENT_STATUS" == "none" ]]; then
      ok "Branch protection          none"
      return
    fi
    if [[ "$FIX" == "true" ]]; then
      gh api "repos/${OWNER}/${REPO}/branches/main/protection" \
        --method DELETE >/dev/null 2>&1 \
        && fixed "Branch protection          removed" \
        || err "Branch protection          failed to remove"
    else
      dryrun "Branch protection          needs removal"
    fi
  fi
}

reconcile_branch_protection
```

**Step 4: Test against a build repo**

```bash
cd /Users/bigviking/Documents/github/projects/lo/content-webhook
/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh
```

Expected: shows status for all 6 automations.

**Step 5: Commit**

```bash
git add scripts/lo-github-sync.sh
git commit -m "feat(f003): add GitHub API reconciliation (CodeQL, protection, auto-merge)"
```

---

### Task 6: Update `/lo:status` skill to call the script

**Files:**
- Modify: `plugins/lo/skills/status/SKILL.md:128-311` (replace Steps B, C, auto-merge generation, and branch protection with single script call)

**Step 1: Replace the inline GitHub automation steps**

In `SKILL.md`, replace the entire `#### Step B: Generate CI Caller Workflow` through `#### Step C: Enable Branch Protection + Auto-Merge` sections (lines 128-309) with:

```markdown
#### Step B: Reconcile GitHub Automation

Run the sync script to reconcile all GitHub automation for the new status:

```bash
/path/to/lo-plugin/scripts/lo-github-sync.sh --fix
```

The script reads the just-updated PROJECT.md status and reconciles:
- `.coderabbit.yaml` (reviews enabled/disabled)
- `.github/workflows/ci.yml` (active/dormant, detected capabilities)
- `.github/workflows/auto-merge.yml` (created/removed)
- CodeQL default setup (enabled/disabled via API)
- Branch protection (1 reviewer + checks / removed via API)
- Auto-merge repo setting (enabled/disabled via API)

The script handles all edge cases: custom CI, missing remotes, free-plan limitations.

Present the script's output to the user. If any items show `error`, investigate and report.
```

Also update **Mode 3 (→ Open)**, **Mode 4 (→ Closed)**, and **Mode 5 (→ Explore)** to call the script after updating PROJECT.md:

For each mode, after "Update `status:` in frontmatter", add:
```
3. Run `lo-github-sync.sh --fix` to reconcile GitHub automation for the new status.
```

Remove the existing "Update `.github/workflows/ci.yml`: change `status:` value" instruction from each mode — the script handles it.

**Step 2: Remove the menu items that reference Steps B and C**

Update the menu in Mode 2 (lines 66-76) to remove the individual GitHub setup options. The script runs automatically — no menu choice needed. Replace with:

```markdown
4. **Ask the user what to set up:**

        What do you want to configure?

        1. All of the below (recommended)
        2. Scan codebase and create a test coverage plan
        3. Reconcile GitHub automation (CodeRabbit, CI, CodeQL, branch protection, auto-merge)
        4. Create README and public docs (if missing)
        5. Skip all — just change the status
```

**Step 3: Verify the skill reads cleanly**

Read the full SKILL.md and confirm it's coherent end-to-end.

**Step 4: Commit**

```bash
git add plugins/lo/skills/status/SKILL.md
git commit -m "feat(f003): update status skill to use lo-github-sync.sh"
```

---

### Task 7: Update `/lo:new` skill to call the script

**Files:**
- Modify: `plugins/lo/skills/new/SKILL.md:262-281` (replace Step 7 inline CI generation)

**Step 1: Replace Step 7 with script call**

Replace the current Step 7 ("Write CI Caller Workflow" with inline YAML template) with:

```markdown
### Step 7: Reconcile GitHub Automation

Run the sync script to set up all GitHub automation appropriate for the project's status:

```bash
/path/to/lo-plugin/scripts/lo-github-sync.sh --fix
```

For new `Explore` projects (the common case), this creates:
- `.coderabbit.yaml` with `reviews.enabled: false`
- `.github/workflows/ci.yml` with dormant status

For new `Build` or `Open` projects, it also creates auto-merge workflows, enables CodeQL, sets branch protection, etc.

The script auto-detects capabilities from `package.json` and env files.
```

**Step 2: Update Step 8 confirmation output**

In Step 8, update the confirmation template to reference the sync script's output instead of just CI:

```
  GitHub automation: lo-github-sync applied (see output above)
```

Replace the line: `CI: .github/workflows/ci.yml (status: <status>, dormant until Build/Open)`

**Step 3: Update the validation checklist**

In the Validation section at the bottom, replace:
```
- [ ] `.github/workflows/ci.yml` exists with correct status
```
with:
```
- [ ] `.coderabbit.yaml` exists with correct reviews.enabled value
- [ ] `.github/workflows/ci.yml` exists with correct status
```

**Step 4: Commit**

```bash
git add plugins/lo/skills/new/SKILL.md
git commit -m "feat(f003): update new skill to use lo-github-sync.sh"
```

---

### Task 8: Run the script across all repos to fix current state

**Files:**
- No permanent file changes (script writes configs in each repo)

**Step 1: Run dry-run across all repos first**

```bash
SCRIPT="/Users/bigviking/Documents/github/projects/lo/lo-plugin/scripts/lo-github-sync.sh"
for repo in lo-plugin nexus platform content-webhook agent-development-brief cr-agent claude-dashboard telemetry-exporter yellowages-for-agents; do
  echo "========================================"
  cd "/Users/bigviking/Documents/github/projects/lo/$repo"
  "$SCRIPT"
done
```

Review output. Confirm each repo shows the expected target state.

**Step 2: Run --fix across all repos**

```bash
for repo in lo-plugin nexus platform content-webhook agent-development-brief cr-agent claude-dashboard telemetry-exporter yellowages-for-agents; do
  echo "========================================"
  cd "/Users/bigviking/Documents/github/projects/lo/$repo"
  "$SCRIPT" --fix
done
```

**Step 3: Verify by running dry-run again — everything should show `ok`**

```bash
for repo in lo-plugin nexus platform content-webhook agent-development-brief cr-agent claude-dashboard telemetry-exporter yellowages-for-agents; do
  echo "========================================"
  cd "/Users/bigviking/Documents/github/projects/lo/$repo"
  "$SCRIPT"
done
```

Expected: every line shows `ok` across all repos.

**Step 4: Commit the generated files in each repo**

For each repo that has changes:
```bash
cd /Users/bigviking/Documents/github/projects/lo/<repo>
git add .coderabbit.yaml .github/workflows/ci.yml .github/workflows/auto-merge.yml
git commit -m "chore: reconcile GitHub automation via lo-github-sync"
git push
```

---

### Task 9: Final verification

**Step 1: Verify branch protection via API**

```bash
for repo in lo-plugin nexus platform content-webhook agent-development-brief; do
  echo "=== $repo ==="
  gh api "repos/looselyorganized/$repo/branches/main/protection" --jq '{reviewers: .required_pull_request_reviews.required_approving_review_count, checks: .required_status_checks.contexts}' 2>/dev/null || echo "no protection"
done
```

Expected: all build/open repos show `reviewers: 1` with appropriate checks.

**Step 2: Verify CodeQL**

```bash
for repo in lo-plugin nexus platform content-webhook agent-development-brief cr-agent claude-dashboard telemetry-exporter yellowages-for-agents; do
  echo "=== $repo ==="
  gh api "repos/looselyorganized/$repo/code-scanning/default-setup" --jq '.state' 2>/dev/null || echo "unavailable"
done
```

Expected: build/open = `configured`, explore = `not-configured`.

**Step 3: Verify CodeRabbit config**

```bash
for repo in lo-plugin nexus platform content-webhook agent-development-brief cr-agent claude-dashboard telemetry-exporter yellowages-for-agents; do
  echo "=== $repo ==="
  gh api "repos/looselyorganized/$repo/contents/.coderabbit.yaml" --jq '.content' 2>/dev/null | base64 -d || echo "missing"
done
```

Expected: build/open = `reviews.enabled: true`, explore = `reviews.enabled: false`.
