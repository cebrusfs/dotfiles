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

## Codex Sandbox Auth Recovery
- If `gh auth status`, any `gh ...` command, or `scripts/gh_issue.sh` fails with an invalid token, missing token, not authenticated, credential/keyring, or credential helper error, first consider whether Codex sandboxing prevented `gh` from reading the host keyring.
- In Codex, request a one-command sandbox escalation for the same necessary command instead of immediately telling the user to run `gh auth login`. Use `sandbox_permissions: "require_escalated"` with a justification such as: `gh may need host keyring access to read the GitHub token; allow running this command outside the sandbox?`
- Keep the escalation narrow: only the command needed for the user's current request, no broad `["gh"]` prefix rule. For repeated reads, prefer a subcommand prefix such as `["gh", "issue", "view"]` or `["gh", "pr", "check"]`.
- Write commands still need explicit user instruction before they are run or retried outside the sandbox.
- If the escalated retry also fails with the same auth/token error, then treat the credential as genuinely unavailable or invalid and ask the user to refresh authentication.

## Rules
- Always `--json` when reading; never omit `--title`/`--body-file` on create/edit (avoids interactive hang)
- Use `--body-file <file>` for every issue, PR, and comment body.
- Use `scripts/gh_issue.sh` for dependencies and sub-issues — `gh issue` has no native support
- Dependency and sub-issue requests must be written to GitHub issue metadata with the CLI script, not only described in the issue body, checklist, or comments.
- sub-issue = hierarchy (epic→task); blocked-by = sequential ordering. Don't conflate
- Write actions (create/edit/close/comment/label/assign, dependency changes, sub-issue changes, PR creation) still require explicit user instruction.

## Body File Hard Rule
- Never use `--body` or `-b` for GitHub writes, even for short comments.
- Never pass body text through shell heredocs, command substitution, `printf`, `echo`, or `cat` inside a `gh` command argument.
- Required pattern: write the body, comment, review, or PR text to a local file first, then pass `--body-file <file>`.
- This applies to all text-bearing writes, including `gh issue create/edit/comment`, `gh pr create/edit/comment`, and `gh pr review`.
- Keep generated body files local unless the user explicitly asks to commit them.

## CRUD

```bash
gh issue create  --title "..." --body-file <body.md> [--label "bug"] [--assignee "@me"]
gh issue list    --state open --limit 20 --json number,title,state,labels,assignees
gh issue view    123 --json title,body,state,labels
gh issue edit    123 --title "..." --body-file <body.md> --add-label "bug" --remove-label "needs-triage"
gh issue close   123 --reason completed   # or: not_planned
gh issue reopen  123
```

## Body Files

Use body files for short, long, generated, and multi-line content alike:

```bash
gh issue comment 123 --body-file <comment.md>
gh pr create --title "..." --body-file <body.md>
gh pr comment 123 --body-file <comment.md>
```

Create the body file with the normal file-writing tool available in the agent environment, then pass that path to `gh`. Keep the body file local unless the user explicitly asks to commit it.

## Extended Operations (`scripts/gh_issue.sh`)

Invoke the script from this skill's `scripts/` directory. Common installed paths:
- Claude: `~/.claude/skills/gh-cli/scripts/gh_issue.sh` (pre-approved via `allowed-tools`)
- Codex/Gemini user skills: `~/.agents/skills/gh-cli/scripts/gh_issue.sh`
- Repo skills: `.agents/skills/gh-cli/scripts/gh_issue.sh`

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

## Creating Issues With Relations

When creating tickets that have dependencies or parent/child relationships:

1. Create every needed issue with `gh issue create --title "..." --body-file <body.md>`.
2. Write relationships into GitHub metadata with `scripts/gh_issue.sh`.
3. Verify with `--relations`, `--list-blocked-by`, `--list-blocking`, or `--show-parent`.

```bash
# #12 cannot start until #7 and #9 are done.
$S --add-dependency 12 7 9

# #15 and #16 are child tasks under epic #3.
$S --add-sub-issue 3 15 16
```

Dependency direction: `--add-dependency <issue> <blocker...>` means `<issue>` is blocked by each `<blocker>`.

## Reference
Advanced filtering, jq patterns, GraphQL, PR queries: `examples/issues_metadata_examples.md`

## 🔄 Autonomous Issue Resolution Loop (Loop Engineering)
When instructed to resolve an issue, use GitHub as your state backend to maintain a transparent, resilient loop:
1. **Plan & Context**: Write the plan comment to a body file, add it with `gh issue comment <issue> --body-file <body.md>`, and mark it `in-progress` (if labels are used).
2. **Act & Verify**: Write the code and run local tests/linters.
3. **Observe & Evaluate**:
   - 🟢 **Success**: Create a PR or commit, and close the issue (`gh issue close <issue> --reason completed`).
   - 🔴 **Failure**: Document the error in a new comment to maintain a persistent history of the inner loop, and retry.
4. **🛑 Safety Brake (Escalate)**: If the exact same opaque error occurs 3 times, or you exceed 5-7 iterations without progress, stop. Comment `@user Blocked on [error]`, add a `blocked` label, and wait for human guidance.
