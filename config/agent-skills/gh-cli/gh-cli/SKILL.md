---
name: gh-cli
description: Manage GitHub issues using `gh` CLI — CRUD, labels, native dependencies, sub-issues.
---

# gh-cli

## Prerequisites
- `gh auth status` — must be authenticated
- Always pass `-R <owner>/<repo>` when not inside the repo

## Rules
- Always `--json` when reading; never omit `--title`/`--body` on create/edit (avoids interactive hang)
- Use `gh_issue_manager.sh` for dependencies and sub-issues — `gh issue` has no native support
- sub-issue = hierarchy (epic→task); blocked-by = sequential ordering. Don't conflate

## CRUD

```bash
gh issue create  -R repo --title "..." --body "..." [--label "bug"] [--assignee "@me"]
gh issue list    -R repo --state open --limit 20 --json number,title,state,labels,assignees
gh issue view    123 -R repo --json title,body,state,labels
gh issue edit    123 -R repo --title "..." --add-label "bug" --remove-label "needs-triage"
gh issue close   123 -R repo --reason completed   # or: not_planned
gh issue reopen  123 -R repo
```

## Dependencies & Sub-issues (`gh_issue_manager.sh`)

```bash
# Blocked-by
<script> --add-dependency    <repo> <issue> <blocker>
<script> --remove-dependency <repo> <issue> <blocker>
<script> --list-blocked-by   <repo> <issue>          # → [{number,title,state}]
<script> --list-blocking     <repo> <issue>           # → [{number,title,state}]

# Sub-issues (hierarchy)
<script> --add-sub-issue     <repo> <parent> <child>
<script> --remove-sub-issue  <repo> <parent> <child>
<script> --list-sub-issues   <repo> <issue>           # → [{number,title,state}]
<script> --show-parent       <repo> <issue>           # → {parent, sub_issues_summary}
```

Each issue has at most one parent. Re-parent = remove old, then add new.

## Reference
Advanced filtering, jq patterns, GraphQL: `examples/issues_metadata_examples.md`
