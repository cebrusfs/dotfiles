# jj Recovery

> **Purpose:** undo/repair after a mistake or resolve conflicts. **Use when** something
> went wrong — not the normal flow.

## Rollback
- `jj undo` is gated: run it only when the user explicitly asked for an
  operation rollback. Without that ask, stop after `jj op log -n 5` and present
  findings. The skill's allowed-tools listing `jj undo` is capability, not
  permission.

## Amending an ancestor
- `jj absorb` distributes `@` changes to the nearest ancestor that touched the same lines.
- If absorb mis-routes, that is an undo-shaped situation: show `jj op log -n 5`
  and ask before `jj undo`; then `jj new` to isolate, redo edits, absorb again.

## Conflict resolution (no TUI)
- After a rebase: `jj resolve --list` to enumerate conflicts, edit markers in-file, then `jj squash -m "resolve conflicts"`.
- Never run bare `jj resolve` (opens TUI).

## Divergent change (one change ID, multiple visible commits)
Cause: a commit was rewritten (`squash`/`rebase`) while something else — another
process or a delegated agent worker — modified the working copy, so the
automatic snapshot raced the rewrite. `jj log` marks the change `??`; siblings
are addressed as `<change>/0`, `<change>/1`, …

1. `jj log` to list the siblings and diff them; pick the survivor (usually the one containing the edits you want to keep).
2. If wanted files vanished from disk, `jj restore --from '<change>/<n>' <files>` to pull that version back into `@`.
3. `jj abandon <commit-id>` the stale sibling — target it by **commit ID**, not the (ambiguous) change ID.
4. Redo the interrupted rewrite.

## Caution: shared/pushed changes
Before `abandon` / `squash` / `rebase`, confirm the target is local with
`jj log`; follow the applicable version-control safeguards and immutability
limits.
