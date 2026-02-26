# Marketplace Restructure Design

## Goal

Make lo-plugin installable via the Claude Code plugin marketplace so any user can install with:

```
/plugin marketplace add looselyorganized/lo-plugin
/plugin install lo@looselyorganized
```

## Approach

Restructure the repo from a flat plugin into a marketplace containing the plugin nested at `plugins/lo/`.

## Current structure

```
lo-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── backlog/SKILL.md
│   ├── work/SKILL.md
│   ├── ship/SKILL.md
│   ├── solution/SKILL.md
│   ├── new/SKILL.md
│   ├── hypothesis/SKILL.md
│   ├── research/SKILL.md
│   ├── milestones/SKILL.md
│   └── stocktaper-design-system/SKILL.md
├── docs/
├── .lo/
├── README.md
└── LICENSE
```

## Target structure

```
lo-plugin/
├── .claude-plugin/
│   └── marketplace.json          ← NEW (replaces plugin.json at this level)
├── plugins/
│   └── lo/
│       ├── .claude-plugin/
│       │   └── plugin.json       ← MOVED from root
│       ├── skills/               ← MOVED from root
│       │   ├── backlog/SKILL.md
│       │   ├── work/SKILL.md
│       │   ├── ship/SKILL.md
│       │   ├── solution/SKILL.md
│       │   ├── new/SKILL.md
│       │   ├── hypothesis/SKILL.md
│       │   ├── research/SKILL.md
│       │   ├── milestones/SKILL.md
│       │   └── stocktaper-design-system/
│       │       ├── SKILL.md
│       │       ├── assets/
│       │       └── references/
│       └── LICENSE
├── docs/
├── .lo/
├── README.md
└── LICENSE
```

## Naming

- Marketplace name: `looselyorganized`
- Plugin name: `lo`
- Install command: `/plugin install lo@looselyorganized`
- Skill prefix: `/lo:`

## New file: `.claude-plugin/marketplace.json`

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

## Changes required

1. Create `plugins/lo/` directory
2. Move `skills/` into `plugins/lo/skills/`
3. Move `.claude-plugin/plugin.json` to `plugins/lo/.claude-plugin/plugin.json`
4. Replace root `.claude-plugin/plugin.json` with `marketplace.json`
5. Copy `LICENSE` into `plugins/lo/` (plugin is cached independently)
6. Update `README.md` with new install instructions and dev commands
7. Update dev command from `claude --plugin-dir .` to `claude --plugin-dir ./plugins/lo`
8. Validate with `claude plugin validate .`

## What stays the same

- `.lo/` directory stays at repo root (project metadata, not plugin content)
- `docs/` stays at repo root
- `plugin.json` content unchanged (just moved)
- All skill files unchanged (just moved)
- All skill names (`/lo:work`, `/lo:ship`, etc.) unchanged
