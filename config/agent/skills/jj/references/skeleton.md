# Skeleton Planning

> **Purpose:** stack named empty commits up front when the steps are known, so each lands
> isolated. **Use when** `@` is clean and the work is a known multi-step sequence.
> **Don't** use with sticky junk in `@` (rules/jj.md → split-down).

Stack empty commits first — creates named checkpoints you can edit independently.
Deliberately creating empties here is the exception to the baseline "don't strand empties"
rule — you fill them in the next step.

## Steps

**1. Draft skeleton** (use the project's `<component>:` message style, not feat/refactor/test):
```bash
jj commit -m "config: extract shared helper"
jj commit -m "zsh: wire helper into prompt"
jj commit -m "ci: cover the helper"
```

**2. Fill each commit:**
```bash
jj edit <change-id>   # move to empty commit, implement, verify
```

**3. Amend a populated commit:**
Use `jj new <rev> -m "fixup"` + `jj absorb` — don't `jj edit` populated commits (silently mixes new edits with old content).

**4. Format:** `jj fix` before finalizing.
