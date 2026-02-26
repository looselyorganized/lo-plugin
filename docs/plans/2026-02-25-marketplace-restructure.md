# Marketplace Restructure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure lo-plugin from a flat plugin into a marketplace with the plugin nested at `plugins/lo/`, so users can install via `/plugin install lo@looselyorganized`.

**Architecture:** The repo root becomes a marketplace (`.claude-plugin/marketplace.json`). The actual plugin lives at `plugins/lo/` with its own `.claude-plugin/plugin.json` and `skills/` directory. Repo-level files (`.lo/`, `docs/`, `README.md`, `LICENSE`) stay at root.

**Tech Stack:** Claude Code plugin system, Markdown skills, JSON manifests

---

### Task 1: Create plugin directory structure and move skills

**Files:**
- Create: `plugins/lo/.claude-plugin/` (directory)
- Move: `skills/` → `plugins/lo/skills/`
- Move: `.claude-plugin/plugin.json` → `plugins/lo/.claude-plugin/plugin.json`

**Step 1: Create the nested plugin directory**

Run:
```bash
mkdir -p plugins/lo/.claude-plugin
```

**Step 2: Move skills directory into the plugin**

Run:
```bash
git mv skills plugins/lo/skills
```

**Step 3: Move plugin.json into the nested plugin**

Run:
```bash
git mv .claude-plugin/plugin.json plugins/lo/.claude-plugin/plugin.json
```

**Step 4: Verify the move**

Run:
```bash
ls -la plugins/lo/.claude-plugin/plugin.json && ls plugins/lo/skills/
```
Expected: `plugin.json` exists, all 9 skill directories listed (backlog, hypothesis, milestones, new, research, ship, solution, stocktaper-design-system, work)

---

### Task 2: Create marketplace.json

**Files:**
- Create: `.claude-plugin/marketplace.json`

**Step 1: Create the marketplace manifest**

Write `.claude-plugin/marketplace.json`:
```json
{
  "name": "looselyorganized",
  "owner": {
    "name": "Loosely Organized Research Facility"
  },
  "metadata": {
    "description": "Plugins by Loosely Organized Research Facility"
  },
  "plugins": [
    {
      "name": "lo",
      "source": "./plugins/lo",
      "description": "LO work system — backlog, work execution, knowledge capture, shipping pipeline, and design system for Loosely Organized projects",
      "license": "MIT",
      "keywords": ["lo", "work-management", "backlog", "skills", "design-system"],
      "category": "productivity"
    }
  ]
}
```

**Step 2: Verify the file is valid JSON**

Run:
```bash
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json')); print('Valid JSON')"
```
Expected: `Valid JSON`

---

### Task 3: Copy LICENSE into the plugin

**Files:**
- Create: `plugins/lo/LICENSE`

Plugins are cached independently when installed — files outside the plugin directory won't be available. The LICENSE must exist inside the plugin.

**Step 1: Copy LICENSE**

Run:
```bash
cp LICENSE plugins/lo/LICENSE
```

**Step 2: Verify**

Run:
```bash
diff LICENSE plugins/lo/LICENSE
```
Expected: No output (files are identical)

---

### Task 4: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Rewrite README with new install instructions**

Replace the full content of `README.md` with:

```markdown
# lo — LO Work System Plugin

Claude Code plugin for managing work in Loosely Organized projects. Provides a complete work lifecycle: backlog management, plan execution, knowledge capture, and a shipping pipeline.

## Install

Add the marketplace and install the plugin:

```
/plugin marketplace add looselyorganized/lo-plugin
/plugin install lo@looselyorganized
```

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| backlog | `/lo:backlog` | View, add tasks/features, pick up work |
| work | `/lo:work` | Execute plans with branch/worktree + parallel agents |
| solution | `/lo:solution` | Capture reusable knowledge |
| ship | `/lo:ship` | Test → simplify → security → commit → push → PR |
| new | `/lo:new` | Scaffold `.lo/` directory |
| milestones | `/lo:milestones` | Update `.lo/stream/` with milestones |
| hypothesis | `/lo:hypothesis` | Create testable hypotheses |
| research | `/lo:research` | Write structured research articles |
| stocktaper-design-system | — | StockTaper / LORF design system tokens, components, and layout patterns |

## The `.lo/` Convention

Every LO project contains a `.lo/` directory at the repo root — the single source of truth for project metadata, backlog, hypotheses, stream entries, research, active work, solutions, and notes.

See [`docs/lo-spec.md`](docs/lo-spec.md) for the full specification.

## Development

Test the plugin locally:

```bash
claude --plugin-dir ./plugins/lo
```

Validate the marketplace:

```bash
claude plugin validate .
```
```

---

### Task 5: Validate and test

**Step 1: Run plugin validate**

Run:
```bash
claude plugin validate .
```
Expected: No errors. Warnings about missing description are acceptable.

**Step 2: Test the plugin loads**

Run:
```bash
claude --plugin-dir ./plugins/lo --print-skills 2>&1 | head -20
```
Expected: Skills listed with `lo:` prefix

**Step 3: Check git status**

Run:
```bash
git status
```
Expected: Moved files show as renamed, new files show `marketplace.json` and `plugins/lo/LICENSE`

---

### Task 6: Commit

**Step 1: Stage all changes**

Run:
```bash
git add .claude-plugin/marketplace.json plugins/ README.md docs/plans/
```

**Step 2: Commit**

Run:
```bash
git commit -m "feat: restructure as marketplace with nested plugin

Restructure repo from flat plugin to marketplace so users can install via:
  /plugin marketplace add looselyorganized/lo-plugin
  /plugin install lo@looselyorganized

- Move skills/ and plugin.json into plugins/lo/
- Add marketplace.json at repo root
- Update README with marketplace install instructions
- Copy LICENSE into plugin directory (needed for caching)"
```
