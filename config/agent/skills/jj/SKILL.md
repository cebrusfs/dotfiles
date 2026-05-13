---
name: jj
description: jj (Jujutsu) workflow details — skeleton planning for multi-step work, commit message drafting, splitting a commit, recovery from mistakes. Invoke only when about to (a) plan a multi-step implementation in jj, (b) write a commit message via `jj describe` / `jj commit`, (c) split or restructure a commit, or (d) recover from a jj mistake. Do NOT invoke for routine `jj st` / `jj log` probes — baseline rules already cover those.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*)
---

# jj

Baseline rules (mental model, TUI bypasses, state-exploration token discipline) live in `~/.claude/rules/jj.md` and always apply. This skill only covers operations that need extra recipe.

## Routing

| Task | Reference |
|---|---|
| Plan a multi-step assignment (stack empty commits first) | `references/skeleton.md` |
| Write / apply a commit message (`jj describe` / `jj commit`) | `references/commit.md` |
| Split a large commit into parts (non-interactive) | `references/split.md` |
| Recover from a mistake (undo, absorb into ancestor) | `references/recovery.md` |

## Quick reminders
- Before edits: `jj new` on a clean `@` so `jj absorb` can route changes correctly later.
- Stage by naming files explicitly — colocated jj auto-tracks per `.gitignore`; `git add .` is forbidden.
- If a command would touch history (`abandon` / `squash` / `rebase` / `undo` on shared work), stop and ask the user first.
