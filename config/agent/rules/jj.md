---
description: jj (Jujutsu) baseline rules for colocated repos
alwaysApply: true
---

# jj baseline

## The invariant (derive from this; don't pattern-match recipes)
One commit = one concern, named as you make it. `@` is your local/uncommitted zone
(a leaf), never an ancestor of pushable work; private/junk is never pushed. Every
command below just maintains this — for an uncovered case, derive from the invariant.

## Mental model
- No staging, no stash, no detached HEAD. Working copy IS a change (`@`), always tracked.
- `jj new` starts fresh work; `jj edit` moves `@`; descendants auto-rebase.
- After `jj commit`/`split`, `@` is already a fresh empty change — don't `jj new` again on an empty `@` (strands an empty).

## Choosing your flow (decide BEFORE editing — first `jj st`)
- **`@` clean** → intent-first: `jj new -m "<component>: <intent>"`, then edit. Work lands above; `@` stays clean for the next task.
- **`@` carries sticky local junk** (machine config, app-rewritten files) → split-down: keep junk in `@` (once: `jj describe @ -m "private: local-only"`), edit, then per task `jj split <files> -m "<component>: ..."` to drop it BELOW `@`.
- Either way: one component per commit, land it as you finish. Never pile multiple concerns into `@` then split at the end — that's what `/jj` split.md *recovers* from, not the default.

## Hard rules
- Never use `git add / commit / stash` — bypasses jj tracking.
- Never rewrite `trunk()` or any pushed/immutable commit (no `jj rebase`/`edit`/`describe` on them, never `--ignore-immutable`). To build on trunk: `jj new trunk()`.
- Before `abandon` / `squash` / `rebase`, confirm the target is local with `jj log` (single source for this check — references point here).
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
- Default: `jj st` or `jj log -n 3 --no-graph -T builtin_log_oneline`
- Scoped: `jj log -r 'main..@'`

## Agent workspaces
- Claude isolated workspaces use `config/agent/claude/settings.json` hooks, which create and
  remove jj workspaces under `.claude/worktrees/`.
- Do not assume Codex App worktrees are jj workspaces. For Codex + jj isolation,
  create/select a jj workspace manually and start Codex in that directory.

For workflow details (skeleton, commit messages, amend/fixup, split, recovery), invoke the `jj` skill.
