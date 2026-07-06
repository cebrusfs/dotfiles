---
name: jj
description: >-
  Use before editing a jj repository or rewriting its history. Covers working-copy flow, topic amendments, non-interactive commits and splits, conflict resolution, and recovery. Routine read-only probes do not require it.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj op log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*), Bash(jj squash:*), Bash(jj split:*), Bash(jj resolve:*), Bash(jj rebase:*)
---

# jj

Cross-agent topic and safety policy lives in the applicable agent instructions.
This skill owns jj-specific mechanics.

## Before editing

Run `jj st` and choose the flow:

- Empty `@`: it is already your new change. Describe it in place; do not run
  `jj new` just to start work.
- Unrelated local edits in `@`: preserve them at the leaf, then use
  `jj split <files> -m "<component>: <title>"` to put your topic below them.
- Continuing an unpushed topic: use the amendment guidance below and keep its
  existing owner.

`jj commit` leaves a fresh empty `@`; `jj split` leaves the unselected remainder.
Use `jj new` to leave a populated change behind or start from a different base.

## Routing

| Task | Reference |
|---|---|
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

For a bad distribution, use
[recovery.md](references/recovery.md#bad-review-fix-distribution).

Use `jj squash -u` / `--use-destination-message` only when the destination
description is already the right final message; it keeps the destination
description and discards the source description. If both descriptions contain
useful context, write the combined message explicitly with `-m` instead.

When several commits squash into the same ancestor, squash the one closest to
it first (bottom-most). Starting from a higher one rewrites the ancestor and
transiently conflicts everything in between; the conflicts auto-resolve as the
remaining squashes land, but the intermediate states are noisy and risky.
