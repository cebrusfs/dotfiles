# Splitting a jj Commit (Agent-Safe Workflow)

Decompose a monolithic commit into smaller, independently verifiable commits programmatically — bypassing `jj split -i` which requires an interactive TUI.

The approach: create new empty commits on top of the parent, then selectively restore files from the original commit into each one. This gives full control over which changes land in which commit without any interactive editor.

## Step 1: Reconnaissance
Identify `COMMIT_TO_SPLIT` and `PARENT_COMMIT`.
```bash
jj diff --stat -r <COMMIT_TO_SPLIT>
```
Plan logical units (e.g., Unit 1: Refactor, Unit 2: Feature).

## Step 2: Stack Logical Units
Iterate through each planned unit sequentially:

### A. Initialize Unit
```bash
jj new <PARENT_COMMIT> -m "Part 1: <Unit Name>"
```
*(Subsequent units build on top using `jj new -m "Part N: ..."`)*

### B. Populate Content
- **Whole files**: `jj restore --from <COMMIT_TO_SPLIT> path/to/file`
- **Partial files**: Restore the whole file first, then revert unwanted blocks using file replacement tools.

### C. Validate Unit
Verify build/tests pass for this isolated commit before moving to the next unit.

## Step 3: Final Integrity Check
Compare the final stacked state against the original:
```bash
jj diff --from <COMMIT_TO_SPLIT> --to @
```
- **Success**: Output must be completely empty.
- **Resolution**: If discrepancies exist, fix them and use `jj absorb`.

## Step 4: Cleanup
Once full equivalence is verified, abandon the original — its content is fully preserved in the new commits:
```bash
# Re-point bookmarks if applicable:
jj bookmark set <bookmark_name> -r @

# Abandon the old monolithic duplicate:
jj abandon <COMMIT_TO_SPLIT>
```
