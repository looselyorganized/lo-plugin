# Execution Patterns Reference

Technical reference for parallel execution patterns. Consult when executing parallel work (Level 2 or Level 3).

## Level Selection Criteria

| Signal | Level |
|--------|-------|
| All tasks depend on each other | Sequential |
| 2-4 independent tasks in a phase | Subagents |
| 5+ independent tasks or multi-day workstreams | Agent Teams |
| Tasks touch overlapping files | Sequential (safest) |
| Tasks touch completely separate areas | Subagents or Teams |

## Sequential Pattern (Level 1)

Execute tasks one at a time on the feature branch. Report progress after each task completes. Appropriate when tasks have dependencies or touch overlapping files.

## Subagent Pattern (Level 2)

### Dispatch protocol

- Use the Agent tool with `isolation: "worktree"` for each independent task
- Each subagent receives: task description, relevant file paths, context from the plan
- Subagents work in isolated repo copies — no conflict risk during parallel execution
- When complete, subagent returns the worktree branch name

### Merge protocol

After all parallel subagents complete:

1. Merge each subagent's branch into the feature branch sequentially
2. Use `git merge <subagent-branch> --no-ff` to preserve history
3. If merge conflict → stop and ask the user
4. Run tests after merge to catch integration issues
5. Continue to the next set of tasks (or dependent tasks)

### Error handling

- Subagent fails → report which agent and what went wrong
- Do not continue to dependent tasks after a failure

## Agent Teams Pattern (Level 3)

### Team dispatch

- Use TeamCreate to create a team
- Spawn teammates with the Agent tool, each with `isolation: "worktree"`
- Assign tasks via TaskCreate/TaskUpdate
- Team lead monitors progress, merges completed branches

### Merge protocol

Same as subagent merge — sequential merge, `--no-ff`, conflict handling, post-merge tests.

### Communication

- Team lead coordinates all merges
- Teammates report completion through task updates
- All merge happens on the feature branch

## Merge Protocol Details

- Merges are always sequential into the feature branch (never merge subagent branches into each other)
- `--no-ff` preserves the branch history for traceability
- Run project tests after each merge, not just after the final one
- If tests fail after merge, the merge is the likely cause — investigate before continuing

## Transparency Requirements

Always tell the user:

- How many parallel tracks are running
- What each track is doing
- When tracks complete
- If any track fails

## Worktree Cleanup

- The Agent tool with `isolation: "worktree"` handles cleanup automatically when the subagent makes no changes
- If changes were made, the worktree persists until merged
- After merging, worktree branches can be deleted: `git branch -d <branch>`
- If cleanup fails, warn the user and suggest manual cleanup
