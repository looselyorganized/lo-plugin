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
| stream | `/lo:stream` | Update `.lo/stream/` with milestones and updates |
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
