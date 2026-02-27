---
title: "LO Plugin"
description: "Claude Code plugin providing the LO work system — backlog, work execution, knowledge capture, shipping pipeline, and design system."
status: "build"
classification: "public"
topics:
  - developer-tooling
  - ai-collaboration
  - work-management
repo: "https://github.com/looselyorganized/lo-plugin"
stack:
  - Markdown
  - Claude Code Skills
infrastructure:
  - GitHub
agents:
  - name: "claude-code"
    role: "AI coding agent (Claude Code)"
---

Claude Code plugin that implements the LO work system for Loosely Organized projects. Provides skills covering the full work lifecycle: backlog management, hypothesis tracking, research, plan execution, knowledge capture, stream updates, and a shipping pipeline with quality gates. Includes the StockTaper design system for building UI.

## Capabilities

- **Backlog Management** — Feature and task tracking with priority ordering and feature IDs
- **Hypothesis Tracking** — Quick-capture hypothesis logging with structured frontmatter
- **Research** — Structured research articles with editorial headings and narrative prose
- **Plan Execution** — Dispatches work from .lo/work/ plans using direct execution or parallel agents
- **Knowledge Capture** — Reusable solution files documenting what was learned after shipping
- **Stream Updates** — Editorial narrative layer grouping commits into thematic milestones
- **Shipping Pipeline** — Gated pipeline running tests, code review, security checks, then PR creation
- **Design System** — StockTaper design system tokens, components, and dark mode patterns
- **Project Lifecycle** — Status transitions with guardrails and PROJECT.md updates

## Architecture

Pure markdown skills plugin — no runtime, no build step, no server. Skills loaded by Claude Code on invocation. Marketplace layout hosts plugins under `plugins/` with a shared registry.

## Infrastructure

- **GitHub** — Source hosting and distribution via LO plugin marketplace
