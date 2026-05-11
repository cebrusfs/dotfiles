---
name: jj-general
description: "Standard operating procedure for using jj (Jujutsu) in agent-assisted development workflows. Focuses on Skeleton Planning and preemptive commit stacking."
---

# Jujutsu (jj) — Version Control for Agent Workflows

This skill defines the standard operating procedure for using `jj` (Jujutsu) as the primary local version control system. It is designed specifically for Agent workflows, prioritizing preemptive planning over retroactive fixes.

## Core Mental Model & Differences from Git

- **No staging area.** File modifications are automatically part of the current change. There is no `git add`.
- **No stash.** Just `jj new` to start fresh work; previous changes stay where they are.
- **No detached HEAD.** `jj edit` lets you jump to any change and keep working; descendants auto-rebase.
- **Branches are called bookmarks** and are only needed when interacting with a remote.
- **The working copy IS a change.** Every modification is instantly tracked.

## 🌟 Primary Agent Workflow: Skeleton Planning (Stacking Commits)

Whenever assigned a multi-step task, **ALWAYS prefer creating a skeleton plan of empty commits first**, rather than writing all code into a single monolithic commit and trying to split it later.

### 1. Draft the Plan (Create Skeleton Commits)
Before modifying any files, create a chain of empty commits representing the logical steps of your task.
```bash
jj commit -m "refactor: extract base utility"
jj commit -m "feat: implement core logic"
jj commit -m "test: add unit tests for core logic"
jj commit -m "docs: update public documentation"
```

### 2. Execute the Plan (Fill in the Commits)
Iterate through your skeleton commits and implement the code.
```bash
jj edit <first-change-id>
# ... write code for refactoring ...
# Verify tests pass

jj edit <next-change-id>
# ... write code for core logic ...
# (Previous work automatically rebases)
```

## Handling Mistakes & Complex States

- **If you make a mistake:** Use `jj undo` immediately. It is safe and reverses any `jj` operation.
- **If you forgot something in a previous commit:**
  ```bash
  jj edit <target-commit>
  # make the fix
  jj edit <back-to-latest-commit>
  ```
  *Alternatively, if you made the fix in your current working copy but it belongs to a parent commit, use `jj absorb` to automatically distribute the changes.*

- **🚨 If you created a monolithic commit and MUST split it:**
  Do NOT use interactive `jj split` (Agents cannot use TUI). Instead, **activate the `jj-split-commit` skill** for a programmatic splitting workflow.

## Essential Commands Quick Reference

- `jj log`: Show change graph + status.
- `jj diff`: Show diff of current change vs parent.
- `jj new`: Start a new empty change on top of the current one.
- `jj describe -m "..."`: Set description of current change.
- `jj edit <change>`: Jump to an existing change and continue editing it.
- `jj abandon`: Discard a change (absorbs modifications into parent).
- `jj git push --bookmark <name>`: Push specific bookmark to remote.

## 🚫 Anti-Patterns
- Do NOT use `git add`, `git commit`, `git stash`, or `git checkout`.
- Do NOT use interactive commands like `jj split` or `jj squash -i`.
