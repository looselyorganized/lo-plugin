---
status: active
feature_id: "f009"
feature: "lo-design Plugin — StockTaper Design System as Separate Plugin"
phase: 1
---

# Extract StockTaper Design System as lo-design Plugin

> **For agentic workers:** Use superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract the stocktaper-design-system skill from the lo plugin into a standalone `lo-design` plugin with corrected color tokens.

**Architecture:** New plugin at `plugins/lo-design/` alongside `plugins/lo/`. Restore v0.5.0 skill files from git history, apply two color fixes, add plugin.json.

**Source:** All files restored from `git show v0.5.0:plugins/lo/skills/stocktaper-design-system/`

---

### Task 1: Scaffold plugin structure

- [ ] Create directory tree:
```bash
mkdir -p plugins/lo-design/.claude-plugin
mkdir -p plugins/lo-design/skills/stocktaper-design-system/references
mkdir -p plugins/lo-design/skills/stocktaper-design-system/assets
```

- [ ] Write `plugins/lo-design/.claude-plugin/plugin.json`:
```json
{
  "name": "lo-design",
  "description": "StockTaper design system — monochromatic, monospace, minimal visual language for Loosely Organized projects",
  "version": "0.6.0",
  "author": {
    "name": "Loosely Organized Research Facility"
  },
  "repository": "https://github.com/looselyorganized/lo-plugin",
  "license": "MIT",
  "keywords": ["lo", "design-system", "stocktaper", "tailwind", "dark-mode"]
}
```

### Task 2: Restore SKILL.md and fix colors

- [ ] Restore SKILL.md from v0.5.0:
```bash
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/SKILL.md > plugins/lo-design/skills/stocktaper-design-system/SKILL.md
```

- [ ] Fix dark mode `--color-cream` in the Dark Mode Color Mapping table:
  - Old: `#141414` (near black)
  - New: `#1E1E1E` (near black)

- [ ] Add `--color-warning` to the Color System table:
```
| `--color-warning`| `#D97706` | Warning states, caution indicators      |
```

- [ ] Add `--color-warning` to the Dark Mode Color Mapping table:
```
| `--color-warning`| `#D97706` (amber)            | `#F59E0B` (bright amber) |
```

- [ ] Update version in SKILL.md metadata to `0.6.0`

### Task 3: Restore reference files [parallel]

- [ ] Restore all 5 reference files from v0.5.0:
```bash
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/references/design-tokens.md > plugins/lo-design/skills/stocktaper-design-system/references/design-tokens.md
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/references/typography-scale.md > plugins/lo-design/skills/stocktaper-design-system/references/typography-scale.md
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/references/layout-patterns.md > plugins/lo-design/skills/stocktaper-design-system/references/layout-patterns.md
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/references/component-catalog.md > plugins/lo-design/skills/stocktaper-design-system/references/component-catalog.md
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/references/mdx-content-guide.md > plugins/lo-design/skills/stocktaper-design-system/references/mdx-content-guide.md
```

- [ ] Fix `--color-cream` dark value in `design-tokens.md` if present (`#141414` → `#1E1E1E`)
- [ ] Add `--color-warning` to `design-tokens.md` if not present

### Task 4: Restore asset templates [parallel]

- [ ] Restore both asset files from v0.5.0:
```bash
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/assets/component-template.tsx > plugins/lo-design/skills/stocktaper-design-system/assets/component-template.tsx
git show v0.5.0:plugins/lo/skills/stocktaper-design-system/assets/page-template.tsx > plugins/lo-design/skills/stocktaper-design-system/assets/page-template.tsx
```

### Task 5: Update README (depends on 1, 2, 3, 4)

- [ ] Add `lo-design` to the Skills table in README.md
- [ ] Commit all files:
```bash
git add plugins/lo-design/
git commit -m "feat(f009): extract stocktaper design system as lo-design plugin"
```
