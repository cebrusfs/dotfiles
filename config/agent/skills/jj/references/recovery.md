# jj Recovery

> **Purpose:** undo/repair after a mistake or resolve conflicts. **Use when** something
> went wrong — not the normal flow.

## Rollback
- `jj undo` is gated: run it only when the user explicitly asked for an
  operation rollback. Without that ask, stop after
  `jj --at-op=@ --ignore-working-copy op log -n 5` and present findings. The
  skill's allowed-tools listing `jj undo` is capability, not permission.

## Amending an ancestor
- `jj absorb` distributes `@` changes to the nearest ancestor that touched the same lines.
- If absorb mis-routes, that is an undo-shaped situation: show
  `jj --at-op=@ --ignore-working-copy op log -n 5` and ask before `jj undo`;
  then `jj new` to isolate, redo edits, absorb again.

## Conflict resolution (non-interactive)
- Use `jj resolve --list` to enumerate conflicts. In jj 0.45.1 (verified
  2026-10-08), exit 2 with `No conflicts found at this revision` means clear;
  inspect the diagnostic rather than treating every nonzero exit as a conflict.
- Compare both sides with their common base and owning commits before editing.
  Re-evaluate the merged intent; preserve compatible changes and ask when a
  material semantic choice remains.
- For an inherited conflict, create a clean repair with
  `jj new <first-conflicted-change>`, preserving any populated local-only tip.
  Edit the conflicted paths, verify the result, and move only the repair into
  its proven owner with `jj squash --from <repair-change> --into <owner-change>`.
  Use `--use-destination-message` when that topic description still fits.
  Do not squash a populated working-copy topic wholesale just to remove markers.
- Never run bare `jj resolve`; it launches the configured interactive external
  merge tool.

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
