# Changing LORF to LO — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename the `.lorf/` convention directory to `.lo/` and update all references across 5 Loosely Organized projects.

**Architecture:** Big bang — one coordinated pass per project. Rename directories with `git mv`, rename files with `git mv`, then find-and-replace file contents. One commit per project. Reload launchd service for claude-dashboard.

**Tech Stack:** git, sed (for bulk content replacement), launchctl (for service reload)

---

### Task 1: agent-development-brief — Rename directory and update skills

This is the plugin repo that defines the `.lorf/` convention. 8 skill files, 3 reference docs, plugin config, README, backlog, and stream entry.

**Files:**
- Rename: `.lorf/` → `.lo/`
- Modify: `lo-plugin/skills/backlog/SKILL.md`
- Modify: `lo-plugin/skills/work/SKILL.md`
- Modify: `lo-plugin/skills/solution/SKILL.md`
- Modify: `lo-plugin/skills/ship/SKILL.md`
- Modify: `lo-plugin/skills/new/SKILL.md`
- Modify: `lo-plugin/skills/milestones/SKILL.md`
- Modify: `lo-plugin/skills/hypothesis/SKILL.md`
- Modify: `lo-plugin/skills/research/SKILL.md`
- Modify: `lo-plugin/skills/research/references/frontmatter-contract.md`
- Modify: `lo-plugin/skills/research/references/design-systems-for-agents.mdx`
- Modify: `lo-plugin/skills/milestones/references/frontmatter-contracts.md`
- Modify: `lo-plugin/skills/new/references/frontmatter-contracts.md`
- Modify: `lo-plugin/.claude-plugin/plugin.json`
- Modify: `lo-plugin/README.md`
- Modify: `.lo/BACKLOG.md` (after rename)
- Modify: `.lo/stream/2026-02-25-work-system.md` (after rename)
- Skip: `docs/plans/2026-02-25-changing-lorf-to-lo-design.md` (design doc — references are historical)

**Step 1: Rename the directory**

```bash
cd /Users/bigviking/Documents/github/projects/looselyorganized/agent-development-brief
git mv .lorf .lo
```

**Step 2: Update all file contents**

Apply these replacements across all files listed above (NOT the design doc):
- `.lorf/` → `.lo/`
- `.lorf` (without slash, in backticks or quotes) → `.lo`
- `# LORF ` → `# LO ` (skill titles)
- `LORF` → `LO` (in descriptions, comments — but NOT in "Loosely Organized Research Facility")
- `"lorf"` → `"lo"` (in plugin.json keywords)
- `lorf` → `lo` (in tags arrays like `[lorf, research, ...]`)
- `"new lorf"` → `"new lo"` and similar trigger phrases in skill descriptions
- `"set up lorf"` → `"set up lo"`, `"scaffold lorf"` → `"scaffold lo"`, etc.
- `"update lorf"` → `"update lo"` in milestones skill description

Be careful with:
- "Loosely Organized Research Facility" — do NOT change
- The design doc at `docs/plans/` — skip it, it's historical
- `design-systems-for-agents.mdx` contains "LORF Bot" brand references — change to "LO Bot"

**Step 3: Update BACKLOG.md self-references**

After the directory rename, `.lo/BACKLOG.md` still references `.lorf/work/changing-lorf-to-lo/`. Update:
- `Status: active -> .lorf/work/changing-lorf-to-lo/` → `Status: active -> .lo/work/changing-lorf-to-lo/`
- Other `.lorf` references in the file

**Step 4: Verify no remaining references**

```bash
grep -r "lorf" --include="*.md" --include="*.json" --include="*.mdx" . | grep -v "docs/plans/" | grep -v ".git/" | grep -v "node_modules/"
```

Expected: No matches (except possibly the design doc which we skip).

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: rename .lorf to .lo across plugin and project metadata"
```

---

### Task 2: claude-dashboard — Rename directory, files, and update code

The exporter has TypeScript files with "lorf" in filenames, a launchd plist, package.json, and extensive code references.

**Files:**
- Rename: `.lorf/` → `.lo/`
- Rename: `exporter/lorf-open.ts` → `exporter/lo-open.ts`
- Rename: `exporter/lorf-close.ts` → `exporter/lo-close.ts`
- Rename: `exporter/com.lorf.telemetry-exporter.plist` → `exporter/com.lo.telemetry-exporter.plist`
- Modify: `exporter/lo-open.ts` (after rename) — service label, log paths, display text
- Modify: `exporter/lo-close.ts` (after rename) — service label, display text
- Modify: `exporter/com.lo.telemetry-exporter.plist` (after rename) — service label, log paths
- Modify: `exporter/slug-resolver.ts` — `.lorf` path references, variable names
- Modify: `exporter/index.ts` — `LORF` in comments, `lorfEntries` variable, `lorfDir` references
- Modify: `exporter/project-scanner.ts` — comment
- Modify: `exporter/sync.ts` — comments referencing lorf-open/lorf-close
- Modify: `exporter/package.json` — package name, script commands
- Modify: `exporter/.env` — comment
- Modify: `CLAUDE.md` — references to lorf-site and exporter
- Modify: `.lo/stream/2026-02-25-lorf-open-startup-command.md` (after dir rename)
- Modify: `.lo/stream/2026-02-23-project-identity-event-tracking.md` (after dir rename)
- Modify: `.wip/2026-02-25-lorf-open-startup-command-design.md` — historical doc, rename references
- Modify: `.wip/2026-02-25-lorf-open-implementation.md` — historical doc, rename references
- Modify: `docs/plans/2026-02-23-message-event-tracking-design.md` — reference to lorf-site

**Step 1: Unload the current launchd service**

```bash
launchctl unload ~/Library/LaunchAgents/com.lorf.telemetry-exporter.plist 2>/dev/null || true
```

**Step 2: Rename directory and files**

```bash
cd /Users/bigviking/Documents/github/projects/looselyorganized/claude-dashboard
git mv .lorf .lo
git mv exporter/lorf-open.ts exporter/lo-open.ts
git mv exporter/lorf-close.ts exporter/lo-close.ts
git mv exporter/com.lorf.telemetry-exporter.plist exporter/com.lo.telemetry-exporter.plist
```

**Step 3: Update file contents — exporter code**

In `exporter/lo-open.ts`:
- `com.lorf.telemetry-exporter` → `com.lo.telemetry-exporter`
- `lorf-exporter.err` → `lo-exporter.err`
- `LORF — Opening Research Facility` → `LO — Opening Research Facility`
- `bun run lorf-open.ts` → `bun run lo-open.ts`
- `lorf-open will reload` → `lo-open will reload`

In `exporter/lo-close.ts`:
- `com.lorf.telemetry-exporter` → `com.lo.telemetry-exporter`
- `LORF — Closing Research Facility` → `LO — Closing Research Facility`
- `bun run lorf-close.ts` → `bun run lo-close.ts`
- `lorf-open will reload` → `lo-open will reload`

In `exporter/com.lo.telemetry-exporter.plist`:
- `com.lorf.telemetry-exporter` → `com.lo.telemetry-exporter`
- `lorf-exporter.log` → `lo-exporter.log`
- `lorf-exporter.err` → `lo-exporter.err`

In `exporter/slug-resolver.ts`:
- `LORF telemetry exporter` → `LO telemetry exporter`
- `.lorf/project.md` → `.lo/project.md`
- `Only LORF projects (those with .lorf/)` → `Only LO projects (those with .lo/)`
- `no .lorf/ directory` → `no .lo/ directory`
- `When .lorf/ is added` → `When .lo/ is added`
- `const lorfDir` → `const loDir`
- `const lorfPath` → `const loPath`
- `// .lorf/ exists but no project.md` → `// .lo/ exists but no project.md`
- `Only includes LORF projects (those with .lorf/ directories)` → `Only includes LO projects (those with .lo/ directories)`
- Update the join path from `".lorf"` to `".lo"`

In `exporter/index.ts`:
- `LORF Telemetry Exporter` → `LO Telemetry Exporter`
- `not a LORF project` → `not a LO project`
- `const lorfEntries` → `const loEntries` (all occurrences)
- `filterAndMapEntries(allEntries)` assignments to `loEntries`
- `only LORF projects` → `only LO projects`
- `insertedByProject keys are already slugs from lorfEntries` → `...from loEntries`
- `computeSlugLastActive(lorfEntries)` → `computeSlugLastActive(loEntries)`

In `exporter/project-scanner.ts`:
- `// Skip non-LORF projects` → `// Skip non-LO projects`

In `exporter/sync.ts`:
- `lorf-site database` → `lo-site database`
- `lorf-open/lorf-close` → `lo-open/lo-close`

In `exporter/package.json`:
- `"name": "lorf-telemetry-exporter"` → `"name": "lo-telemetry-exporter"`
- `"description": "...LORF operations dashboard"` → `"...LO operations dashboard"`
- `"open": "bun run lorf-open.ts"` → `"open": "bun run lo-open.ts"`
- `"close": "bun run lorf-close.ts"` → `"close": "bun run lo-close.ts"`

In `exporter/.env`:
- `# Supabase credentials for the lorf-site project` → `# Supabase credentials for the lo-site project`

In `CLAUDE.md`:
- `lorf-site project` → `lo-site project`
- `lorf-site Supabase project` → `lo-site Supabase project`

In `.lo/stream/` entries and `.wip/` design docs:
- All `lorf` → `lo` references (these are historical but should stay consistent)
- Stream entry filename: `git mv .lo/stream/2026-02-25-lorf-open-startup-command.md .lo/stream/2026-02-25-lo-open-startup-command.md`

In `exporter/.visibility-cache.json`:
- `"lorf": "classified"` → `"lo": "classified"`

**Step 4: Update LaunchAgents symlink and load new service**

```bash
# Remove old symlink
rm -f ~/Library/LaunchAgents/com.lorf.telemetry-exporter.plist
# Create new symlink
ln -s /Users/bigviking/Documents/github/projects/looselyorganized/claude-dashboard/exporter/com.lo.telemetry-exporter.plist ~/Library/LaunchAgents/com.lo.telemetry-exporter.plist
# Load new service
launchctl load ~/Library/LaunchAgents/com.lo.telemetry-exporter.plist
```

**Step 5: Verify no remaining references**

```bash
grep -r "lorf" --include="*.ts" --include="*.json" --include="*.md" --include="*.plist" . | grep -v ".git/" | grep -v "node_modules/"
```

Expected: No matches (except possibly `.wip/` historical docs if we chose to skip them).

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: rename lorf to lo — exporter, plist, service label, and project metadata"
```

---

### Task 3: looselyorganized — Rename directory, files, CSS classes, and brand content

The main site project. Has `.lorf/` directory, docs with "lorf" filenames, CSS animation classes prefixed with `lorf-`, image files with "lorf" names, brand docs, component references, and editorial content.

**Files:**
- Rename: `.lorf/` → `.lo/`
- Rename: `docs/lorf-spec.md` → `docs/lo-spec.md`
- Rename: `brand/lorf-bots.md` → `brand/lo-bots.md`
- Rename: `public/lorf-icon-light.png` → `public/lo-icon-light.png`
- Rename: `public/lorf-icon-dark.png` → `public/lo-icon-dark.png`
- Rename: `public/lorf-lab-hero.png` → `public/lo-lab-hero.png`
- Rename: `public/lorf-lab.png` → `public/lo-lab.png`
- Rename: `public/research/design-systems-for-agents/05-lorf-bot-mascot.png` → `public/research/design-systems-for-agents/05-lo-bot-mascot.png`
- Rename: `.github/assets/lorf-bots-table.png` → `.github/assets/lo-bots-table.png`
- Modify: `CLAUDE.md`
- Modify: `src/app/globals.css` — rename all `lorf-` CSS keyframes and classes
- Modify: `src/app/page.tsx` — image path reference
- Modify: `src/components/interactive/LobbyLiveSection.tsx` — CSS class reference
- Modify: `src/components/research/LobbyDemos.tsx` — CSS class references
- Modify: `src/components/project/EventFeed.tsx` — CSS class references
- Modify: `src/components/project/FacilityStatusStrip.tsx` — CSS class reference
- Modify: `src/components/project/HypothesisCard.tsx` — CSS class reference
- Modify: `src/lib/types.ts` — comment
- Modify: `content/research/design-systems-for-agents.mdx` — LORF Bot → LO Bot, image path
- Modify: `content/research/building-the-lobby.mdx` — "Loosely Organized Research Facility" stays, but check for abbreviation uses
- Modify: `docs/lo-spec.md` (after rename) — extensive `.lorf` → `.lo` replacement
- Modify: `brand/lo-bots.md` (after rename) — `LORF Bot` → `LO Bot`
- Modify: `.lo/stream/` entries (after dir rename)
- Modify: `.lo/research/design-systems-for-agents.md` (after dir rename)
- Modify: `.github/README.md` — `LORF` abbreviation
- Modify: `.wip/agent-comm.md`, `.wip/project-vision.md`, `.wip/mcp-server-roadmap.md`, `.wip/site-reorganization.md`, `.wip/completed/project-pages-roadmap.md`
- Modify: `docs/plans/2026-02-24-event-driven-telemetry-push-plan.md`

**Step 1: Rename directory and files**

```bash
cd /Users/bigviking/Documents/github/projects/looselyorganized/looselyorganized
git mv .lorf .lo
git mv docs/lorf-spec.md docs/lo-spec.md
git mv brand/lorf-bots.md brand/lo-bots.md
git mv public/lorf-icon-light.png public/lo-icon-light.png
git mv public/lorf-icon-dark.png public/lo-icon-dark.png
git mv public/lorf-lab-hero.png public/lo-lab-hero.png
git mv public/lorf-lab.png public/lo-lab.png
git mv public/research/design-systems-for-agents/05-lorf-bot-mascot.png public/research/design-systems-for-agents/05-lo-bot-mascot.png
git mv .github/assets/lorf-bots-table.png .github/assets/lo-bots-table.png
```

**Step 2: Update CSS — rename all lorf- prefixed animations and classes**

In `src/app/globals.css`, rename:
- `@keyframes lorf-pulse` → `@keyframes lo-pulse`
- `@keyframes lorf-slide-in` → `@keyframes lo-slide-in`
- `@keyframes lorf-flash` → `@keyframes lo-flash`
- `@keyframes lorf-blink` → `@keyframes lo-blink`
- `@keyframes lorf-dot-pulse` → `@keyframes lo-dot-pulse`
- `.lorf-pulse` → `.lo-pulse` (class and animation reference)
- `.lorf-slide-in` → `.lo-slide-in`
- `.lorf-feed-scroll` → `.lo-feed-scroll`
- `.lorf-flash` → `.lo-flash`
- `.lorf-blink` → `.lo-blink`
- `.lorf-dot-pulse` → `.lo-dot-pulse`

**Step 3: Update component CSS class references**

In each component file, replace CSS class names:
- `lorf-blink` → `lo-blink`
- `lorf-slide-in` → `lo-slide-in`
- `lorf-feed-scroll` → `lo-feed-scroll`
- `lorf-pulse` → `lo-pulse`

Components: `LobbyLiveSection.tsx`, `LobbyDemos.tsx`, `EventFeed.tsx`, `FacilityStatusStrip.tsx`, `HypothesisCard.tsx`

**Step 4: Update image path references**

In `src/app/page.tsx`:
- `src="/lorf-lab-hero.png"` → `src="/lo-lab-hero.png"`

In `content/research/design-systems-for-agents.mdx` and `.lo/research/design-systems-for-agents.md`:
- `05-lorf-bot-mascot.png` → `05-lo-bot-mascot.png`

**Step 5: Update content and docs**

In `docs/lo-spec.md` (after rename): Replace all `.lorf/` → `.lo/`, `LORF` → `LO` (except "Loosely Organized Research Facility")

In `brand/lo-bots.md` (after rename): `LORF Bot` → `LO Bot`, `LORF Bots` → `LO Bots`

In `CLAUDE.md`: `.lorf/research/` → `.lo/research/`, `.lorf/project.md` → `.lo/project.md`

In `.github/README.md`: `**LORF**` → `**LO**`

In editorial content (`.mdx` files): `LORF Bot` → `LO Bot`, `LORF Bots` → `LO Bots`. Leave "Loosely Organized Research Facility" unchanged.

In `.wip/` files and `docs/plans/`: Update `.lorf` references, `LORF` abbreviation, `lorf_register` → `lo_register`, `sync-lorf` → `sync-lo`, `LORF MCP` → `LO MCP`

In `src/lib/types.ts`: `// --- .lorf/ Content Pipeline ---` → `// --- .lo/ Content Pipeline ---`

In `.lo/stream/` and `.lo/research/` entries: Update content references

**Step 6: Verify no remaining references**

```bash
grep -r "lorf" --include="*.ts" --include="*.tsx" --include="*.css" --include="*.md" --include="*.mdx" --include="*.json" . | grep -v ".git/" | grep -v "node_modules/" | grep -v ".next/"
```

Expected: No matches.

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: rename lorf to lo — directory, docs, CSS classes, brand, and image files"
```

---

### Task 4: nexus — Rename directory and update stream entry

Minimal changes — just the directory and two files with content references.

**Files:**
- Rename: `.lorf/` → `.lo/`
- Rename: `.lo/stream/2026-02-19-lorf-project-tracking.md` → `.lo/stream/2026-02-19-lo-project-tracking.md`
- Modify: `.lo/stream/2026-02-19-lo-project-tracking.md` (after rename) — update content
- Modify: `.claude/settings.local.json` — update allowed command paths

**Step 1: Rename directory and file**

```bash
cd /Users/bigviking/Documents/github/projects/looselyorganized/nexus
git mv .lorf .lo
git mv .lo/stream/2026-02-19-lorf-project-tracking.md .lo/stream/2026-02-19-lo-project-tracking.md
```

**Step 2: Update file contents**

In `.lo/stream/2026-02-19-lo-project-tracking.md`:
- `title: "LORF project tracking"` → `title: "LO project tracking"`
- `.lorf/` → `.lo/` in content

In `.claude/settings.local.json`:
- `.lorf/project.md` → `.lo/project.md` (in allowed command)
- `.lorf/stream/` → `.lo/stream/`
- `.lorf/hypotheses/` → `.lo/hypotheses/`
- `.lorf/notes/` → `.lo/notes/`
- `.lorf/research/` → `.lo/research/`

**Step 3: Verify**

```bash
grep -r "lorf" . | grep -v ".git/" | grep -v "node_modules/"
```

Expected: No matches.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: rename .lorf to .lo"
```

---

### Task 5: yellowages-for-agents — Rename directory and update stream entry

Minimal — just directory rename and one stream entry with a content reference.

**Files:**
- Rename: `.lorf/` → `.lo/`
- Modify: `.lo/stream/2026-02-19-project-started.md` (after dir rename)

**Step 1: Rename directory**

```bash
cd /Users/bigviking/Documents/github/projects/looselyorganized/yellowages-for-agents
git mv .lorf .lo
```

**Step 2: Update stream entry**

In `.lo/stream/2026-02-19-project-started.md`:
- `LORF project structure created` → `LO project structure created`

**Step 3: Verify**

```bash
grep -r "lorf" . | grep -v ".git/" | grep -v "node_modules/"
```

Expected: No matches.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: rename .lorf to .lo"
```

---

### Task 6: Post-migration verification

**Step 1: Verify launchd service is running**

```bash
launchctl list | grep com.lo.telemetry-exporter
```

Expected: Service appears in list.

**Step 2: Verify exporter can resolve project slugs**

```bash
cd /Users/bigviking/Documents/github/projects/looselyorganized/claude-dashboard/exporter
bun run lo-open.ts
```

Expected: All preflight checks pass, facility opens successfully.

**Step 3: Verify no stale lorf references across all projects**

```bash
for dir in agent-development-brief claude-dashboard looselyorganized nexus yellowages-for-agents; do
  echo "=== $dir ==="
  grep -r "lorf" /Users/bigviking/Documents/github/projects/looselyorganized/$dir --include="*.ts" --include="*.tsx" --include="*.css" --include="*.md" --include="*.mdx" --include="*.json" --include="*.plist" | grep -v ".git/" | grep -v "node_modules/" | grep -v ".next/" | grep -v "docs/plans/2026-02-25-changing-lorf-to-lo"
done
```

Expected: No matches from any project (except the design doc in agent-development-brief which is historical).
