# Writing a jj Commit Message

> **Purpose:** write/apply a message for a finished change — one component per message
> (`<component>: <title>`, optional summary body).

- Status: !`jj st`
- Diff: !`jj diff`
- History: !`jj log -r 'ancestors(@, 5)' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'`

Apply with `jj describe -m "..."`.

**Format (priority order):**
1. Match project history pattern (most important)
2. Check `CLAUDE.md` / `CONTRIBUTING.md`
3. Default: `<component>: <title>` (omit component if not obvious)

Title ≤72 chars. Use a summary body only when it adds context, verification
notes, tradeoffs, or close keywords. If diff is empty, say so.

Report the message used. Nothing else.
