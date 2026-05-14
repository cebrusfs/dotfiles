# Skeleton Planning

Stack empty commits first — creates named checkpoints you can edit independently.

## Steps

**1. Draft skeleton:**
```bash
jj commit -m "refactor: extract utility"
jj commit -m "feat: implement core"
jj commit -m "test: unit tests"
```

**2. Fill each commit:**
```bash
jj edit <change-id>   # move to empty commit, implement, verify
```

**3. Amend a populated commit:**
Use `jj new <rev> -m "fixup"` + `jj absorb` — don't `jj edit` populated commits (silently mixes new edits with old content).

**4. Format:** `jj fix` before finalizing.
