---
name: jj
description: Jujutsu (jj) version control workflows for agent use. Use this skill whenever working in a jj repository — planning multi-step implementations with skeleton commits, writing commit messages, splitting large commits, investigating workspace state, or any jj operation. Triggers when the user mentions jj commands, change IDs, bookmarks, or says "commit this", "split this commit", "describe the change", or asks how to manage history without git.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*)
---

# Jujutsu (`jj`) — Version Control for Agent Workflows

## Core Mental Model (vs Git)
- **No staging area**: Modifications are instantly part of the current change (`@`).
- **No stash**: Use `jj new` to start fresh; old work stays intact.
- **No detached HEAD**: `jj edit` moves the active working copy; descendants auto-rebase.
- **Working copy IS a change**: Always tracked.

## Constraints
- Don't use `git add`, `git commit`, or `git stash` — in a jj-colocated repo these bypass jj's change tracking and break the history model.
- Don't run `jj split` or `jj squash -i` — these require an interactive TUI that hangs the agent.

## Routing

Based on the task, read the relevant reference file. For tasks that span multiple areas, read all relevant files.

| Task | Reference file |
|---|---|
| Write / apply a commit message | `references/commit.md` |
| Split a large commit into parts | `references/split.md` |
| Plan multi-step work, skeleton commits, workspace state | `references/general.md` |
