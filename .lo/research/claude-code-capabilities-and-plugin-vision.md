---
title: "Claude Code Capabilities Deep Dive: What's New, What Matters, and Where LO Goes Next"
date: "2026-03-09"
topics: [claude-code, agent-workflows, skills, subagents, plugin-architecture, developer-tooling]
status: "draft"
project: "lo-plugin"
author: "Michael Hofweller"
readingTime: "18 min read"
---

## The Landscape Has Shifted

Claude Code as of v2.1.71 (March 2026) is a fundamentally different tool than what we built the original ADB against. The surface area of capabilities has expanded in every direction: subagents with custom models and tool restrictions ([docs](https://docs.anthropic.com/en/docs/claude-code/sub-agents)), agent teams with mesh communication ([docs](https://docs.anthropic.com/en/docs/claude-code/agent-teams)), skills as a portable standard ([docs](https://docs.anthropic.com/en/docs/claude-code/skills)), git worktree isolation ([docs](https://docs.anthropic.com/en/docs/claude-code/worktrees)), lifecycle hooks for deterministic control ([docs](https://docs.anthropic.com/en/docs/claude-code/hooks)), background tasks ([docs](https://docs.anthropic.com/en/docs/claude-code/background-tasks)), persistent agent memory ([docs](https://docs.anthropic.com/en/docs/claude-code/memory)), and a CI/CD story that's gone from "possible" to "first-party GitHub Action" ([docs](https://docs.anthropic.com/en/docs/claude-code/github-actions)).

This research examines every major capability, maps what LO already covers, identifies where the platform is going, and develops a strong opinion about what the plugin should become.

---

## Part 1: The Full Capability Map

### Skills — The Winning Abstraction

Skills are now the primary extension mechanism for Claude Code, and the community has voted with their feet. The [`awesome-claude-code`](https://github.com/anthropics/awesome-claude-code) repo has grown rapidly (star count as of writing: verify at time of use). Anthropic ships bundled skills (examples include `/simplify`, `/batch`, `/debug`, `/claude-api`) ([docs](https://docs.anthropic.com/en/docs/claude-code/skills)). The format has been standardized as the [Agent Skills open standard](https://agentskills.io/specification) — portable across Claude.ai, Claude Code CLI, and the API.

**What's new since we last looked:**

- **Custom commands merged into skills.** `.claude/commands/review.md` and `.claude/skills/review/SKILL.md` are now equivalent. Legacy commands files still work; skills take precedence on name conflicts.
- **Dynamic context injection** via `!command` syntax. Shell commands run before skill content is sent to Claude, with output substituted inline. This is preprocessing — Claude only sees the rendered result.
- **Forked execution** with `context: fork` and `agent: <type>`. A skill can declare it runs in an isolated subagent with a specific model and tool set.
- **String substitutions**: `$ARGUMENTS`, `$ARGUMENTS[N]`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`.
- **Invocation control matrix**: `disable-model-invocation: true` hides description from context (user-only). `user-invocable: false` hides from `/` menu (Claude-only). Default: both can invoke, description always in context.
- **`allowed-tools`**: Tools Claude can use without per-use approval when a skill is active.
- **Context budget**: Skill descriptions consume ~2% of context window (fallback: 16,000 chars). Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET`.

**What this means for LO:** Our 11 skills are already in the right format. The key new capabilities — dynamic context injection, forked execution, and allowed-tools — are opportunities we should selectively adopt where they reduce friction. Not everywhere.

### Subagents — Context Isolation as Architecture

Subagents are specialized AI instances with their own context window, system prompt, tool access, and optionally their own model. The main conversation delegates to them and gets back a summary — keeping the primary context clean.

**Built-in types:**

| Type | Model | Tools | Purpose |
|------|-------|-------|---------|
| Explore | Haiku | Read-only | Fast codebase search |
| Plan | Inherited | Read-only | Research during plan mode |
| General-purpose | Inherited | All | Complex multi-step tasks |
| Claude Code Guide | Haiku | Read-only | Self-documentation |

**Custom subagents** live at `.claude/agents/<name>.md` with full frontmatter:

```yaml
---
name: code-reviewer
description: Reviews code for quality. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
maxTurns: 20
memory: user
isolation: worktree
skills:
  - code-conventions
---
```

**Key capabilities:**
- **Model routing**: Route cheap tasks (search, summarization) to Haiku, expensive tasks (code generation) to Opus/Sonnet
- **Persistent memory**: `memory: user` gives a subagent its own memory directory at `~/.claude/agent-memory/<name>/`, persisting across sessions
- **Worktree isolation**: `isolation: worktree` gives each subagent an isolated git worktree, auto-cleaned if no changes
- **Skill preloading**: The `skills` field injects full skill content at subagent startup (not just descriptions)
- **Background execution**: `background: true` or runtime backgrounding with Ctrl+B

**The community pattern**: 100+ community subagents now collected at [`VoltAgent/awesome-claude-code-subagents`](https://github.com/VoltAgent/awesome-claude-code-subagents). The emerging architecture is orchestrator + specialists — one main session coordinating security reviewers, test writers, documentation generators, each reporting back summaries.

**The provocative finding**: One practitioner noted Claude now designs better subagents on the fly than the ones they hand-crafted. This points toward meta-agentic improvement — the system getting better at organizing itself.

### Agent Teams — Experimental, Powerful, Expensive

Agent Teams coordinate multiple full Claude Code instances with mesh communication. Unlike subagents (hub-and-spoke, results-only), teammates message each other directly and self-coordinate via a shared task list.

**The architecture:**
- **Team Lead**: Main session that creates and coordinates
- **Teammates**: Independent instances with full context windows
- **Shared Task List**: `~/.claude/tasks/{team-name}/` with dependency support
- **Mailbox**: Any-to-any messaging (direct or broadcast)

**Enable with**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

**When they're worth it:**
- Research with competing hypotheses (teammates test different theories and challenge each other)
- Cross-layer features spanning frontend, backend, tests
- Architecture debates with multiple positions converging
- 5+ independent tasks or multi-day workstreams

**When they're not:**
- Sequential tasks, same-file edits, tightly-coupled work
- Anything 2-4 subagents could handle (subagents are cheaper)
- Simple parallelizable changes (`/batch` is simpler)

**Token cost scales linearly** — each teammate is a full Claude instance. Best with 3-5 focused teammates.

### Git Worktrees — Isolation Without Overhead

Worktrees create separate working directories sharing repository history. Claude Code uses them to prevent session collisions.

```bash
claude --worktree feature-auth
# Creates .claude/worktrees/feature-auth/ with branch worktree-feature-auth
```

**Cleanup behavior:**
- No changes → auto-removed on session exit
- Changes exist → prompt to keep or remove

**The `/batch` pattern**: The bundled `/batch` skill automatically creates one worktree per unit of work, runs tests in each, and opens a PR. This is the recommended approach for large-scale parallel changes.

**Non-git VCS**: `WorktreeCreate` and `WorktreeRemove` hooks support SVN, Perforce, etc.

### Hooks — Deterministic Control Over Probabilistic Behavior

Hooks are user-defined shell commands that execute at lifecycle points. They're the escape hatch from pure LLM control — when you need something to happen every time, not just when the model remembers.

**14 hook events:**

| Event | When |
|-------|------|
| `SessionStart` | Session begins/resumes/clears/compacts |
| `UserPromptSubmit` | User submits a prompt |
| `PreToolUse` | Before tool execution |
| `PostToolUse` | After tool success |
| `PostToolUseFailure` | After tool failure |
| `SubagentStart/Stop` | Subagent lifecycle |
| `Notification` | Claude needs attention |
| `TaskCompleted` | Task marked complete |
| `PermissionRequest` | Claude requests permission for a tool or action |
| `TeammateIdle` | A teammate has no pending work |
| `PreCompact` | Before context compaction |
| `SessionEnd` | Session terminates |
| `Stop` | Claude finishes responding |

**Hook types:**
- `command`: Run shell command
- `http`: POST to URL
- `prompt`: Single LLM turn for yes/no
- `agent`: Multi-turn agent verification

**Exit code protocol:**
- `0`: Allow, optionally inject context via stdout
- `2`: Block action, send feedback to Claude
- Other: Allow, log to verbose mode

**Scoped hooks**: Can be defined globally, per-project, per-skill, or per-subagent.

### MCP Integration

MCP (Model Context Protocol) servers extend Claude Code with external tools and data. Configured per-project or globally. In this session alone, we have Firecrawl, context7, shadcn, and browser automation MCP servers.

MCP is the integration layer — how Claude Code talks to external services. Skills are the workflow layer — how Claude Code organizes its own behavior. These are complementary, not competing.

### CI/CD — First-Party, Production-Ready

Anthropic ships `anthropics/claude-code-action` — a first-party GitHub Action.

**Trigger patterns:**
- PR auto-review on every push
- `@claude` mentions in comments
- Manual commands like `/gen-tests`
- `workflow_dispatch` for on-demand

**Community security consensus:**
- Pin action versions by commit SHA
- `contents: read` + `pull-requests: write` + `issues: write` — nothing broader
- Never push AI changes directly to protected branches — always via PR with required reviews
- Label AI-touched PRs (`ai-assisted`) for audit trails
- Cap `--max-turns` to control cost

### Background Agents & Headless Mode

The `9to5` community project runs Claude Code on schedules and webhooks. Anthropic has previewed this direction. The pattern: "Claude Code running while you sleep" — background agents that pick up tasks from a queue.

### Permission Modes

| Mode | Behavior |
|------|----------|
| `default` | Standard permission prompts |
| `acceptEdits` | Auto-accept file edits |
| `plan` | Read-only exploration |
| `dontAsk` | Auto-deny unpermitted tools |
| `bypassPermissions` | Skip all checks |
| `auto` (preview) | Intelligent auto-approval |

> **Note:** `auto` mode is a research preview rollout expected around mid‑March 2026 and may not be available in all environments — treat it as unstable.

---

## Part 2: What the Community Has Learned

### The Dominant Workflow Pattern

Across Reddit, HN, and engineering blogs, the same cycle emerges independently:

**Explore → Plan → Code → Commit**

This is essentially what LO's `plan → work → ship` models. The community arrived at the same structure without knowing about our plugin. That's validation.

### Power User Patterns

1. **Parallel sessions as "team of juniors"**: 3-5 Claude Code sessions on separate branches, morning standup-style task decomposition
2. **TDD-first**: Write failing tests, then instruct Claude to make them pass
3. **Error log reconstruction**: Feed entire error logs + context for rapid debugging
4. **Living CLAUDE.md**: Treat it as a continuously updated onboarding document
5. **Context budgeting**: Aggressive discipline about what goes into context (tool descriptions alone can consume 35%+)

### The Arize Finding

Arize's prompt optimization research found that optimizing only the CLAUDE.md — with no other changes — yielded **+5.2% improvement on SWE Bench** and **+10.9% on repository-specific tasks** *(source: Arize AI internal research, 2025–2026; link to original report to be added when publicly available)*. Repository-specific configuration is a "practical superpower."

This validates LO's approach of maintaining rich project context in `.lo/PROJECT.md`, but it also suggests we may want a skill that helps users refine their CLAUDE.md iteratively based on session outcomes.

### CodeRabbit Integration

CodeRabbit now has first-class Claude Code plugin support:

1. Claude Code implements a feature
2. CodeRabbit analyzes the PR
3. Claude Code works through findings
4. Repeat until clean

The value: CodeRabbit catches race conditions, memory leaks, and logic errors that generic linters miss. It also reads CLAUDE.md to calibrate reviews against project standards.

### The `obra/superpowers` Analog

The closest community equivalent to LO is Jesse Vincent's [`superpowers`](https://github.com/obra/superpowers) collection — `/brainstorm`, `/write-plan`, `/execute-plan`, etc. It's the most prominent community skill set with 20+ battle-tested skills. Worth studying for gaps. Key difference: superpowers is generic workflow tooling; LO is an opinionated work system for research-oriented projects.

### Where People Think It's Going

1. **Background/headless agents**: Always-on AI developer, picking up tasks from queues
2. **Orchestration as the core human skill**: Developers shift from "writer of code" to "director of agents"
3. **Skills as the primary extension mechanism**: Community has chosen skills over raw system prompts or MCP for repeatable workflows
4. **Self-improving agents**: Meta-agentic patterns where Claude designs better subagents than hand-crafted ones
5. **Enterprise governance gap**: Skill distribution and admin management not yet solved at enterprise scale

---

## Part 3: Where LO Is Now

### The Current Skill Map (11 Skills, v0.4.0)

```text
/lo:new       → Scaffold .lo/ directory
/lo:backlog   → Manage features and tasks
/lo:plan      → Design before execution (mandatory brainstorming)
/lo:work      → Execute with branch isolation + parallelization
/lo:ship      → Quality pipeline (9 gates: tests, security, simplification, PR)
/lo:release   → Versioned releases with changelogs
/lo:stream    → Editorial log of progress (curated, not raw git)
/lo:solution  → Capture reusable knowledge
/lo:status    → Lifecycle transitions (Explore → Build → Open → Closed)
/lo:publish   → Transform research into MDX articles
/lo:stocktaper-design-system → UI component design tokens
```

### The Dependency Graph

```text
new → (backlog | status)
backlog → plan
plan → work
work → ship
ship → (stream | solution | release)
release → (stream | solution)
status → (transitions trigger automation)
```

### What's Working

1. **The plan → work → ship pipeline** matches the community's independently-discovered explore → plan → code → commit cycle
2. **Mandatory brainstorming** before planning (design first, code second) is a differentiator — most tools skip this
3. **9-gate quality pipeline** in ship (tests, security, simplification, EARS audit) is more rigorous than anything in the community
4. **Stream as editorial layer** — curated narrative on top of git, not a commit log restatement — is unique
5. **Solution capture** — institutional memory that compounds — is unique
6. **EARS requirements** integration for complex features is sophisticated

### What's Missing or Underexploited

1. **No custom subagents**: LO doesn't ship subagent definitions. The `/lo:work` skill describes parallelization strategies but doesn't provide pre-configured agents optimized for LO's workflow
2. **No hooks**: No lifecycle hooks for deterministic behavior (auto-format on edit, auto-lint on commit, status notifications)
3. **No dynamic context injection**: Skills don't use `!command` syntax to pull live data (git state, recent changes, project status) at invocation time
4. **No `context: fork` usage**: No skills run in forked subagent context despite some being good candidates (stream scanning, backlog queries)
5. **No `allowed-tools` declarations**: Skills don't pre-authorize tools, meaning users get more permission prompts than necessary
6. **No persistent agent memory**: No use of `memory:` for building institutional knowledge across sessions
7. **Research skill deleted**: Gap in the workflow for structured investigation

---

## Part 4: The Vision — Strong Opinions, Loosely Held

### Thesis: Less Is More, But the Right Less

The temptation after seeing all these capabilities is to adopt everything. Custom subagents for every skill. Hooks for every lifecycle event. Dynamic context injection everywhere. Agent teams for complex features.

**That would be a mistake.**

The LO plugin's value isn't in maximizing Claude Code's feature surface — it's in providing an opinionated workflow that makes the human-AI collaboration productive without requiring the human to understand the underlying machinery. The plugin should absorb complexity so the user doesn't have to.

### What to Actually Do

#### 1. Keep the Core Pipeline Exactly As Is

`plan → work → ship` is the right abstraction. The community independently converged on the same pattern. Don't over-engineer it.

The skills are already well-structured. The brainstorming requirement is a genuine differentiator. The quality gates in ship are more rigorous than anything else in the ecosystem. The stream and solution capture create compounding value over time.

**Action: No structural changes to the pipeline.**

#### 2. Add Selective Dynamic Context Injection

Three skills would materially benefit from `!command` preprocessing:

- **`/lo:ship`**: Inject `!git diff --stat` and `!git log --oneline -10` at the top so the skill starts with awareness of what's being shipped
- **`/lo:stream`**: Inject `!git log --oneline --since="30 days ago"` to have recent history pre-loaded
- **`/lo:work`**: Inject `!cat .lo/PROJECT.md | head -20` to have project context immediately

These are small, targeted changes that reduce the back-and-forth of "let me read the project state" at the start of every skill invocation.

#### 3. Add `allowed-tools` to Reduce Permission Friction

Every skill should declare which tools it needs so the user isn't prompted repeatedly:

```yaml
# /lo:ship
allowed-tools: Read, Grep, Glob, Bash(npm test), Bash(bun test), Bash(git *)
```

```yaml
# /lo:work
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent
```

```yaml
# /lo:stream (read-only analysis)
allowed-tools: Read, Grep, Glob, Bash(git log *)
```

This is pure friction reduction — no behavior change.

#### 4. Consider (But Don't Rush) Two Custom Subagents

If we ship any custom subagents, they should be:

**a) `lo-reviewer`** — A code review subagent optimized for LO projects:
```yaml
---
name: lo-reviewer
description: Reviews code against LO project standards. Use during /lo:ship.
tools: Read, Grep, Glob
model: sonnet
memory: project
skills:
  - ship
---
```

**b) `lo-researcher`** — A research subagent to fill the deleted research skill gap:
```yaml
---
name: lo-researcher
description: Conducts structured research. Use when investigating technologies or approaches.
tools: Read, Grep, Glob, WebSearch, WebFetch
model: opus
isolation: worktree
---
```

But these are optional. The skills themselves already orchestrate subagent behavior through the Agent tool. Custom subagent definitions are a convenience, not a necessity.

#### 5. Don't Ship Hooks (Yet)

Hooks are powerful but they're infrastructure, not workflow. They belong in the user's `.claude/settings.json`, not in the plugin. Reasons:

- Hooks are environment-specific (macOS notification commands don't work on Linux)
- Hook behavior is deterministic and should be controlled by the user, not the plugin
- Shipping hooks creates a maintenance burden and a surface area for breakage

If anything, a future skill could *help users set up hooks* for their LO projects — a `/lo:setup-hooks` that generates a recommended hooks configuration. But the hooks themselves should live in user space.

#### 6. Don't Adopt Agent Teams

Agent Teams are experimental, expensive (linear token scaling), and solve a problem LO doesn't have. The `/lo:work` skill already handles parallelization through subagents and worktrees. Agent Teams are for when you need multiple agents to *discuss and challenge each other's work* — a pattern that's valuable for open-ended research but overkill for structured feature execution.

If the user wants Agent Teams, they can enable them. The plugin shouldn't assume or require them.

#### 7. Revive the Research Skill — But Simpler

The deleted research skill should come back as a lightweight investigation framework:

```text
/lo:research <topic>
```

Steps:
1. Create `.lo/research/<slug>.md` with frontmatter
2. Use the Explore subagent to search the codebase for context
3. Optionally use WebSearch/WebFetch for external research
4. Present findings in a structured format
5. Save to the research directory

No EARS requirements. No multi-phase planning. Just: investigate, synthesize, save.

#### 8. The CLAUDE.md Optimization Opportunity

The Arize finding (+10.9% on repository-specific tasks from CLAUDE.md optimization) suggests a future skill:

```text
/lo:optimize-context
```

This would:
1. Read the current CLAUDE.md and `.lo/PROJECT.md`
2. Analyze recent session patterns (what Claude asks repeatedly, what context is missing)
3. Suggest additions or refinements to the project configuration
4. Apply changes with user approval

This is speculative — it requires session history analysis that may not be feasible today. But it's the direction where the most leverage lives.

### The Integration Question: GitHub, CodeRabbit, and External Systems

The user explicitly noted being unopinionated on how interdependent the plugin should be with external systems. Here's the framework for deciding:

**Integrate tightly with:**
- **Git** — it's universal, deterministic, and the source of truth. LO already does this well.
- **GitHub** (via `gh` CLI) — the `/lo:ship` and `/lo:release` skills already create PRs. This is the right level of coupling.

**Integrate lightly with:**
- **CodeRabbit** — The `/lo:release` skill already has a `cr-agent` pattern for handling CodeRabbit comments (up to 3 rounds). This is good. Don't go deeper — CodeRabbit's behavior changes frequently and tight coupling creates maintenance burden.
- **CI/CD** — The skills should *work with* CI (wait for checks, read results) but not *configure* CI. CI configuration is infrastructure that belongs in the repo, not the plugin.

**Don't integrate with:**
- **Specific hosting platforms** (Railway, Vercel, etc.) — these are orthogonal to the work management workflow
- **Specific testing frameworks** — the skills already detect test runners dynamically
- **Slack/Discord/communication tools** — the plugin manages work, not communication

### The Deeper Pattern: Skills as Institutional Knowledge

The most important insight from this research isn't about any single feature. It's about what skills represent in the context of AI-assisted development.

A skill is not a macro. It's not a template. It's **codified institutional knowledge about how work should be done**.

When `/lo:ship` runs 9 quality gates in sequence — tests, security review, code simplification, EARS audit — it's encoding the judgment of an experienced engineer who knows what gets missed when you're moving fast. When `/lo:plan` requires brainstorming before planning, it's encoding the lesson that premature implementation is the most expensive mistake in software.

This is why "we may only need a few structured skills and not over-engineer" is as valid a conclusion as a comprehensive feature matrix. The value isn't in the number of skills — it's in the quality of the judgment encoded in each one.

The skills that matter most are the ones that prevent the mistakes humans make under pressure: shipping without testing, coding without designing, solving without understanding, building without capturing what was learned.

LO already has these. The evolution should be about making them smoother, not more numerous.

---

## Part 5: Predicted Evolution of Claude Code

### Near-Term (3-6 months)

1. **Agent Teams graduates from experimental**: The shared task list + mesh communication pattern will stabilize and become the default for complex work
2. **Persistent agent memory becomes standard**: Subagents that remember patterns across sessions will be the default, not the exception
3. **Background agents ship officially**: Anthropic will ship a first-party solution for "always-on" Claude Code instances — likely integrated with GitHub Actions
4. **Skill marketplace**: A central registry for discovering and installing skills, similar to VS Code extensions

### Medium-Term (6-12 months)

5. **Self-improving agents**: Agents that analyze their own performance and suggest skill/configuration improvements — the meta-agentic pattern
6. **Enterprise skill governance**: Admin tools for distributing, versioning, and enforcing skills across organizations
7. **Deeper IDE integration**: Agent teams visible in VS Code/JetBrains as a persistent panel, not just CLI
8. **Model routing becomes automatic**: Claude Code automatically selects the cheapest model that can handle each subtask

### Long-Term (12+ months)

9. **Agent-native project management**: The work management layer (backlog, planning, execution, shipping) becomes a first-class Claude Code feature — which is exactly what LO already provides. This is both a threat and a validation.
10. **Continuous integration of AI and human work**: The boundary between "human-written" and "AI-written" code dissolves entirely, replaced by provenance metadata and quality gates
11. **Skills as the new APIs**: Instead of building REST endpoints, teams build skills that other agents can invoke — inter-agent collaboration through shared skill protocols

### What This Means for LO

The plugin occupies a space that Claude Code itself may eventually absorb. That's fine. The ADB preceded official features by months. The skill system preceded the standard by months. LO's role is to be the leading edge — to discover what works through daily use and let the platform catch up.

The things that won't be absorbed:
- **Opinionated workflow** (brainstorming before planning, mandatory quality gates)
- **Institutional knowledge capture** (solutions, stream)
- **Project lifecycle management** (status transitions, release coordination)
- **Design system integration** (StockTaper)

These are domain-specific enough that they'll always be plugin territory.

---

## Conclusion: The Minimum Effective Plugin

After examining every major Claude Code capability, the community ecosystem, and the current state of LO, the recommendation is:

**Keep the core pipeline. Add three targeted improvements. Don't over-engineer.**

1. Add `allowed-tools` to every skill (friction reduction)
2. Add dynamic context injection to ship, stream, and work (faster startup)
3. Revive the research skill as a lightweight investigation tool

Everything else — custom subagents, hooks, agent teams, CLAUDE.md optimization — is interesting but not necessary yet. The plugin's value is in the workflow judgment it encodes, not in the number of Claude Code features it touches.

The best plugin is the one that fades into the background. You say `/lo:plan`, it brainstorms. You say `/lo:work`, it executes. You say `/lo:ship`, it runs every check that matters. The machinery is invisible. The work is what shows.

That's the vision. A few structured skills that encode real engineering judgment, running on a platform that's getting better at everything else every month.
