---
name: gh-cli
description: Manage GitHub issues using native commands and a specialized wrapper for complex relationships (Sub-issues, Dependencies).
---

# GitHub CLI (`gh`) Issue Management Skill

This skill provides a tiered approach to managing GitHub issues, ensuring stability and eliminating API/`jq` trial-and-error.

## Execution Tiers (Decision Logic)

### Tier 1: Simple Operations & Reporting
For basic CRUD, use native `gh` commands directly.
*   **Create/Edit/Close/Reopen**: Always use `gh issue`.
*   **List/Report**: Use the wrapper's `--report` command as your default way to view recent issues, as it provides a clean Markdown table with states and labels.
*   **CRITICAL CONSTRAINT**: NEVER execute `gh issue create` or `gh issue edit` without both `--title` and `--body`. This prevents interactive prompts that will hang the session.

### Tier 2: Relationship Management (The Wrapper)
For any task involving **Parent/Child (Sub-issues)** or **Blocked-by (Dependencies)**, you **MUST** use the provided wrapper script.
*   **Path**: `scripts/gh_issue_manager.sh`
*   **Why**: Native `gh` does not support relationship writing. The API requires mapping standard Issue Numbers to internal GraphQL Node IDs. The wrapper completely hides this complexity and supports batch operations.

**Commands**:
```bash
# Generate a general Markdown report of recent issues (default 20):
./scripts/gh_issue_manager.sh --report [limit]

# Fetch relationships (Parent, Sub-issues, Blockers) for ONE or MORE issues:
./scripts/gh_issue_manager.sh --relations <issue_1> [issue_2...]

# Manage Relationships (supports adding/removing MULTIPLE targets at once):
./scripts/gh_issue_manager.sh --add-dependency <issue_num> <blocker_1> [blocker_2...]
./scripts/gh_issue_manager.sh --remove-dependency <issue_num> <blocker_1> [blocker_2...]
./scripts/gh_issue_manager.sh --add-sub-issue <parent_num> <child_1> [child_2...]
./scripts/gh_issue_manager.sh --remove-sub-issue <parent_num> <child_1> [child_2...]
```

### Tier 3: Advanced Reporting (The Cookbook)
If Tier 1 and Tier 2 cannot satisfy a complex query (e.g., "List all issues with X label formatted as a TSV"), **ONLY THEN** read the example file:
*   **File**: `examples/issues_metadata_examples.md`
*   **Instruction**: Do not read this file during initial exploration. Access it only when a custom, high-complexity `jq` query is required.

## Standard Workflows

### 1. Investigating Issue Status
1. Run `./scripts/gh_issue_manager.sh --report 10` to see recent issues.
2. Run `./scripts/gh_issue_manager.sh --relations <num>` to see blockers/children for a specific issue.
3. Synthesize the status for the user.

### 2. Creating an Epic with Tasks
1. Create the Parent: `gh issue create --title "Epic: ..." --body "..."`
2. Create Children: `gh issue create --title "Task: ..." --body "..."`
3. Link them in one shot: `./scripts/gh_issue_manager.sh --add-sub-issue <parent_id> <child_1_id> <child_2_id>`

## Agent Protocols
1. **Single Repo Assumption**: Most operations occur in the local repository. The wrapper automatically detects the repo context.
2. **JQ Ban**: Do not attempt to write complex `jq` filters from memory. Use `--report` for tables, `--relations` for hierarchies, or the Tier 3 cookbook for custom logic.
3. **Non-Interactive**: Always use flags to provide all required inputs.
