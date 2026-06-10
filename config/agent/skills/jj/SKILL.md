---
name: jj
description: jj (Jujutsu) workflow details — skeleton planning, commit messages, diff-based split, conflict resolution, recovery. Invoke when: (a) planning a multi-step jj stack, (b) writing a commit message, (c) splitting a commit diff-selectively (no explicit file paths), (d) resolving merge conflicts without TUI, or (e) recovering from a jj mistake. Skip for routine probes or file-path-only splits.
allowed-tools: Bash(jj diff:*), Bash(jj st:*), Bash(jj log:*), Bash(jj describe:*), Bash(jj commit:*), Bash(jj edit:*), Bash(jj new:*), Bash(jj absorb:*), Bash(jj undo:*), Bash(jj restore:*), Bash(jj bookmark:*), Bash(jj abandon:*), Bash(jj fix:*), Bash(jj squash:*), Bash(jj split:*), Bash(jj resolve:*), Bash(jj rebase:*)
---

# jj

Baseline rules (mental model, non-interactive requirements, state-exploration) live in `~/.claude/rules/jj.md` and always apply. This skill covers operations needing extra recipe.

## Routing

| Task | Reference |
|---|---|
| Plan a multi-step stack (skeleton commits) | `references/skeleton.md` |
| Write / apply a commit message | `references/commit.md` |
| Split a commit non-interactively | `references/split.md` |
| Recover from a mistake / resolve conflicts | `references/recovery.md` |

## Quick reminders
- `jj new` on a clean `@` before edits so `jj absorb` can route changes correctly later.
- For `abandon` / `squash` / `rebase` on shared/pushed changes, verify target is local with `jj log` first.

## 🔄 Autonomous Fixup Loop (Loop Engineering)
Instead of waiting for human verification after every minor code change, execute an autonomous loop:
1. **Act**: Run `jj new -m "fixup"` to create an isolated checkpoint, then apply your code changes.
2. **Verify**: Run the project's build/test command.
3. **Evaluate**:
   - 🟢 **Pass**: `jj squash` the fixup(s) into the target commit to keep history clean.
   - 🔴 **Fail**: Read the error. DO NOT destroy the commit. Create another `jj new -m "fixup"` to try an alternative approach. This shows progress over counting.
4. **🛑 Safety Brake**: If you stack >5 fixup commits without resolving the test failure, stop and ask the user for guidance. Your fixup history will serve as the "dev journal" for the human to review.
