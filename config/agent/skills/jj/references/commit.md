# Writing a jj Commit Message

> **Purpose:** write/apply a message for a finished change — one component per message
> (`<component>: <title>`, optional summary body).

- Status: !`jj st`
- Diff: !`jj diff`
- History: !`jj log -r 'ancestors(@, 5)' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'`

Apply a simple one-line message with `jj describe -m "..."`.

For a message body or other multiline text, do not use shell-specific ANSI-C
quoting such as `$'...\n...'`. Use stdin instead:

```bash
jj describe --stdin <<'MSG'
component: title

Summary body.
MSG
```

If composing the message in a file is clearer, write it under `$TMPDIR` and feed
it with `jj describe --stdin < "$message_file"`. `jj describe` supports
`--stdin`, not a message-file flag; Git's equivalent is `git commit -F <file>`
or `git commit -F -`.

**Format (priority order):**
1. Follow active repository agent / contributing instructions (most important)
2. Match project history pattern
3. Default: `<component>: <title>`

Title ≤72 chars. Use the subject for the high-level what. Use a body when the
why or how would not be obvious from the diff, or when the change has tradeoffs,
risks, or close keywords; do not squeeze material context into the subject. Use
bullets when the body explains multiple distinct what/why/how points. After
amending, squashing, or splitting a commit, re-read the final diff and update the
message if it no longer describes the committed content. If diff is empty, say
so.

Report the message used. Nothing else.
