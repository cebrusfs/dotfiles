# Writing a jj Commit Message

- Status: !`jj st`
- Diff: !`jj diff`
- History: !`jj log -r 'ancestors(@, 5)' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'`

Apply with `jj describe -m "..."`.

**Format (priority order):**
1. Match project history pattern (most important)
2. Check `CLAUDE.md` / `CONTRIBUTING.md`
3. Default: `scope: summary` (omit scope if not obvious)

Subject ≤72 chars. If diff is empty, say so.

Report the message used. Nothing else.
