---
name: gh-cli
description: Manage GitHub issues using `gh` CLI — CRUD, labels, native dependencies, sub-issues. Use this skill whenever you need to create, list, view, close, or manage GitHub issues, track task dependencies, manage epics, or link parent/child issues — even if the user just says "create a task", "what's blocking this", or "show me open issues".
---

# gh-cli

## Prerequisites
- `gh auth status` — must be authenticated
- Run from inside the repository (scripts use `{owner}/{repo}` context)

## Rules
- Always `--json` when reading; never omit `--title`/`--body` on create/edit (avoids interactive hang)
- Use `gh_issue_manager.sh` for dependencies and sub-issues — `gh issue` has no native support
- sub-issue = hierarchy (epic→task); blocked-by = sequential ordering. Don't conflate

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

```bash
# Full thread dump — body + all comments, multiple issues in one GraphQL call
<script> --dump  <issue_num...>

# JSON reads
<script> --list-blocked-by   <issue>          # → [{number,title,state}]
<script> --list-blocking     <issue>          # → [{number,title,state}]
<script> --list-sub-issues   <issue>          # → [{number,title,state}]
<script> --show-parent       <issue>          # → {parent, sub_issues_summary}

# Rich multi-issue view (single GraphQL call)
<script> --relations  <issue_num...>          # parent/sub-issues/blockedBy
<script> --report     [limit=20]              # Markdown summary table

# Writes (support multiple targets)
<script> --add-dependency    <issue> <blocker...>
<script> --remove-dependency <issue> <blocker...>
<script> --add-sub-issue     <parent> <child...>
<script> --remove-sub-issue  <parent> <child...>
```

Each issue has at most one parent. Re-parent = remove old, then add new.

## Reference
Advanced filtering, jq patterns, GraphQL, PR queries: `examples/issues_metadata_examples.md`
