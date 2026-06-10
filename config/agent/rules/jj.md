---
description: jj (Jujutsu) baseline rules for colocated repos
alwaysApply: true
---

# jj baseline

## Mental model
- No staging, no stash, no detached HEAD. Working copy IS a change (`@`), always tracked.
- `jj new` starts fresh work; `jj edit` moves `@`; descendants auto-rebase.

## Working-copy hygiene
- **Before starting:** `jj st`. If `@` already carries changes or has no description (e.g. a pre-existing working copy you didn't create), title it with `jj describe -m` or set it aside first — don't stack new commits over an undescribed `@`.
- **Don't strand empties:** after `jj commit` (or `jj describe` + `jj new`), `@` is *already* a fresh empty change. Only `jj new` when `@` has content to set aside — a `jj new` on an empty `@` just strands an empty commit. In a multi-commit sequence, let `jj commit` open the next empty `@` for you.

## Hard rules
- Never use `git add / commit / stash` — bypasses jj tracking.
- Never rewrite `trunk()` or any pushed/immutable commit (no `jj rebase`/`edit`/`describe` on them, never `--ignore-immutable`). To build on trunk: `jj new trunk()`.
- Syncing with the remote is the user's job via `jj sync` (fetch + rebase all stacks). Do **not** run `jj git fetch` or rebase onto `trunk()` yourself.
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
