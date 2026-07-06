---
description: jj (Jujutsu) baseline rules for colocated repos
alwaysApply: true
---

# jj baseline

Claude-only amplifier. The cross-agent safety core — never `git`, the `jj git` /
`jj undo` / `jj op` bans, immutability, commit format, topic rules — lives in
`global.md` and always applies. This file adds the jj working model that must be
in context *before editing starts*; heavier recipes live in the `jj` skill.

## The invariant (derive from this; don't pattern-match recipes)
One commit = one concern, named as you make it. `@` is your local/uncommitted zone
(a leaf), never an ancestor of pushable work; private/junk is never pushed. Every
rule below just maintains this — for an uncovered case, derive from the invariant.

## Mental model
- No staging, no stash, no detached HEAD. Working copy IS a change (`@`), always tracked.
- `jj new` starts fresh work; `jj edit` moves `@`; descendants auto-rebase.
- After `jj commit`/`split`, `@` is already a fresh empty change — don't `jj new` again on an empty `@` (strands an empty).
- Never rewrite `trunk()` or any pushed/immutable commit; to build on trunk: `jj new trunk()`. Before `abandon` / `squash` / `rebase`, confirm the target is local with `jj log`.
- Do not rebase onto `trunk()` or fetch yourself; the user syncs via `jj sync`.
- Never open an interactive TUI; when unsure of a non-interactive form (`split`, `resolve`), read the `jj` skill first.

## Choosing your flow (decide BEFORE editing — first `jj st`)
- **`@` clean** → intent-first: `jj new -m "<component>: <title>"`, then edit. Work lands above; `@` stays clean for the next task.
- **`@` carries sticky local junk** (machine config, app-rewritten files) → split-down: keep junk in `@` (once: `jj describe @ -m "private: local-only"`), edit, then per task `jj split <files> -m "<component>: <title>"` to drop it BELOW `@`.
- Either way: one component per commit, land it as you finish. Never pile multiple concerns into `@` then split at the end — that's what the `jj` skill's split recipe *recovers* from, not the default.

## State exploration
- Default: `jj st` or `jj log -n 3 --no-graph -T builtin_log_oneline`
- Scoped: `jj log -r 'main..@'`

For anything heavier — skeleton stacks, commit messages, non-interactive command
forms, split, conflicts, recovery — invoke the `jj` skill.
