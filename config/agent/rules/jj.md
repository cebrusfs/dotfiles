---
description: jj (Jujutsu) baseline rules for colocated repos
alwaysApply: true
---

# jj baseline

## Mental model
- No staging, no stash, no detached HEAD. Working copy IS a change (`@`), always tracked.
- `jj new` starts fresh work; `jj edit` moves `@`; descendants auto-rebase.

## Hard rules
- Never use `git add / commit / stash` — bypasses jj tracking.
- Every command must be non-blocking — never open an interactive TUI:

| Command | Non-interactive form |
|---------|---------------------|
| `jj describe` / `jj commit` | `-m "..."` |
| `jj squash` | `-m "..."` or `--use-destination-message` |
| `jj split <files>` | specify explicit file paths |
| `jj split` (diff-based) | read `/jj` skill first |
| `jj resolve` | read `/jj` skill first |

## State exploration
- Default: `jj st` or `jj log -n 3 --no-graph -T commit_summary`
- Scoped: `jj log -r 'main..@'`

For workflow details (skeleton, commit messages, split, recovery), invoke the `jj` skill.
