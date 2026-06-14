---
name: jj
description: >-
  jj (Jujutsu) workflow details — skeleton planning, commit messages, diff-based split, conflict resolution, recovery. Invoke when: (a) planning a multi-step jj stack, (b) writing a commit message, (c) splitting a commit diff-selectively (no explicit file paths), (d) resolving merge conflicts without TUI, or (e) recovering from a jj mistake. Skip for routine probes or file-path-only splits.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*), Bash(jj squash:*), Bash(jj split:*), Bash(jj resolve:*), Bash(jj rebase:*)
---

# jj

Baseline rules (mental model, non-interactive requirements, state-exploration) live in the shared rules file (`config/agent/rules/jj.md` in this repo; `~/.claude/rules/jj.md` when installed for Claude) and always apply. This skill covers operations needing extra recipe.

## Routing

| Task | Reference |
|---|---|
| Plan a multi-step stack (skeleton commits) | `references/skeleton.md` |
| Write / apply a commit message | `references/commit.md` |
| Split a commit non-interactively | `references/split.md` |
| Recover from a mistake / resolve conflicts | `references/recovery.md` |

## Quick reminders
- Baseline (mental model, hard rules, flow choice) is always-on in `rules/jj.md`; this skill holds the heavier recipes.

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
