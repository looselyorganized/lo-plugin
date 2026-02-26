# Hypothesis File Reference

## Frontmatter Contract

```yaml
---
id: "h001"                       # Required. Unique within project, matches filename prefix.
statement: "..."                 # Required. The testable hypothesis.
status: "proposed"               # Required. proposed | testing | validated | invalidated | revised
date: "2026-02-19"              # Required. Date of last status change.
revisesId: "h000"               # Optional. Links to a prior hypothesis this revises.
---
```

## Status Transitions

```
proposed → testing → validated
                   → invalidated
                   → revised (creates new hypothesis with revisesId pointing back)
```

## Filename Convention

`h{NNN}-{slug}.md` — e.g., `h001-redis-locking.md`

- Numeric prefix (`h001`) ensures stable ordering and uniqueness
- Slug is kebab-case, 2-5 words, for human readability
- Zero-pad to 3 digits

---

## Complete Example: Validated Hypothesis

**File:** `h001-redis-locking.md`

```markdown
---
id: "h001"
statement: "Redis distributed locks with TTL expiration are sufficient for file-level mutual exclusion in multi-agent systems"
status: "validated"
date: "2026-02-15"
---

## Context

While building the Nexus coordination server, we needed a way to prevent two agents from modifying the same file simultaneously. The simplest approach — Redis `SET NX` with TTL — seemed promising but we hadn't tested it under concurrent load.

## How to Test

Run a load test with 8 concurrent agent processes, each attempting to acquire locks on a shared pool of 50 files. Measure:
- Lock collision rate (should be 0)
- Average lock acquisition time
- Recovery time after simulated agent crash

## Evidence

Load test results (2026-02-14):
- 10,000 lock operations across 8 agents: **0 collisions**
- Average acquisition time: 2.3ms
- After killing an agent mid-lock, TTL expired in 30s and other agents recovered automatically
- No deadlocks observed in 4-hour sustained test

## Notes

- TTL of 30s proved optimal — long enough for file operations, short enough to recover from crashes
- Considered Redlock for multi-node Redis, but single-node is sufficient at our current scale
- This validates the approach for Nexus v1; may need to revisit for multi-region deployment
```

---

## Complete Example: Revised Hypothesis

**File:** `h002-crdt-state.md`

```markdown
---
id: "h002"
statement: "CRDTs can replace Redis locks for state synchronization when agents operate on independent document sections"
status: "proposed"
date: "2026-02-17"
revisesId: "h001"
---

## Context

While h001 validated Redis locks for file-level mutual exclusion, we observed that many agent operations don't actually conflict — they modify different sections of the same document. Locks force serialization even when parallelism would be safe.

CRDTs (Conflict-free Replicated Data Types) could allow agents to work on the same document simultaneously, merging changes automatically.

## How to Test

1. Model a document as a CRDT (Yjs or Automerge)
2. Run the same 8-agent workload from h001
3. Compare throughput (operations/second) vs. the locked approach
4. Verify merge correctness — no data loss or corruption

## Evidence

[Not yet tested]

## Notes

- This doesn't replace h001 — locks are still needed for atomic operations
- CRDT overhead may negate throughput gains for small documents
- Yjs has a Bun-compatible runtime; Automerge requires WASM
```

---

## Writing Good Hypothesis Statements

### Strong Statements (Testable, Specific, Falsifiable)

- "Redis distributed locks with TTL expiration are sufficient for file-level mutual exclusion in multi-agent systems"
- "Streaming LLM responses through WebSocket connections reduces perceived latency by 60% compared to HTTP polling"
- "A single Bun process can coordinate 20+ concurrent agent connections without message loss"
- "Frontmatter-based metadata is sufficient for project state tracking without requiring a database for projects with fewer than 100 stream entries"

### Weak Statements (Help the User Improve These)

| Weak | Problem | Better |
|------|---------|--------|
| "Redis is good for locking" | Not specific or testable | "Redis SET NX with 30s TTL prevents concurrent file access for up to 8 agents" |
| "The system will work" | Not falsifiable | "The coordination server handles 100 requests/second with p99 latency under 50ms" |
| "WebSockets are better" | Better than what? By what measure? | "WebSocket streaming reduces time-to-first-token by 200ms compared to HTTP long-polling" |
| "We should use TypeScript" | Not a hypothesis, it's a preference | "TypeScript's type system catches 80% of agent message format errors at compile time" |
