# Writing a jj Commit Message

## Context

- Current change status: !`jj st`
- Current diff: !`jj diff`
- Recent history: !`jj log -r 'ancestors(@, 5)' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'`

## Task

Based on the diff above, write a commit message and apply it with `jj describe -m "..."`.

**Determine the Format (Follow this hierarchy):**

1. **Project History:** Look at the `Recent history` above. If there is a clear pattern (e.g., `type(scope):`, `[TAG]`, bug tracker prefixes), strictly mimic that format.
2. **Project Documentation:** If the history is ambiguous, check project guidelines (`CLAUDE.md`, `GEMINI.md`, `README.md`, `CONTRIBUTING.md`) for instructions.
3. **Default Format:** If you cannot determine a convention, use: `scope: summary`
   - The `scope` briefly describes the component.
   - Omit scope if not obvious.

**General Rules:**
- Subject line under 72 characters.
- If the diff is empty, tell the user there is nothing to describe.

Report the message you used. No other explanation needed.
