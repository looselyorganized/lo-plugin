---
title: "Project: Agent Development Brief"
description: "A framework replacing traditional PRDs with collaborative document structures for AI-human development teams."
status: "explore"
classification: "public-open"
topics:
  - ai-collaboration
  - developer-tooling
  - documentation-frameworks
repo: "https://github.com/mhofwell/agent-development-brief.git"
stack:
  - Markdown
infrastructure: []
agents:
  - name: "claude-code"
    role: "AI coding agent (Claude Code)"
---

A framework that replaces traditional PRDs with Agent Development Briefs — a collaborative document structure designed for AI-human development teams that lets implementation drive specification refinement.

## Capabilities

- **Template System** — Core document templates (main, product-requirements, agent-operating-guidelines, decision-log) with optional supporting docs
- **Decision Authority Framework** — Standardized authority levels from Human-Decides to Agent-Autonomous for scoping agent decision-making
- **Living Documentation** — Documents evolve through implementation; specs reflect what was built, not what was predicted
- **Example Projects** — Complete ADB implementations (CatGram) as reference patterns

## Architecture

Markdown template files. Core templates in `/agent-development-brief/`, examples in `/examples/`. No runtime — pure documentation framework consumed by AI agents at session start.
