---
name: jj-split-commit
description: "Programmatic workflow for splitting a large jj commit into multiple smaller, testable commits without using interactive TUI."
---

# Splitting a Jujutsu (jj) Commit (Agent-Safe Workflow)

This skill provides a programmatic method to split a monolithic commit into multiple logical units. Since Agents cannot interact with the `jj split -i` TUI, this workflow uses `jj restore` and precise file editing.

## 1. Prerequisites & Planning
- Identify the target `COMMIT_TO_SPLIT` and its `PARENT_COMMIT`.
- Run `jj diff --stat -r <COMMIT_TO_SPLIT>` to see all modified files.
- Plan the logical split units (e.g., "Refactor", "Feature", "Tests").

## 2. Decomposition Cycle (Execution)
For each logical unit in order:

### Step A: Initialize
Start a new commit on top of the parent.
- For Unit 1: `jj new <PARENT_COMMIT> -m "Part 1: Refactor"`
- For Unit N: `jj new -m "Part N: Feature"`

### Step B: Populate (Whole Files)
If entire files belong to this unit:
```bash
jj restore --from <COMMIT_TO_SPLIT> path/to/file1 path/to/file2
```

### Step C: Populate (Partial Files)
If only parts of a file belong to this unit:
1. Restore the entire file from the future: `jj restore --from <COMMIT_TO_SPLIT> path/to/file`
2. **Reverse Edit**: Use editing tools (like `replace`) to manually revert the code blocks that *do not* belong to this specific unit yet.

### Step D: Validate
Run the project's test suite (e.g., `make test`, `npm test`) to ensure this unit is independently valid.

## 3. Final Validation
After creating all split commits, verify the final state matches the original:
```bash
jj diff --from <COMMIT_TO_SPLIT> --to @
```
**Success Condition:** The output should be empty. If there are accidental changes, fix them and use `jj absorb` to distribute the fixes.

## 4. Branch Update (Git Backend)
If the original commit was a Git branch, move the bookmark to the new tip:
```bash
jj bookmark set <branch_name> -r @
jj abandon <ORIGINAL_MONOLITHIC_COMMIT>
```

## Quick Reference
- `jj restore --from <REV> <PATH>`: Pull file state from a specific revision.
- `jj diff --from <REV1> --to <REV2>`: Compare two states.
- `jj absorb`: Automatically distribute current changes to their origins.
