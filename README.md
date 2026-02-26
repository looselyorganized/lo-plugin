# lo — LO Work System Plugin

Claude Code plugin for managing work in Loosely Organized projects.

## Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| backlog | `/lo:backlog` | View, add tasks/features, pick up work |
| work | `/lo:work` | Execute plans with branch/worktree + parallel agents |
| solution | `/lo:solution` | Capture reusable knowledge |
| ship | `/lo:ship` | Test → simplify → security → commit → push → PR |
| new | `/lo:new` | Scaffold .lo/ directory |
| milestones | `/lo:milestones` | Update .lo/stream/ with milestones |
| hypothesis | `/lo:hypothesis` | Create testable hypotheses |
| research | `/lo:research` | Write structured research articles |

## Development

```bash
claude --plugin-dir ./lo-plugin
```

## Install

```bash
claude plugin install lo
```
