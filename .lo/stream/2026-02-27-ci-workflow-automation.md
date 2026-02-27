---
type: "milestone"
date: "2026-02-27"
title: "CI workflow automation"
commits: 5
---

`/lo:new` now writes a dormant CI caller workflow at scaffold time. `/lo:status` manages the CI lifecycle — activating, pausing, and syncing the workflow on every transition. Branch protection switched to reusable workflow job names. `/lo:ship` enables auto-merge on PR creation.
