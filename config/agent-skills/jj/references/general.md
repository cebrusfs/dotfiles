# jj General Workflow — Skeleton Planning

## Skeleton Planning Workflow

For any multi-step assignment, stack empty commits first — this creates named checkpoints you can edit independently, so a mistake in one step doesn't tangle with others.

### Step 1: Draft the Plan (Skeleton Commits)
Create a chain of empty commits representing logical steps:
```bash
jj commit -m "refactor: extract base utility"
jj commit -m "feat: implement core logic"
jj commit -m "test: add unit tests for core logic"
```

### Step 2: Execute the Plan
Iterate through the skeleton stack to implement code:
```bash
jj edit <target-change-id>
# Implement code... verify compilation/tests
# Then move on: jj edit <next-change-id>
```
`jj edit` is the right tool here because the skeleton commits are still **empty** when you enter them. Once you've filled a commit and moved on, it's now "populated" — don't go back with `jj edit`.

### Step 3: Fixing a Populated Commit
If you need to revise an already-populated commit:
- Use `jj new <rev> -m "fixup"` and make your changes, then `jj absorb` to fold them back in.
- Avoid `jj edit` on populated commits — it repoints the working copy onto an existing change, which can silently mix new edits with old content.

## State Management & Recovery
- **Mistakes**: `jj undo` is safe for local rollbacks; ask the user before major structural rollbacks.
- **Amending ancestors**: Use `jj absorb` to distribute changes to the right parent automatically.
- **Splitting a commit**: Don't use interactive `jj split`. Return to the routing table in SKILL.md and read `references/split.md`.
