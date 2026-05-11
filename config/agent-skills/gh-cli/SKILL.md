---
name: gh-cli
description: Manages GitHub issues, sub-issues, and dependencies using native commands and specialized wrapper scripts. Triggers on task creation, epic breakdown, or dependency tracking.
---

# GitHub CLI (`gh`) Issue Management Skill

## Goal
Provide a stable, tiered approach to managing GitHub issues, eliminating API/`jq` trial-and-error by leveraging native commands and custom relationship wrappers.

## When to Use This Skill
Trigger this skill automatically when the user requests to:
- Investigate GitHub issue status, labels, or recent activities.
- Create new tasks, epics, or sub-issues.
- Link issues with Parent/Child (Sub-issue) or Blocked-by (Dependency) relationships.

## How to Use It (Execution Tiers)

### Tier 1: Simple Operations & Reporting
For basic CRUD, use native `gh` commands directly.
- **Create/Edit/Close/Reopen**: Always use `gh issue`.
- **List/Report**: Prefer `./scripts/gh_issue_manager.sh --report [limit]` to generate clean Markdown tables.
- **CRITICAL CONSTRAINT**: NEVER execute `gh issue create` or `gh issue edit` without both `--title` and `--body` to prevent interactive prompt hangs.

### Tier 2: Relationship Management (The Wrapper)
For tasks involving **Parent/Child** or **Blocked-by** logic, you MUST use the wrapper script.
- **Path**: `scripts/gh_issue_manager.sh`
- **Guidance**: Always run `./scripts/gh_issue_manager.sh --help` first if unsure about syntax.

**Common Patterns**:
```bash
# Fetch relationships for specific issues:
./scripts/gh_issue_manager.sh --relations <issue_1> [issue_2...]

# Manage dependencies (supports batch target IDs):
./scripts/gh_issue_manager.sh --add-dependency <issue_num> <blocker_1> [blocker_2...]
./scripts/gh_issue_manager.sh --add-sub-issue <parent_num> <child_1> [child_2...]
```

### Tier 3: Advanced Custom Reporting
If Tiers 1 and 2 cannot satisfy complex queries (e.g., custom TSV output):
- Reference `examples/issues_metadata_examples.md` for pre-validated `jq` recipes.
- **Constraint**: Do NOT read this file during initial exploration; access only when strictly necessary.

## Standard Workflows

### Scenario A: Investigating Issue Status
1. Run `./scripts/gh_issue_manager.sh --report 10` to overview context.
2. Run `./scripts/gh_issue_manager.sh --relations <num>` to check specific blockers.

### Scenario B: Creating an Epic with Tasks
1. Create Parent: `gh issue create --title "Epic: ..." --body "..."`
2. Create Children: `gh issue create --title "Task: ..." --body "..."`
3. Link immediately: `./scripts/gh_issue_manager.sh --add-sub-issue <parent_id> <child_1_id> <child_2_id>`

## Agent Protocols
- **Single Repo Context**: Assume operations target the local repository context.
- **No Raw JQ Filters**: Do not write raw `jq` queries from memory; rely on wrappers or cookbooks.
- **Non-Interactive Enforcement**: Always supply necessary flags to bypass TUI prompts.
