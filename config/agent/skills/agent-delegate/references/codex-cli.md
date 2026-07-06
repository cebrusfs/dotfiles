# Codex CLI Worker

Verified 2026-11-16 with codex-cli 0.169.0, launched from a sandboxed Claude
Code 2.1.325 session: three read-only lanes and one writable lane ran to
completion.

## Launch

```bash
dir="$TMPDIR/agent-delegate/<lane>"   # holds brief.md; the report lands here
cd <repo> &&
    codex --strict-config -a never --search \
        -c 'default_permissions=":read-only"' \
        exec --json --model gpt-6.1-sol -o "$dir/last-message.md" - \
        <"$dir/brief.md" >"$dir/events.jsonl" 2>"$dir/stderr.log"
```

- `-a never`, `--search`, and `-c` are global flags and go before `exec`.
  `--strict-config` fails fast on an unknown config key.
- `-` reads the brief from stdin. Say in the brief that the final message is
  the deliverable.
- `:read-only` blocks writes and command networking; `--search` still gives the
  worker web search. For a bounded write set select
  `default_permissions="workspace-tool-caches"`, the profile described in
  [agent-config.md](../../../../../docs/agent-config.md#codex-permission-posture),
  and name the write set in the brief.
- Add `-c 'model_reasoning_effort="xhigh"'` for reviews and second opinions.
- From a sandboxed Claude session, start the command outside the Bash sandbox:
  inside it Codex cannot read its own login (`codex login status` fails with
  `Operation not permitted`). Codex's own profile still confines the worker.
- Run it in the background and bound wall-clock time yourself; Codex has no
  timeout flag. Re-run read-only lanes freely; never blindly re-run a writable
  one.

## Report and resume

- The first line of `events.jsonl` carries the `thread_id`; record it per lane.
  `codex exec resume <thread-id>` continues that session from the same
  directory. `resume` takes no `-C` and no `--sandbox`; pass the same `-c`
  profile again.
- Read the report from `last-message.md`. A Stop hook can make the worker add
  one more short message that replaces it (seen on the writable lane); then
  take the report from the `agent_message` items in `events.jsonl`.
- The `turn.completed` event reports token usage.
- In a jj workspace without a colocated `.git`, add `--skip-git-repo-check`.
