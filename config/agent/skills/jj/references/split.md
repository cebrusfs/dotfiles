# Splitting a jj Commit (Non-Interactive)

> **Purpose:** carve an already-mixed `@` into separate commits. **Recovery path** — prefer
> committing incrementally (rules/jj.md). Use only when concerns are *already* tangled in
> one commit.

**Not this if** the parts already belong to existing ancestor commits — `jj absorb`
(recovery.md) auto-routes each hunk to the right ancestor; manual split is for carving
into *new* commits.

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

## Why sticky junk stays at the leaf (`@`), not the base
A `private:` commit can't be pushed, and jj refuses to push *any descendant* of it (pushing
a descendant would require pushing the private one). So junk parked at the base would make
all work above it unpushable. Keep junk in `@` (the leaf): it has no descendants, work
commits sit below it and don't carry it as an ancestor, so they push cleanly.
