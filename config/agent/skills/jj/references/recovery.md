# jj Recovery

## Rollback
- `jj undo` reverses the last local op. Use `jj op log -n 5` to inspect first.

## Amending an ancestor
- `jj absorb` distributes `@` changes to the nearest ancestor that touched the same lines.
- If absorb mis-routes: `jj undo`, `jj new` to isolate, redo edits, absorb again.

## Conflict resolution (no TUI)
- After a rebase: `jj resolve --list` to enumerate conflicts, edit markers in-file, then `jj squash -m "resolve conflicts"`.
- Never run bare `jj resolve` (opens TUI).

## Caution: shared/pushed changes
Before `abandon` / `squash` / `rebase` on possibly-pushed changes, run `jj log` to confirm they're local-only.
