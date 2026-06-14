---
name: gh-cli
description: >-
  Manage GitHub issues using `gh` CLI — CRUD, labels, native dependencies, sub-issues. Use this skill whenever you need to create, list, view, close, or manage GitHub issues, track task dependencies, manage epics, or link parent/child issues — even if the user just says "create a task", "what's blocking this", or "show me open issues".
allowed-tools: Bash(gh:*) Bash(~/.claude/skills/gh-cli/scripts/gh_issue.sh:*)
---

# gh-cli

## Prerequisites
- `gh auth status` — must be authenticated
- Run from inside the repository (scripts use `{owner}/{repo}` context)

## Rules
- Always `--json` when reading; never omit `--title`/`--body` on create/edit (avoids interactive hang)
- Use `scripts/gh_issue.sh` for dependencies and sub-issues — `gh issue` has no native support
- sub-issue = hierarchy (epic→task); blocked-by = sequential ordering. Don't conflate
- Write actions (create/edit/close/comment/label/assign, dependency changes, sub-issue changes, PR creation) still require explicit user instruction.

## CRUD

```bash
gh issue create  --title "..." --body "..." [--label "bug"] [--assignee "@me"]
gh issue list    --state open --limit 20 --json number,title,state,labels,assignees
gh issue view    123 --json title,body,state,labels
gh issue edit    123 --title "..." --add-label "bug" --remove-label "needs-triage"
gh issue close   123 --reason completed   # or: not_planned
gh issue reopen  123
```

## Extended Operations (`scripts/gh_issue.sh`)

Invoke the script from this skill's `scripts/` directory. Common installed paths:
- Claude: `~/.claude/skills/gh-cli/scripts/gh_issue.sh` (pre-approved via `allowed-tools`)
- Codex user skills: `~/.agents/skills/gh-cli/scripts/gh_issue.sh`
- Codex repo skills: `.agents/skills/gh-cli/scripts/gh_issue.sh`

```bash
S=~/.agents/skills/gh-cli/scripts/gh_issue.sh

# Full thread dump — body + all comments, multiple issues in one GraphQL call
$S --dump  <issue_num...>

# JSON reads
$S --list-blocked-by   <issue>          # → [{number,title,state}]
$S --list-blocking     <issue>          # → [{number,title,state}]
$S --list-sub-issues   <issue>          # → [{number,title,state}]
$S --show-parent       <issue>          # → {parent, sub_issues_summary}

# Rich multi-issue view (single GraphQL call)
$S --relations  <issue_num...>          # parent/sub-issues/blockedBy
$S --report     [limit=20]              # compact: "#N [STATE] title [labels]"
$S --report     [limit=20] --human      # Markdown table (for display to user)

# Writes (support multiple targets)
$S --add-dependency    <issue> <blocker...>
$S --remove-dependency <issue> <blocker...>
$S --add-sub-issue     <parent> <child...>
$S --remove-sub-issue  <parent> <child...>
```

Each issue has at most one parent. Re-parent = remove old, then add new.

## Reference
Advanced filtering, jq patterns, GraphQL, PR queries: `examples/issues_metadata_examples.md`

## 🔄 Autonomous Issue Resolution Loop (Loop Engineering)
When instructed to resolve an issue, use GitHub as your state backend to maintain a transparent, resilient loop:
1. **Plan & Context**: Add a comment (`gh issue comment <issue> --body "Starting work. Plan: ..."`) and mark it `in-progress` (if labels are used).
2. **Act & Verify**: Write the code and run local tests/linters.
3. **Observe & Evaluate**:
   - 🟢 **Success**: Create a PR or commit, and close the issue (`gh issue close <issue> --reason completed`).
   - 🔴 **Failure**: Document the error in a new comment to maintain a persistent history of the inner loop, and retry.
4. **🛑 Safety Brake (Escalate)**: If the exact same opaque error occurs 3 times, or you exceed 5-7 iterations without progress, stop. Comment `@user Blocked on [error]`, add a `blocked` label, and wait for human guidance.
