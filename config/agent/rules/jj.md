---
description: jj (Jujutsu) baseline rules for colocated repos
alwaysApply: true
---

# jj baseline

## Mental model (vs git)
- No staging, no stash, no detached HEAD. The working copy IS a change (`@`), always tracked.
- `jj new` starts fresh work; `jj edit` moves `@`; descendants auto-rebase.

## Hard rules
- Never run `git add`, `git commit`, `git stash` in a jj-colocated repo — they bypass jj's change tracking.
- Never invoke an interactive TUI: don't run `jj split` / `jj resolve` without flags; always pass `-m "..."` to `jj describe` / `jj commit`; bypass `jj squash`'s editor with `-m` or `--use-destination-message`.
- Never run destructive ops (`jj abandon` / `jj undo` / `jj squash` / `jj rebase`) without explicit user instruction.

## State exploration (token discipline)
- Don't run `jj show` or unbounded `jj log` blindly.
- Default probes: `jj st`, or `jj log -n 3 --no-graph -T commit_summary`.
- For tree context, scope to the base bookmark: `jj log -r 'main..@'`.

For workflow details (skeleton planning, commit messages, split, recovery), invoke the `jj` skill.
