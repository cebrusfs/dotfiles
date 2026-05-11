---
name: jj
description: Jujutsu (jj) version control workflows for agent use. Use this skill whenever working in a jj repository — planning multi-step implementations with skeleton commits, writing commit messages, splitting large commits, investigating workspace state, or any jj operation. Triggers when the user mentions jj commands, change IDs, bookmarks, or says "commit this" / "split this commit" / "describe the change" / "manage history", and also whenever the agent itself is about to run any jj command.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*)
---

# Jujutsu (`jj`) — Version Control for Agent Workflows

## Core Mental Model (vs Git)
- **No staging area**: Modifications are instantly part of the current change (`@`).
- **No stash**: Use `jj new` to start fresh; old work stays intact.
- **No detached HEAD**: `jj edit` moves the active working copy; descendants auto-rebase.
- **Working copy IS a change**: Always tracked.

## Constraints & TUI Bypasses
- Don't use `git add`, `git commit`, or `git stash` — in a jj-colocated repo these bypass jj's change tracking and break the history model.
- **NO Interactive TUI**: As an AI Agent, you CANNOT handle editor popups.
  - Never execute `jj split` or `jj resolve` interactively. (See Routing table for programmatic splitting).
  - Bypass `jj squash` editor using `-m "..."` or `--use-destination-message`.
  - Always provide `-m` to `jj describe` and `jj commit`.

## Investigating State (Token Conservation)
- **NEVER** run `jj show` or `jj log` blindly without limits.
- **ONLY** use `jj status` or `jj log -n 3 --no-graph -T commit_summary` at the start of a task, or if you suspect external changes.
- **Tree Context**: Query relative to the base bookmark (e.g., `jj log -r 'main..@'`). Keep formatting minimal if exploring depth.

## Skeleton Planning Workflow

For any multi-step assignment, stack empty commits first — this creates named checkpoints you can edit independently, so a mistake in one step doesn't tangle with others.

### Step 1: Draft the Plan (Skeleton Commits)
Create a chain of empty commits representing logical steps:
```bash
jj commit -m "refactor: extract base utility"
jj commit -m "feat: implement core logic"
jj commit -m "test: add unit tests for core logic"
```

### Step 2: Execute the Plan
Iterate through the skeleton stack to implement code:
```bash
jj edit <target-change-id>
# Implement code... verify compilation/tests
# Then move on: jj edit <next-change-id>
```
`jj edit` is the right tool here because the skeleton commits are still **empty** when you enter them. Once you've filled a commit and moved on, it's now "populated" — don't go back with `jj edit`.

### Step 3: Fixing a Populated Commit
If you need to revise an already-populated commit:
- Use `jj new <rev> -m "fixup"` and make your changes, then `jj absorb` to fold them back in.
- Avoid `jj edit` on populated commits — it repoints the working copy onto an existing change, which can silently mix new edits with old content.

### Step 4: Formatting
Before finalizing a commit, run formatting (if configured in the repo):
```bash
jj fix
```

## State Management & Recovery
- **Mistakes**: `jj undo` is safe for local rollbacks; ask the user before major structural rollbacks.
- **Amending ancestors**: Use `jj absorb` to distribute changes to the right parent automatically.

## Routing

For specialized tasks, read the relevant reference file. For tasks spanning multiple areas, read all relevant files.

| Task | Reference file |
|---|---|
| Write / apply a commit message | `references/commit.md` |
| Split a large commit into parts | `references/split.md` |
