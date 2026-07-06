# Writing a jj Commit Message

> **Purpose:** write/apply a message for a finished change — one component per message
> (`<component>: <title>` plus body paragraphs whenever the title omits why).

- Status: !`jj st`
- Diff: !`jj diff`
- History: !`jj log -r 'ancestors(@, 5)' --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'`

Apply a simple one-line message with `jj describe -m "..."`.

For a message body or other multiline text, do not use shell-specific ANSI-C
quoting such as `$'...\n...'`. Use stdin instead:

```bash
jj describe --stdin <<'MSG'
component: title

Describe the behavior or scope that the title cannot carry.

Explain why this change or approach is needed, including the relevant constraint or trade-off.
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

Title ≤72 chars. The subject states the high-level **what**; include **why**
there only when it stays clear and concise. If the title does not explain why
the change or chosen approach is needed, write a body. Use short, unlabeled
paragraphs in reader order: first any missing **what** or behavior, then
**why** (the reason, constraint, or trade-off), then a risk, verification, or
rollout detail only when it informs a future decision. Do not repeat the title
or diff. After amending, squashing, or splitting a commit, re-read the final
diff and update the message if it no longer describes the committed content. If
diff is empty, say so.

Report the message used. Nothing else.
