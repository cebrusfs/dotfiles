---
name: gh-cli
description: Manage GitHub issues, pull requests, and metadata (labels/tags) using the `gh` CLI. Supports issue CRUD and native GitHub issue dependencies.
---

# GitHub CLI (`gh`) Issue Management Skill

> **Note on Compatibility:** This skill is built using the standard format supported by both **Gemini CLI** and **Claude Code** (`SKILL.md` with YAML frontmatter + bundled `scripts/`).

This skill provides instructions for managing GitHub issues using the `gh` CLI. It covers full CRUD operations, metadata (label) management, and handling native issue dependencies.

## Prerequisites
- Ensure `gh` is installed and authenticated (`gh auth status`).
- If `gh` is missing, inform the user to install it via [cli.github.com](https://cli.github.com/).
- **Context is Key:** Always set the repository context using `-R <owner>/<repo>` if not running inside a cloned repository.

## 1. Issue CRUD Operations

### Create an Issue
Use `gh issue create` to open a new issue.
- **Interactive prevention:** ALWAYS provide `--title` and `--body` to prevent interactive prompts which will hang the agent.
- **Example:**
  ```bash
  gh issue create -R owner/repo --title "Bug: Login fails" --body "Steps to reproduce..." --label "bug" --assignee "@me"
  ```

### List Issues
Use `gh issue list` to query issues. Use `--json` to get structured output.
- **Example:**
  ```bash
  gh issue list -R owner/repo --state open --limit 20 --json number,title,state,labels,assignees
  ```

### View an Issue
Use `gh issue view` to read issue details and comments.
- **Read body/metadata:**
  ```bash
  gh issue view 123 -R owner/repo --json title,body,state,labels
  ```

### Edit an Issue
Use `gh issue edit` to modify existing issues.
- **Example:**
  ```bash
  gh issue edit 123 -R owner/repo --title "Updated Title"
  ```

### Close/Reopen Issues
- **Close:** `gh issue close 123 -R owner/repo --reason "completed"`
- **Reopen:** `gh issue reopen 123 -R owner/repo`

## 2. Metadata Management (Labels/Tags)

Labels are used to categorize and track issues.
- **Add Labels:**
  ```bash
  gh issue edit 123 -R owner/repo --add-label "bug,high priority"
  ```
- **Remove Labels:**
  ```bash
  gh issue edit 123 -R owner/repo --remove-label "needs-triage"
  ```

## 3. Native Issue Dependencies (Blocked By / Blocking)

GitHub supports native "Issue Dependencies" via its REST API. The `gh` CLI does not yet have a native high-level command for this (tracked at [cli/cli#10298](https://github.com/cli/cli/issues/10298)).

Use the provided `gh_issue_manager.sh` wrapper script. All operations are **single-repo** (parent and blocker / child must be in the same `<owner>/<repo>` — for cross-repo cases, drop down to `gh api` directly).

**Path:** Use the absolute path to `scripts/gh_issue_manager.sh` as provided in the `<available_resources>` section by the Agent environment.

### Add a Dependency (Mark as Blocked)
```bash
<absolute-path-to-scripts/gh_issue_manager.sh> --add-dependency <owner>/<repo> <issue_num> <blocking_issue_num>
```

### Remove a Dependency
```bash
<absolute-path-to-scripts/gh_issue_manager.sh> --remove-dependency <owner>/<repo> <issue_num> <blocking_issue_num>
```

## 4. Native Sub-Issues (Parent / Child)

GitHub's native sub-issue feature (GA 2024–2025) tracks hierarchical "epic → tasks" relationships, distinct from sequential "blocked-by". Same script:

```bash
# Set CHILD as a sub-issue of PARENT
<absolute-path-to-scripts/gh_issue_manager.sh> --add-sub-issue <owner>/<repo> <parent_num> <child_num>

# Remove the relationship (does not delete either issue)
<absolute-path-to-scripts/gh_issue_manager.sh> --remove-sub-issue <owner>/<repo> <parent_num> <child_num>
```

**Constraint:** each issue has **at most one parent**. Re-parenting = remove from old parent, then add to new parent.

## 5. Reading Relationships

For inspection / project-board / agent-automation queries — read-only `gh api` one-liners (no script needed):

```bash
# What blocks this issue?
gh api repos/<owner>/<repo>/issues/<num>/dependencies/blocked_by

# Children (sub-issues) of this parent
gh api repos/<owner>/<repo>/issues/<num>/sub_issues

# Parent + sub-issues summary in one read
gh api repos/<owner>/<repo>/issues/<num> --jq '{parent: .parent.number, summary: .sub_issues_summary}'
```

## 6. GraphQL Alternative (Ad-hoc, No Script)

For one-off operations without sourcing the script (e.g. quick prototyping):

```bash
# 1. Fetch node IDs
gh api graphql -f query='{ repository(owner:"X",name:"Y"){ a:issue(number:<PARENT>){id} b:issue(number:<CHILD>){id} } }'

# 2. Mutations (parameterized inputs):
#   addBlockedBy(input:{issueId:"<BLOCKED_ID>", blockingIssueId:"<BLOCKER_ID>"})
#   addSubIssue(input:{issueId:"<PARENT_ID>", subIssueId:"<CHILD_ID>", replaceParent:true})

# 3. Read connections (always require first:/last: for paginated lists):
#   issue { parent{number}  blockedBy(first:10){nodes{number}}  subIssues(first:10){nodes{number}}  subIssuesSummary{completed total} }
```

**Quirk:** `addSubIssue` without `replaceParent:true` fails when the child already has a parent.

## Summary of Agent Protocols
1. Always use `--json` or `--jq` when fetching data (`gh issue list`, `gh issue view`) to parse results deterministically.
2. Never use `gh issue create` or `gh issue edit` without explicit `--title` and/or `--body` parameters.
3. Manage native dependencies and sub-issues using `gh_issue_manager.sh` so GitHub's UI / project boards correctly track the relationship.
4. **Don't conflate**: sub-issue is for hierarchy (epic → tasks); blocked-by is for sequential ordering. Pick the right one.
