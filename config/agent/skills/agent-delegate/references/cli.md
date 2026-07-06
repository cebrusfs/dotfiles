# Agent CLI Invocation

Read when a CLI worker is the chosen route: invocation, resume, output capture,
or a non-Codex runtime. [../SKILL.md](../SKILL.md) owns whether to delegate at
all and owns the CLI session-boundary authorization; model choice comes from
[models.md](models.md). Later `resume` calls within the same approved lane keep
that conversation boundary.

## Codex

Headless hardening (flags verified against `--help`, codex-cli 0.144.5):

- `-a never` and `--search` are global flags — they go before `exec`.
- `--strict-config` fails fast on unknown config keys instead of drifting.
- `--ephemeral` skips rollout persistence for one-shot workers; omit it when
  `resume` may be needed.
- `--output-schema <file>` returns a schema-conforming final JSON for
  machine-parsed reports.
- No timeout or retry flags exist; supervise wall-clock from the caller.
  Re-run read-only tasks freely; never blindly re-run writable ones.
- `-o <file>` captures only the last message; a Stop hook may replace it. When
  a report feeds later work, tell the worker to write the artifact itself.
- `codex exec resume <session-id>` resumes with edits intact. Run it from the
  original directory; `resume` does not accept `-C`, and still needs
  `--skip-git-repo-check` if the original dispatch did. `--last` picks the most
  recent session in that directory, so it resumes the wrong worker as soon as
  two lanes share a cwd — record each dispatch's session id and pass it.
- `resume` also rejects `-s`/`--sandbox`; override the sandbox with
  `-c 'sandbox_mode="workspace-write"'` (verified 0.144.5). This enables the
  review-then-fix pattern: dispatch the review with `-s read-only` and no
  `--ephemeral`, judge the findings, then resume the same session with the
  write override so the worker applies accepted fixes with its context intact.
- `codex exec review` runs the built-in repo review; `--json` emits JSONL.
- In a jj workspace without colocated `.git`, add `--skip-git-repo-check`.
- On `failed to spawn code-mode host` with mise-installed Codex 0.144.0,
  re-dispatch with `--disable code_mode_host` (observed 2026-07-10).

## Claude

For dialogue or review that may need a follow-up, keep one foreground manager
alive. It owns one read-only Claude CLI child in streaming-input mode:

```bash
session_dir="$TMPDIR/agent-delegate/claude/<task>"
helper="$HOME/.agents/skills/agent-delegate/scripts/claude-session.py"

"$helper" start "$session_dir" --model <model> [--effort <effort>]
```

Launch it through a persistent process/PTY handle (Codex: unified exec with
`tty` enabled) and retain that handle for the lane. The manager switches that
PTY out of canonical mode so long NDJSON prompts are not truncated at the
terminal line-buffer limit. Wait for `manager_ready`, then send each prompt,
including follow-ups, as one NDJSON line:

```json
{"prompt":"<task or follow-up>"}
{"type":"close"}
```

The manager serializes queued prompts and prints Claude's raw stream, including
one `result` per prompt. It records `session.json`, `events.jsonl`, `stderr.log`,
and the latest `reply.txt`. One Claude process handles every turn, so ordinary
follow-ups do not rebuild the process-local prompt context. Do not invoke a new
shell command per turn.

Send `close` when the lane finishes. EOF, SIGHUP, SIGINT, and SIGTERM also close
the child; after a short grace period the manager terminates it, then exits and
releases its lock. It is not a daemon and should not remain idle after the
caller or lane ends.

The helper exposes only `Read,Grep,Glob` with `dontAsk`, preserves the original
cwd and config root, and rejects a second live manager for the same directory.
Claude stores recovery transcripts under
`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/`; the parent sandbox must allow
writes there. The helper verifies the transcript after every successful turn.
Do not redirect `CLAUDE_CONFIG_DIR`, which would also replace auth, settings,
hooks, plugins, and skills.

If the manager dies, first confirm its process is gone, then inspect the logs.
Start a replacement only by explicitly recovering the recorded session:

```bash
"$helper" recover "$session_dir"
```

Use the same NDJSON protocol and make the first prompt state what was
interrupted. Recovery passes the recorded ID to `--resume`: the conversation
survives, but the prompt cache may cold-rebuild because this is a new process.
Never silently replace it with a fresh `start`. `--continue` is ambiguous when
sessions run in parallel; `--fork-session` is only for intentional divergence.

For a disposable one-shot query, direct CLI use remains appropriate:

```bash
claude -p --model <model> --tools "Read,Grep,Glob" \
  --permission-mode dontAsk --mcp-config '{"mcpServers":{}}' \
  --strict-mcp-config --no-session-persistence "<prompt>"
```

Flags and two-turn streaming behavior verified with Claude Code 2.1.220.
Runtime subagents remain preferable when their harness is the reason for
staying in Claude.

## Antigravity (`agy`)

CLI surface checked with installed `agy` 1.2.3 on 2026-10-08 (`agy --help`,
`agy help models`, and `agy models`):

- `agy --print "<prompt>"` runs one non-interactive prompt; `-p` is its alias.
- `--model <model>` selects the model. Use `agy models` to inspect the current
  account's IDs and display labels; the configured `Gemini 3.1 Pro (High)`
  appeared in that list. Do not assume another runtime's catalog applies.
- `--effort` accepts `low`, `medium`, or `high`.
- `--output-format` accepts `text`, `json`, or `stream-json`.
  `--json-schema` accepts a schema string or file path.
- `--input-format stream-json` reads NDJSON turns from stdin and requires
  `--output-format stream-json`.
- `--print-timeout` defaults to `5m0s`.
- `--conversation <id>` resumes by ID; `--continue` / `-c` chooses the most
  recent conversation. Record the ID for parallel lanes.
- `--sandbox` enables terminal restrictions. `--mode=plan` is planning mode;
  neither has been verified as a read-only worker boundary.

These are help/catalog checks, not a completed worker invocation or resume
test. Read-only enforcement, unattended approvals, structured output, and
recovery remain unverified; follow the remaining task in
[antigravity-cli-verification.md](../../../../../docs/antigravity-cli-verification.md).
The CLI session boundary is still governed by [../SKILL.md](../SKILL.md).
Google-agent CLI maintenance targets Antigravity; do not add Gemini CLI recipes.

When adding another CLI, record only its non-interactive form, sandbox/read-only
mode, model selector, output capture, and verified failure recovery.
