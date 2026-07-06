---
name: jj
description: >-
  jj (Jujutsu) workflow details — skeleton planning, commit messages, diff-based split, conflict resolution, recovery. Invoke when: (a) planning a multi-step jj stack, (b) writing a commit message, (c) splitting a commit diff-selectively (no explicit file paths), (d) resolving merge conflicts without TUI, or (e) recovering from a jj mistake. Skip for routine probes or file-path-only splits.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj op log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*), Bash(jj squash:*), Bash(jj split:*), Bash(jj resolve:*), Bash(jj rebase:*)
---

# jj

Baseline (invariant, mental model, pre-edit flow choice) lives in the shared jj
rules loaded by the current environment; read those rules on demand when they
are not auto-loaded. Cross-agent safety rules live in the applicable agent
instructions. This skill covers operations needing extra recipe.

## Routing

| Task | Reference |
|---|---|
| Plan a multi-step stack (skeleton commits) | `references/skeleton.md` |
| Write / apply a commit message | `references/commit.md` |
| Split a commit non-interactively | `references/split.md` |
| Recover from a mistake / resolve conflicts | `references/recovery.md` |

## Non-interactive forms (never open a TUI)

| Command | Non-interactive form |
|---------|---------------------|
| `jj describe` | `-m "..."` for one line, or `--stdin` for a body |
| `jj commit` | `-m "..."` |
| `jj squash` | `-m "..."`; or `-u` / `--use-destination-message` only when discarding the source description is intended |
| `jj split <files>` | specify explicit file paths |
| `jj split` (diff-based) | see `references/split.md` |
| `jj resolve` | see `references/recovery.md` |

## Quick reminders
- Never rewrite commits while another process edits the same working copy or
  overlapping history; wait first. If they race, follow "Divergent change" in
  `references/recovery.md`.

## Amending commits in a stack
Mutable commits can be rewritten. For a follow-up that belongs wholly to one
known target, edit in a clean descendant and squash the change into that target.

For review fixes spanning several stack commits, decide the history shape before
rewriting:

- **Route into existing commits:** when every hunk belongs to an existing
  concern and line provenance can identify its owner, start from a clean
  descendant `@`, make the edits once, then run `jj absorb`. It routes each
  hunk to the closest mutable ancestor that last changed those lines; ambiguous
  hunks stay in the source revision. Inspect
  `jj --at-op=@ --ignore-working-copy op log -p -n 1`, and keep
  ambiguous leftovers together as one visible fixup unless ownership is proven.
- **Keep one visible fixup:** when the change is cross-cutting, ambiguous, or
  should remain independently reviewable, keep the source revision as one
  fixup at the stack tip and do not run `jj absorb`.

Do not distribute review fixes into ancestors by file path. A single file can
contain hunks owned by several commits, so path-based squashes can move later
work into an earlier concern and cascade conflicts through every descendant.
Never guess ownership from filenames.

### Recovering a bad review-fix distribution

Inspect recent operations without snapshotting or reconciling the current
working copy:

```bash
jj --at-op=@ --ignore-working-copy op log -n 5
```

Identify the operation immediately before the bad rewrite, inspect it with
`jj --at-op=<operation-id> log`, and record the old stack-tip **commit ID**:

- If current stack-tip content is missing or wrong, work from a clean repair
  change at the current stack tip and restore only the affected paths:

  ```bash
  jj restore --from <old-tip-commit-id> <paths>
  ```

  This restores file content, not the old commit graph; it does not use
  `jj op restore`. Inspect the repair diff, then follow the decision gate above.
- If final content is already correct and only commit ownership is wrong,
  restore is a no-op. Stop and ask whether to perform an authorized operation
  rollback or deliberately reconstruct the affected local stack. Never run
  `jj undo` without explicit user authorization.

Use `jj squash -u` / `--use-destination-message` only when the destination
description is already the right final message; it keeps the destination
description and discards the source description. If both descriptions contain
useful context, write the combined message explicitly with `-m` instead.

When several commits squash into the same ancestor, squash the one closest to
it first (bottom-most). Starting from a higher one rewrites the ancestor and
transiently conflicts everything in between; the conflicts auto-resolve as the
remaining squashes land, but the intermediate states are noisy and risky.
