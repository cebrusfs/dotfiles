# Splitting a jj Commit (Non-Interactive)

Use `jj restore` to populate new commits from the original — no TUI needed.

## Workflow

**1. Recon:** `jj diff --stat -r <COMMIT>` — plan logical units.

**2. Create new commits on the parent:**
```bash
jj new <PARENT> -m "Part 1: ..."
jj restore --from <COMMIT> path/to/file   # whole file
# partial: restore whole file, then revert unwanted blocks in-editor
jj new -m "Part 2: ..."
jj restore --from <COMMIT> other/file
```

**3. Verify equivalence:** `jj diff --from <COMMIT> --to @` must be empty.

**4. Cleanup:**
```bash
jj bookmark set <name> -r @   # re-point if needed
jj abandon <COMMIT>
```
