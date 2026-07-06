---
name: jj
description: >-
  jj (Jujutsu) workflow details — skeleton planning, commit messages, diff-based split, conflict resolution, recovery. Invoke when: (a) planning a multi-step jj stack, (b) writing a commit message, (c) splitting a commit diff-selectively (no explicit file paths), (d) resolving merge conflicts without TUI, or (e) recovering from a jj mistake. Skip for routine probes or file-path-only splits.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj op log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*), Bash(jj squash:*), Bash(jj split:*), Bash(jj resolve:*), Bash(jj rebase:*)
---

# jj

Baseline (invariant, mental model, pre-edit flow choice) lives in the shared rules file `~/.dotfiles/config/agent/rules/jj.md` (also linked at `~/.claude/rules/jj.md`) — auto-loaded in Claude Code; other agents read it from that path on demand. The cross-agent safety rules live in the global instructions. This skill covers operations needing extra recipe.

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
- Never rewrite commits (`squash` / `rebase` / `absorb`) while another process or delegated agent worker is editing the same working copy — the automatic snapshot races the rewrite and produces divergent change IDs, which can drop edits from disk. Wait for the worker to finish; if it already happened, see "Divergent change" in `references/recovery.md`.

## Amending a commit in a stack
Mutable commits can be rewritten. Two ways:

- **Direct amend** (default): edit, then `jj squash` into the target. If the edits are spread across several existing stack commits, `jj absorb` auto-routes each hunk to the ancestor that last touched those lines — start work on a clean `@` so the hunks route cleanly.
- **Visible fixup** (when the amendment should stay separately reviewable — e.g. answering review on a shared commit): add a commit right after the target so its diff shows exactly what changed; squash it in once it no longer needs to be visible.

```bash
jj new --after <target> -m "<component>: fix up <target>"
# make the changes here
jj squash --from <fixup> --into <target>
```

Use `jj squash -u` / `--use-destination-message` only when the destination
description is already the right final message; it keeps the destination
description and discards the source description. If both descriptions contain
useful context, write the combined message explicitly with `-m` instead.

A→B→C becomes A→fixupA→B→fixupB→C→fixupC; squash each before finalizing.
