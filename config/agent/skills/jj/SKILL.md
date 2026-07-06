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

## Amending a commit in a stack
Mutable commits can be rewritten. Two ways:

- **Direct amend** (default): edit, then `jj squash` into the target. If the edits are spread across several existing stack commits, `jj absorb` auto-routes each hunk to the ancestor that last touched those lines — start work on a clean `@` so the hunks route cleanly.
- **Visible fixup** (when the amendment should stay separately reviewable — e.g. answering review on a shared commit): add a commit right after the target so its diff shows exactly what changed; squash it in once it no longer needs to be visible.

```bash
jj new --after <target> -m "<component>: fix up <target>"
# make the changes here
jj squash --from <fixup> --into <target>
```

A→B→C becomes A→fixupA→B→fixupB→C→fixupC; squash each before finalizing.

Use `jj squash -u` / `--use-destination-message` only when the destination
description is already the right final message; it keeps the destination
description and discards the source description. If both descriptions contain
useful context, write the combined message explicitly with `-m` instead.

When several commits squash into the same ancestor, squash the one closest to
it first (bottom-most). Starting from a higher one rewrites the ancestor and
transiently conflicts everything in between; the conflicts auto-resolve as the
remaining squashes land, but the intermediate states are noisy and risky.
