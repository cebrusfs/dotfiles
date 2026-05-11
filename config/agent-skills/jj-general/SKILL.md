---
name: jj-general
description: Provides standard operating procedures for Jujutsu (jj) version control. Guides agents to perform Skeleton Planning (stacking empty commits) for multi-step tasks.
---

# Jujutsu (`jj`) — Version Control for Agent Workflows

## Goal
Establish robust local version control habits for agents, prioritizing preemptive planning (Skeleton Planning) over retroactive, monolithic fixes.

## When to Use This Skill
Trigger this skill automatically when:
- Starting a new multi-step task or feature implementation.
- Investigating workspace state before modifying code.
- Interacting with local version history.

## Core Mental Model (vs Git)
- **No staging area**: Modifications are instantly part of the current change (`@`).
- **No stash**: Use `jj new` to start fresh; old work stays intact.
- **No detached HEAD**: `jj edit` moves the active working copy; descendants auto-rebase.
- **Working copy IS a change**: Always tracked.

## How to Use It: Skeleton Planning Workflow
For any multi-step assignment, ALWAYS stack empty commits first.

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
```
*Note: Per Global Rules, editing these specific empty skeleton commits via `jj edit` is authorized.*

### Step 3: Stack Fixups for Existing Commits
If you need to modify an existing **populated** commit (not an empty skeleton):
- ALWAYS use `jj new <rev> -m "fixup"`.
- NEVER use `jj edit` on populated non-fixup commits.

## State Management & Recovery
- **Mistakes**: Executing `jj undo` is safe but requires user permission for major structural rollbacks unless part of an automated skill cleanup.
- **Amending Parents**: If changes belong to an ancestor, use `jj absorb` to distribute them automatically.
- **Splitting**: If a monolithic commit must be split, do NOT use interactive `jj split`. Activate the **`jj-split-commit`** skill instead.

## Critical Constraints
- **NO Git Commands**: Never use `git add`, `git commit`, `git stash`.
- **NO Interactive TUI**: Never execute `jj split` or `jj squash -i`.
