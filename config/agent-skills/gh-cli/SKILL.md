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

GitHub supports native "Issue Dependencies" via its REST API. Currently, the `gh` CLI does not have a native high-level command for this (tracked at [cli/cli#10298](https://github.com/cli/cli/issues/10298)).

You **must** use the provided `gh_issue_manager.sh` script, which wraps the GitHub REST API.

**Path:** Use the absolute path to `scripts/gh_issue_manager.sh` as provided in the `<available_resources>` section by the Agent environment.

### Add a Dependency (Mark as Blocked)
To mark `ISSUE_NUM` as being blocked by `BLOCKING_ISSUE_NUM`:
```bash
<absolute-path-to-scripts/gh_issue_manager.sh> --add-dependency <owner>/<repo> <issue_num> <blocking_repo> <blocking_issue_num>
```

### Remove a Dependency
```bash
<absolute-path-to-scripts/gh_issue_manager.sh> --remove-dependency <owner>/<repo> <issue_num> <blocking_repo> <blocking_issue_num>
```

## Summary of Agent Protocols
1. Always use `--json` or `--jq` when fetching data (`gh issue list`, `gh issue view`) to parse results deterministically.
2. Never use `gh issue create` or `gh issue edit` without explicit `--title` and/or `--body` parameters.
3. Manage native dependencies using `gh_issue_manager.sh` to ensure GitHub's UI correctly tracks the blockings.
