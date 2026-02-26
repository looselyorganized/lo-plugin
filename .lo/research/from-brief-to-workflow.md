---
title: "From Brief to Workflow: How a Template Became a Work System"
date: "2026-02-25"
topics: [agent-workflows, work-management, developer-tooling, ai-collaboration]
status: "draft"
project: "lo-plugin"
author: "Michael Hofweller"
readingTime: "12 min read"
---

We were early on this, really early. In June 2025 — three months before GitHub shipped Spec Kit, six months before GSD and Compound Engineering arrived — we created the Agent Development Brief.

At the time, engineers were just beginning to run up against issues related to tracking and managing work in process when using a coding agent. We were day-one Claude Code users, and we felt these issues as major pains after a few weeks of usage. You'd start a session, explain the project, get some good work done, then close the terminal. Next session: same explanation. Same context. Same questions from the agent. The knowledge didn't stick.

Through trial and error we discovered quickly that Markdown was the medium of choice for storing context for localized coding agents. Read/write speed was incredibly fast — context ingestion was immediate without any API calls. The agent could read a `.md` file and have your entire project brief in its working memory in milliseconds. No database queries. No network round trips. Just files on disk.

So it was no surprise when we picked Markdown to build the ADB on. Six documents that didn't just give AI agents project context, but told them how to operate: read the brief in order, ask clarifying questions, update the documents when decisions changed, generate an implementation plan with testable phases, log decisions as you make them, track progress as you go.

Claude Code wasn't able to break down tasks as accurately or maneuver through execution as well as it does today. Back then, you'd hand it a feature description and it would either try to build everything in one shot — touching fifteen files in a single pass — or get paralyzed asking "what should I do first?" at every turn. The ADB was our attempt to give it guardrails: here's the scope, here's the stack, here's how you make decisions, and here's where you write down what you decided.

When the frameworks arrived later that year — each attacking a different piece of the problem — they validated our instinct and expanded the vocabulary. Eight months after that first commit, we took the best of what everyone had learned and synthesized it into something purpose-built: a work system for operating an innovation lab with AI agents.

## The Agent Development Brief

The ADB started with a frustration everyone was hitting: context amnesia. Every new session was a cold start. Your agent had no idea what happened yesterday, what decisions were locked, or what phase the project was in.

Most people were solving this with a `CLAUDE.md` file — a grab bag of notes, preferences, and reminders stuffed into the project root. It worked the way sticky notes on a monitor work: better than nothing, but not a system.

The ADB was a system. Six Markdown files with specific roles:

- **main.md** — the entry point. Told the agent to read five documents in order, ask clarifying questions about anything ambiguous, update documents when decisions changed, then create `PROJECT_STATUS.md` — a phased implementation plan with testable deliverables. The agent updated this plan after completing each phase.
- **product-requirements.md** — what we're building, who it's for, user stories, trade-off priorities, what's explicitly out of scope.
- **technical-guidelines.md** — stack, architecture constraints, performance requirements, known limitations.
- **design-requirements.md** — design goals, core user flows, success criteria.
- **agent-operating-guidelines.md** — the decision authority model.
- **decision-log.md** — a running log the agent wrote to during work. Every significant decision got a timestamp, a title, and reasoning.

The decision authority model was the part that felt genuinely new. We defined six levels:

| Level | What it means |
|-------|--------------|
| Human-Decides | Human makes the call, agent implements |
| Agent-Proposes-Human-Decides | Agent suggests options, human chooses |
| Agent-Decides-Human-Review | Agent decides and implements, human can override |
| Agent-Autonomous | Agent has full authority, no review needed |
| Collaborative | Both parties discuss until consensus |
| Already-Decided | Pre-established in project docs, don't relitigate |

Each decision type — architecture, UX, implementation details, scope changes, technology choices — got mapped to one of these levels. The agent knew when to ask and when to act. Not every choice has the same stakes, and treating them all as "ask the human" wastes time just as much as treating them all as "just do it" wastes trust.

The ADB shipped with a worked example — CatGram, a social media app for cats — that showed what a filled-in brief looked like. You could clone the repo, replace CatGram with your project, and have a structured brief in twenty minutes.

This was June 6, 2025. There was nothing else like it.

## Where It Hit the Ceiling

The ADB worked well for what Claude Code could do at the time. But as the models improved and projects got more ambitious, the gaps became clear.

**The plan was a monolith.** `PROJECT_STATUS.md` was a flat list of phases. No concept of parallel execution, no dependency tracking, no way to say "tasks 2 and 3 can run simultaneously but task 4 depends on both." When Claude got better at handling complexity, we were still handing it a sequential checklist.

**No learning mechanism.** The decision log captured choices, but not *patterns*. When the agent figured out that a specific caching strategy worked for a specific kind of data access — that insight evaporated at the end of the session. Next similar problem, next cold start.

**No work management.** The brief told you what to build. It didn't track what was built, what was in progress, or what was next. The human kept all that state in their head and relayed it at the start of each session. For a small project, fine. For a lab running five concurrent projects, untenable.

**No shipping pipeline.** The ADB ended at "implement the plan." Getting code from a working branch to a merged PR — tests, review, security check, commit, push, PR creation — was all manual orchestration. Every time.

We refined the templates in September 2025 — tighter product requirements, better structure in the design doc, cleaner decision log format. But these were surface changes. The architecture was the ceiling: one brief, one plan, one agent, one shot.

## The Framework Explosion

Between September and December 2025, three frameworks arrived that each cracked open a different dimension of the problem.

### Spec Kit — Specifications as Source of Truth

GitHub's Den Delimarsky and John Lam shipped Spec Kit in September 2025. Their insight cut deeper than ours had: the specification isn't a preamble to the work — it *is* the work. Code is the output of a good spec.

Spec Kit introduced a three-layer context architecture:

1. **Constitution Layer** — permanent project rules. Stack versions, naming conventions, architectural patterns, security requirements. Things that don't change mid-project. This was like our technical-guidelines.md, but elevated to a first-class concept with its own file and its own workflow stage.
2. **Specification Layer** — user stories, acceptance criteria, business requirements. The what.
3. **System Design Layer** — service mapping, data flow, integration points. The how.

Their six-stage workflow — CONSTITUTION → SPECIFY → CLARIFY → PLAN → TASKS → IMPLEMENT — made the ADB's "read everything then build" look like a single-step process. And the `[P]` markers on tasks for parallel execution was a signal: they'd thought about the execution model we'd hand-waved past.

### GSD — Solving Context Rot

In December 2025, TACHES (@glittercowboy) released GSD. Where Spec Kit focused on specification quality, GSD attacked context rot — the slow degradation of an agent's understanding as the conversation window fills up and early details get pushed out of memory.

We'd been feeling this acutely. Long sessions with Claude would start strong and slowly drift. The agent would forget a technical constraint from hour one, or relitigate a decision that had been locked three exchanges ago. The longer the session, the worse it got.

GSD's answer was multi-agent orchestration with fresh context windows. Instead of one agent carrying everything, specialized agents — planner, researcher, executor, verifier, debugger — each start clean, loaded only with what they need. Key primitives:

- **PLAN.md** with XML-structured tasks including explicit verification steps
- **Wave-based execution** — independent tasks run in parallel within waves, dependent tasks run sequentially across waves
- **STATE.md** — decisions, blockers, and position that persists across sessions
- **CONTEXT.md** — locked decisions that can't be revisited (solving the relitigation problem we'd seen constantly)

The wave model was the execution framework we'd been missing. And locked decisions — `[Already-Decided]` from our ADB, but enforced structurally instead of advisory — addressed a real pain point.

### Compound Engineering — The Learning Loop

Dan Shipper and Kieran Klaassen at Every.to published Compound Engineering around the same time. Their thesis was the one that changed how we thought about everything: each feature you build should make the *next* feature easier. Not through better code, though that helps — through accumulated knowledge that compounds over time.

Their four-step loop inverted the effort allocation we'd assumed:

1. **PLAN** (80% of effort) — Research, synthesize, create detailed plans
2. **WORK** (20% of effort) — Write code and tests according to plans
3. **REVIEW** (80% of effort) — Analyze output, identify issues, evaluate
4. **COMPOUND** (20% of effort) — Feed learnings back into the system

That fourth step — compound — was what the ADB had been missing entirely. Our decision log recorded *what* was decided. Compound Engineering recorded *what was learned*. And it fed those learnings back into the system so the next planning cycle started smarter than the last.

The formula they proposed: `Productivity = (Code Velocity) × (Feedback Quality) × (Iteration Frequency)`

This reframed the whole game. It wasn't about making the agent faster at writing code. It was about making the *system* — human plus agent plus accumulated knowledge — faster at producing good outcomes.

## The Common Patterns

In February 2026, we did a deep research pass across all three frameworks — plus enterprise workflow standards (BPMN, CMMN), distributed systems patterns (sagas, event sourcing, Temporal), economic coordination models (bounty systems, smart contracts), and academic multi-agent literature (Contract Net Protocol, BDI, stigmergy). Six paradigms, dozens of approaches.

The coding frameworks — GSD, Spec Kit, Compound — converged on the same patterns despite being built independently by teams who weren't talking to each other:

**Phased gated workflows.** Every framework gates work into stages. Nobody lets the agent run from brief to deployed code in one shot.

```
GSD:           DISCUSS → PLAN → EXECUTE → VERIFY
Compound:      PLAN → WORK → REVIEW → COMPOUND
Spec Kit:      SPECIFY → PLAN → TASKS → IMPLEMENT
```

**Atomic task units.** GSD caps plans at 3 tasks to stay under 50% context window. Compound scopes each task to 1-2 files so it's reviewable and reversible. Spec Kit marks tasks with `[P]` for parallel execution. All three agree: small, bounded, clear completion criteria.

**Dependency graphs with parallelization.** All model work as a DAG with explicit sequential and parallel markers. Without this, the agent serializes everything or tries to do everything at once. Both are wrong.

**Persistent context.** All maintain knowledge that survives across sessions. GSD uses STATE.md and CONTEXT.md. Compound feeds learnings back. Spec Kit has its constitution layer. The session boundary is the enemy.

**Verification as first-class.** All require explicit success criteria before execution begins. You define "done" upfront and verify against it.

**Human-in-the-loop checkpoints.** All have explicit pause points. The agent works autonomously within a phase but checks in at boundaries. This was our decision authority model from the ADB, refined from advisory into structural.

Three teams. Three independent frameworks. Same six patterns. That convergence told us something real had been found.

## The Synthesis

We didn't want to build a protocol. Our work-item-protocol research had mapped out six viable approaches to standardizing agent work — from A2A extensions to economic models to durable execution runtimes. All valid. All premature for the problem in front of us.

Our problem was specific: we run the Loosely Organized Research Facility — an innovation lab where projects come in as hypotheses, graduate through research and design, get built, get shipped. We needed a work system for *that*, not a universal interchange format.

So we took the patterns from GSD, Compound, and Spec Kit — plus what still worked from the ADB — and built nine Claude Code skills packaged as a plugin called `lo`. Each skill has a clear lineage:

**`/lo:new`** is the ADB reborn. But instead of templates with placeholders, it scans the repo — detects the stack from package.json and imports, finds infrastructure from config files and CI/CD, reads the README for project description — and pre-fills what it can. It creates the `.lo/` directory convention and walks you through what it couldn't auto-detect. The brief isn't a document you fill in before work starts. It's generated as the first step of work.

**`/lo:backlog`** gives us what the ADB never had — work management. A BACKLOG.md with features and tasks. When you `/lo:backlog start "auth"`, it graduates the feature to active work: creates a work directory, invokes brainstorming to explore the design, then writes a structured implementation plan. Everything enters through the backlog before it becomes work.

**`/lo:work`** is GSD's wave executor rebuilt as a Claude Code skill. It reads plans from `.lo/work/`, parses dependencies and parallelization markers, asks whether you want a branch or worktree for isolation (recommending the best option based on scope), and executes. Sequential tasks run one at a time. Independent tasks dispatch to subagents in parallel. It reports after each task, stops at phase boundaries, and never ships — that's a different skill with different gates.

**`/lo:ship`** is a ten-gate quality pipeline. Pre-flight check (not on main, clean working tree). Run tests. Code simplification review. Security scan. Commit. Push. Create PR. Write stream entry. Update backlog. Prompt for solution capture. If any gate fails, the pipeline stops and tells you what to fix. Inspired by Spec Kit's staged approach and born from too many times we pushed code that should have been reviewed first.

**`/lo:solution`** is Compound Engineering's compound step. After shipping — or any time you solve something non-obvious — it prompts three questions: What problem did you run into? What approach worked? When would you use this again? The answers go into `.lo/solutions/` as structured documents with tags. Future brainstorming and planning sessions search this directory first. Knowledge compounds. The tenth feature should be easier than the first.

**`/lo:hypothesis`** captures directional bets — technology choices, architecture assumptions, approach hunches — before you act on them. Quick mode takes a statement inline and generates the file. Guided mode walks you through refining the statement and adding context. Either way, the hypothesis lands in `.lo/hypotheses/` with a testable claim, a status, and room for evidence.

**`/lo:stream`** is a curated editorial layer on top of git. It doesn't restate commits — it groups them under thematic arcs. A milestone like "lo plugin v0.2.0" references the twelve commits that built it. The stream provides narrative; git stays the source of truth for details.

**`/lo:research`** generates structured research articles with editorial guidelines — direct voice, concrete examples, narrative arc from problem through iteration to insight. This article was written with it.

**`stocktaper-design-system`** is the visual identity skill — the StockTaper design system with color tokens, typography scale, component catalog, and layout patterns. It's the subject of our previous article, "From Aesthetic to Algorithm," and it travels with the plugin so every LO project gets the same visual language.

## The `.lo/` Convention

Everything converges on a directory:

```
.lo/
├── PROJECT.md          # Project brief and metadata
├── BACKLOG.md          # Features and tasks (created by /lo:backlog)
├── hypotheses/         # Testable claims with evidence
├── stream/             # Curated milestones and updates
├── research/           # Structured research articles
├── work/               # Active feature directories with plans
├── solutions/          # Reusable knowledge from completed work
└── notes/              # Scratch space
```

Every file is plain Markdown with YAML frontmatter. No custom formats. No databases. No config files beyond what's needed. A human can read any file with `cat`. An agent can parse any file with standard tooling. The website reads this directory — via GitHub webhooks into Supabase — and populates project pages automatically. The `.lo/` convention is both the internal work system and the external publishing pipeline.

This is what the ADB was reaching for but couldn't quite express with six template files: a living project structure where the brief, the backlog, the plans, the decisions, and the accumulated knowledge all live together and evolve together. Nothing is static because nothing needs to be.

## What's Different About v0.2.0

This is not a framework. Not a protocol. Not a standard.

It's nine skills that work today, in one tool, for one team. Some deliberate choices:

**Skills, not agents.** GSD has six specialized agent types. We have skills that run in the same Claude Code session. The skill shapes the agent's behavior for a specific task — it doesn't spin up a separate system. Simpler. Faster. No infrastructure to maintain.

**Files, not services.** Everything lives in `.lo/` as Markdown. No databases, no APIs, no running processes beyond what's already there. Git is the transport. The filesystem is the state store. Any developer with a text editor can see and modify every piece of project state. We chose this deliberately — Markdown got us here, and it's what keeps us fast.

**Convention, not configuration.** The directory structure is fixed. PROJECT.md is always at `.lo/PROJECT.md`. Hypotheses are always in `.lo/hypotheses/`. There's nothing to configure because there's nothing to get wrong.

**Plugin, not scattered files.** The skills ship as a Claude Code marketplace plugin — `lo` under the `looselyorganized` marketplace. One install command, all nine skills. Version-controlled, distributable, updatable. This is a long way from the ADB's "clone the repo and edit the templates."

**Deliberately incomplete.** No automated verification agents. No constitution layer. No reputation scoring. No economic incentives. Those are all good ideas that showed up in the research. They're also scope creep for v0.2.0. What we have is the loop: backlog → plan → work → ship → learn. That loop works today.

## Operating the Lab

The Loosely Organized Research Facility isn't a blog. It's an agent-interoperable research platform — a proving ground for the very infrastructure it studies. Nexus tests multi-agent coordination. Yellow Pages tests agent discovery. The Work Item Protocol tests task distribution across agent boundaries. The facility researches agentic infrastructure by *being* agentic infrastructure.

The lo-plugin is the operating system for this. Here's how work actually flows:

1. A hypothesis gets logged — `/lo:hypothesis`
2. Research explores whether it holds — `/lo:research`
3. If it does, a feature hits the backlog — `/lo:backlog feature "X"`
4. When it's time to build, the feature graduates — `/lo:backlog start "X"`
5. Brainstorming explores the design, a plan gets written to `.lo/work/`
6. The plan executes with parallelization and progress tracking — `/lo:work`
7. The quality pipeline ships a PR — `/lo:ship`
8. Reusable knowledge gets captured — `/lo:solution`
9. A milestone hits the stream — `/lo:stream`

Every step is executable by an agent with the lo-plugin loaded. The skills aren't documentation. They're instruction sets. An agent can run this loop, checking in with the human at the gates we've defined — the same decision authority model from the original ADB, now embedded in the pipeline's structure rather than written in a guidelines doc.

The longer-term vision is a facility where external agents discover projects through the Yellow Pages, browse open work items via MCP tools, claim tasks, and build reputation. The `.lo/` convention becomes the interface between internal work and the broader agent ecosystem. The backlog feeds into distributed task allocation. Solutions compound across project boundaries. The stream publishes progress that other agents consume.

We're not there yet. But the architecture is designed for it.

## What We're Still Figuring Out

**Branch discipline.** The lo:work skill asks about branches and worktrees before executing. We caught ourselves committing directly to main during the initial build — while building the system that's supposed to prevent committing directly to main. The skill says the right thing. Actually following it when you're moving fast is a different problem.

**Plan granularity.** How detailed should plans be? GSD says max 3 tasks. Compound says each task touches 1-2 files. The plan for building the lo-plugin had 16 tasks across 5 phases — too many for one session, too few for full multi-agent orchestration. We haven't found our number yet.

**Solution discovery.** The `.lo/solutions/` directory captures knowledge, but nothing searches it automatically during planning. The vision: before you brainstorm a new feature, the agent scans solutions for relevant patterns. That wiring isn't done yet.

**Cross-project learning.** Each project has its own `.lo/solutions/`. But a caching pattern from Nexus might matter for the Dashboard. There's no cross-pollination mechanism. This might be where the Work Item Protocol fits — not as a task distribution system, but as a knowledge distribution one.

---

We started in June 2025 with six template files and the instinct that agents needed structured project context to do good work. The frameworks that followed — Spec Kit, GSD, Compound Engineering — proved us right and showed us what we'd missed: execution models, learning loops, gated pipelines, parallelization.

The lo-plugin is our synthesis. Small, opinionated, built for one purpose: operating an innovation lab where agents are collaborators, not just tools. Nine skills. One directory convention. A loop that runs.

v0.2.0. The lab is open.
