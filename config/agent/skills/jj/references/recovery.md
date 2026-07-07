# jj Recovery

> **Purpose:** undo/repair after a mistake or resolve conflicts. **Use when** something
> went wrong — not the normal flow.

## Rollback
- `jj undo` reverses the latest operation and is itself recorded, so `jj redo`
  reverses it again. Use it when the user asks to undo, or to reverse your own
  last jj step when it went wrong: run
  `jj --at-op=@ --ignore-working-copy op log -n 5` first, confirm the operation
  is yours, and report its id. Deeper rollbacks (`jj op restore <id>`) need the
  user's explicit instruction naming the target; `jj op abandon` and
  `jj util gc` are never run by agents. `undo`, `abandon`, and `restore` are
  not pre-approved in `allowed-tools`: the shared guidance decides when a
  request authorizes them.

## Bad review-fix distribution

Inspect recent operations without snapshotting or reconciling the working copy:

```bash
jj --at-op=@ --ignore-working-copy op log -n 5
```

Inspect the pre-rewrite state with `jj --at-op=<operation-id> log` and record
its stack-tip **commit ID**.

- If content is wrong, create a clean repair at the current tip and use
  `jj restore --from <old-tip-commit-id> <paths>`. This restores file content,
  not the old graph. Inspect the diff and follow
  [amendment routing](../SKILL.md#amending-commits-in-a-stack).
- If only commit ownership is wrong, restoring content cannot fix it: `jj undo`
  your own most recent operations, or ask for a deeper rollback naming the
  target operation.

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
