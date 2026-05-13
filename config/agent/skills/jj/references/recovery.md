# jj Recovery

## Local rollback
- `jj undo` is safe for the last local op. Confirm with the user before chaining multiple undos.
- `jj op log -n 5` to inspect recent operations before deciding what to undo.

## Amending an ancestor
- `jj absorb` distributes uncommitted changes in `@` to the nearest ancestor that touched the same lines — works best when `@` is clean before you started editing.
- If absorb routes incorrectly: `jj undo`, then `jj new` to isolate, redo edits, absorb again.

## Conflict resolution (no TUI)
- After a rebase produces conflicts, run `jj resolve --list` to enumerate them, then edit conflict markers in-file and `jj squash` the fix into the conflicted change with `-m`.
- Never run bare `jj resolve` (opens an editor).

## Before destructive ops
`jj abandon` / `jj squash` / `jj rebase` on shared or ancestor changes — stop and ask the user first.
