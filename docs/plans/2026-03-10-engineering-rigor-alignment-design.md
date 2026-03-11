# Engineering Rigor Alignment — Design

Aligns LO plugin skills with the Engineering Rigor Framework's progressive automation ladder. Each project stage (Explore → Build → Open) should enforce only the practices appropriate to that stage.

## Problem

The plugin's skills run the same logic regardless of project status. Ship runs reviewers and tests in Explore (framework says: none). The Open transition is a one-liner (framework says: major step). CI is flat across Build and Open. The gap means Explore is slower than it should be and Open is less rigorous than it should be.

## Decisions

- **Approach A:** Stage-aware conditionals in existing skills (no new files, no extracted reference docs)
- **Railway-specific Open stage:** PR deploys for pre-production testing, no persistent staging service
- **Cost alerts removed:** Not worth the automation at current scale
- **EMERGENCY.md removed:** Solo dev knows rollback procedures, file would drift
- **Solution skill unchanged:** Stays post-ship; stream handles mid-work narrative
- **Reviewer subagent unchanged:** Fine for Build; CI covers Open gaps (npm audit)

## Changes

### 1. `/lo:ship` — Stage-aware gates

Gates 2-4 become status-conditional:

- **Explore/Closed:** Skip Gates 2, 3, 4 entirely. Ship becomes: pre-flight → commit → push → wrap-up.
- **Build:** Run all gates as today. Tests: run if they exist, pass = proceed, fail = stop, none = proceed with note (not warning).
- **Open:** Run all gates. Tests: run, must pass, none = hard stop ("Open-status projects require tests"). Add `npm audit --audit-level=critical` (or equivalent) to Gate 3. Audit failure = stop.

Gate 4 (reviewer): skip in Explore/Closed, run in Build/Open.

### 2. `/lo:status open` — Open transition wizard

Replace simple transition with multi-step wizard:

```
1. All of the below (recommended)
2. Reconcile GitHub automation
3. Enable Railway PR deploys
4. Set up error tracking
5. Set up uptime monitoring
6. Add rate limiting check
7. Skip all — just change the status
```

- **GitHub automation:** Runs lo-github-sync.sh --fix (now generates Open-specific CI with has-audit)
- **Railway PR deploys:** Verify enabled via prompt, link to Railway dashboard. Not automated — verification only.
- **Error tracking:** Prompt for status. If not set up, add backlog task.
- **Uptime monitoring:** Prompt for status. If not set up, add backlog task.
- **Rate limiting:** Prompt for status. If not set up, add backlog task.

Steps 4-6 create trackable backlog tasks rather than automating vendor-specific setup.

### 3. `/lo:status build` — Conditional infra steps

Add two steps that appear only when relevant infrastructure is detected from PROJECT.md:

- **Database backups and migrations:** Shown if DB detected. Verify backups enabled, migration tool in version control. Add backlog tasks for gaps.
- **Health check endpoint:** Shown if API/server detected. Verify /health exists. Add backlog task if not.

Menu items are conditionally visible — projects without DBs or servers see the same menu as today.

### 4. CI differentiation — Build vs Open

In `lo-github-sync.sh`: when status is `open`, add `has-audit: true` to the CI workflow's `with:` block. Same pattern as `has-test` and `has-build`.

Reusable CI workflow changes (in `looselyorganized/ci` repo, separate PR) to add conditional `npm audit --audit-level=critical` job when `has-audit` is true.

### 5. `/lo:new` — .gitignore verification

Add step between scan and directory creation:

1. If `.gitignore` missing: generate default based on detected stack, present for review
2. If `.gitignore` exists but no `.env` exclusion: warn and offer to add
3. If `.gitignore` exists and covers `.env`: no action

### 6. Stream quality gate — Broaden editorial filter

Change quality gate from "would you post this?" to "would this be interesting to someone following the project?"

Add to qualifying events: lessons learned, challenges overcome, key decisions and pivots that other builders would find useful.

Exclusions unchanged: routine fixes, config changes, dependency updates.

## Files Changed

| File | Change | Size |
|------|--------|------|
| `skills/ship/SKILL.md` | Stage-aware Gates 2-4 | Medium |
| `skills/status/SKILL.md` | Open wizard, Build conditional infra steps | Large |
| `skills/new/SKILL.md` | .gitignore verification | Small |
| `skills/stream/SKILL.md` | Quality gate wording | Small |
| `scripts/lo-github-sync.sh` | has-audit for Open | Small |

## Out of Scope

- Reusable CI workflow (`looselyorganized/ci`) — separate repo, separate PR
- Solution skill — no changes
- Reviewer subagent — no changes
