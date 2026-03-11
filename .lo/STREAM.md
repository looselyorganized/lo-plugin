---
type: stream
---

<entry>
date: 2026-03-10
title: "CI responsibility split"
<description>
Removed duplicated checks between the local ship pipeline and CI. Audit job pulled from per-PR CI — dependency scanning now runs as a weekly scheduled cron for Open projects. CI narrowed to clean-environment checks only: lint, test, build. Local ship owns everything else.
</description>
</entry>

<entry>
date: 2026-03-10
title: "Stage-aware engineering rigor"
version: "0.5.0"
<description>
Skills now scale with project maturity. Explore ships with zero gates — no tests, no review, just commit and push. Build adds the full pipeline. Open adds dependency auditing and a transition wizard for Railway PR deploys, error tracking, uptime monitoring, and rate limiting. Stream broadened from milestones-only to include decisions and lessons.
</description>
</entry>

<entry>
date: 2026-03-10
title: "Stream redesign and skill hardening"
version: "0.4.1"
<description>
Stream consolidated into single STREAM.md with XML entry format for reliable webhook parsing. Milestones-only quality gate — if you wouldn't post it, it's not an entry. All skills rewritten with Anthropic prompt best practices — XML-isolated mode paths fixed a bug where Explore projects got PRs instead of direct main pushes. Eight backlog tasks shipped.
</description>
</entry>

<entry>
date: 2026-03-09
title: "Unified ship and plugin redesign"
version: "0.4.0"
<description>
One ship command, three modes — Explore pushes to main, Build pushes the branch, release branches get the full pipeline. Replaced 9 gates with 6 and moved code review to a dedicated subagent. Added SessionStart hook for PROJECT.md injection and allowed-tools frontmatter across all skills.
</description>
</entry>

<entry>
date: 2026-03-07
title: "Release management and GitHub automation"
version: "0.3.2"
<description>
Built /lo:release for versioned release lifecycle — release branches, changelog generation, merge-to-main with tags. lo-github-sync.sh replaces 200+ lines of inline CI code. EARS requirements as optional formal contract through the plan-work-ship chain.
</description>
</entry>

<entry>
date: 2026-03-04
title: "Research becomes publishing"
version: "0.3.1"
<description>
Killed /lo:research as a standalone skill. Research files stay as raw materials in .lo/research/; publishing is now /lo:publish — a cross-repo pipeline that dispatches articles to the platform.
</description>
</entry>

<entry>
date: 2026-03-03
title: "Plan skill and format standardization"
version: "0.3.0"
<description>
New /lo:plan skill for engineering implementation plans. Major rework of backlog, ship, and work skills — progressive disclosure, concrete examples, format specs extracted to references/ files. CI automation with dormant workflow scaffolding.
</description>
</entry>

<entry>
date: 2026-02-26
title: "Marketplace restructure"
<description>
Restructured from a flat plugin into a marketplace layout with the LO plugin nested under plugins/lo/. Sets up the repo to host multiple plugins under a single registry.
</description>
</entry>

<entry>
date: 2026-02-25
title: "LO work system"
<description>
Built the lo plugin consolidating all skills under the lo: namespace. Backlog management, plan execution with parallel agents, solution capture, and a gated shipping pipeline. Renamed .lorf/ to .lo/ across all projects.
</description>
</entry>
