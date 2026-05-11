# Writing a jj Commit Message

## Context

- Current change status: !`jj st`
- Current diff: !`jj diff`
- Recent history: !`jj log -r 'ancestors(@, 5)' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'`

## Task

Based on the diff above, write a commit message and apply it with `jj describe -m "..."`.

Use conventional commit format: `type(scope): summary`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`
- Omit scope if not obvious; subject line under 72 characters
- If the diff is empty, tell the user there is nothing to describe

Report the message you used. No other explanation needed.
