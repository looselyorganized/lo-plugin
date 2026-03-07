# EARS Requirements Guide

> Easy Approach to Requirements Syntax — optional step in `/lo:plan` for complex features.

## When to Use

EARS requirements are worth writing when a feature involves:

- **Multiple subsystems** — e.g., GH Action + service + database schema
- **External interfaces or APIs** — anything crossing process/network boundaries
- **State machines or lifecycle flows** — entities with distinct states and transitions
- **Multiple actors** — users, agents, services interacting with each other

Skip EARS for simple features where the brainstorming output is sufficient to plan from.

## EARS Patterns

Five sentence patterns cover nearly all requirements:

| Pattern | Template | Use when |
|---------|----------|----------|
| Ubiquitous | The {system} shall {behavior}. | Always true, no trigger needed |
| Event-driven | When {trigger}, the {system} shall {behavior}. | Responding to an event |
| State-driven | While {state}, the {system} shall {behavior}. | Behavior depends on current state |
| Unwanted | If {condition}, then the {system} shall {behavior}. | Error handling, edge cases |
| Optional | Where {feature}, the {system} shall {behavior}. | Configurable or feature-flagged |

**Writing tips:**
- One requirement per sentence. No compound requirements.
- Use "shall" for mandatory behavior, "should" for recommended.
- Be specific: name the system, the trigger, the behavior. "The auth middleware shall return 401" not "it should handle errors."
- Each requirement must be testable — if you can't verify it, rewrite it.

## Naming Convention

Requirements are grouped by subsystem. Each subsystem gets a prefix:

| Prefix | Subsystem type | Example |
|--------|---------------|---------|
| REQ-T | Trigger / entry point | REQ-T01 (GH Action, webhook, CLI) |
| REQ-A | Agent / service | REQ-A01 (backend service logic) |
| REQ-S | Schema / data model | REQ-S01 (database tables, types) |
| REQ-U | UI / frontend | REQ-U01 (components, pages) |
| REQ-X | Cross-cutting | REQ-X01 (auth, logging, config) |

Sequential numbering within each prefix: `REQ-A01`, `REQ-A02`, `REQ-A03`.

Custom prefixes are fine when the standard ones don't fit — just be consistent within the document.

## File Template

Save to `.lo/work/f{NNN}-slug/ears-requirements.md`:

```markdown
---
feature_id: "f{NNN}"
date: "YYYY-MM-DD"
status: "draft"
audience: "claude-agents"
---

# EARS Requirements — {Feature Name}

## Scope

**In:** What this feature covers.
**Out (v2+):** What is explicitly deferred.

## Key Design Decisions

- Decision 1: rationale
- Decision 2: rationale

## 1. {Subsystem A}

REQ-{PREFIX}01: When {trigger}, the {system} shall {behavior}.
REQ-{PREFIX}02: The {system} shall {behavior}.
REQ-{PREFIX}03: If {error condition}, then the {system} shall {behavior}.

## 2. {Subsystem B}

REQ-{PREFIX}01: While {state}, the {system} shall {behavior}.
REQ-{PREFIX}02: When {trigger}, the {system} shall {behavior}.

## 3. Cross-Cutting

REQ-X01: The {system} shall {behavior}.
REQ-X02: If {condition}, then the {system} shall {behavior}.
```

## Frontmatter Fields

| Field | Type | Description |
|-------|------|-------------|
| `feature_id` | string | Backlog ID, e.g. `f003` |
| `date` | string | Date written (`YYYY-MM-DD`) |
| `status` | enum | `draft` \| `approved` \| `updated` |
| `audience` | string | Who consumes this doc (typically `claude-agents`) |

Status transitions:
- `draft` — Initial write, under review
- `approved` — User approved, plans can reference these IDs
- `updated` — Revised after implementation started (note what changed)

## How Plans Reference EARS

Implementation plans (`001-*.md`) should reference requirement IDs in task descriptions:

```markdown
## Tasks
- [ ] 1. Create webhook listener endpoint (REQ-T01, REQ-T02)
- [ ] 2. Build agent processing pipeline (REQ-A01, REQ-A02, REQ-A03) [parallel]
- [ ] 3. Create database schema and migrations (REQ-S01, REQ-S02) [parallel]
- [ ] 4. Add error handling and retries (REQ-X01, REQ-X02) (depends on 2, 3)
```

This creates traceability from requirements → plan → execution.

## Real-World Example

The `cr-agent` project used EARS to define 22 requirements across 4 subsystems before building v1:

```
cr-agent/.lo/work/t001-ears-requirements/ears-requirements.md

## 1. GH Action Trigger (REQ-T)
REQ-T01: When a pull request is opened, the GH Action shall send a webhook to the agent service.
REQ-T02: When a pull request is synchronized, the GH Action shall send an updated webhook.
REQ-T03: If the webhook delivery fails, then the GH Action shall retry up to 3 times.

## 2. Railway Agent Service (REQ-A)
REQ-A01: When a webhook is received, the agent shall validate the payload signature.
REQ-A02: The agent shall clone the repository at the PR's head commit.
REQ-A03: When the clone is complete, the agent shall run the code review pipeline.
...

## 3. Supabase Schema (REQ-S)
REQ-S01: The schema shall store review requests with status tracking.
...

## 4. Cross-Cutting (REQ-X)
REQ-X01: The system shall authenticate all inter-service communication.
...
```

This document drove the entire v1 implementation and was updated during the t004 webhook refactor to stay current with the architecture.
