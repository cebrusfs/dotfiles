# Antigravity CLI runtime verification

**Status: help-level checks only, 2026-11-16.** Verified with `agy --version`
(`1.5.3`) and `agy --help` on the installed CLI:

| Flag | Help-level behavior |
|---|---|
| `--print`, `-p`, `--prompt` | Run one prompt non-interactively and print the response; `-p` is the short alias and `--prompt` is an alias. |
| `--model` | Select the model for this CLI session. |
| `--effort` | Reasoning effort: `low`, `medium`, `high`, `xhigh`, `max`. |
| `--output-format` | Print output: `text` (default), `json`, `stream-json`. |
| `--input-format` | Print input: `text` (default), `stream-json`; the latter reads one NDJSON message per stdin line, runs a turn for each, and requires `--output-format stream-json`. |
| `--json-schema` | Schema string or file path enforcing structured output; for `stream-json`, applies only to the final result. |
| `--print-timeout` | Print-mode time limit; default `0s`, where `0` waits until the turn completes. |
| `--continue`, `-c`, `--conversation` | `--continue` / `-c` continues the latest conversation; `--conversation` resumes one by ID. |
| `--sandbox` | Run in a sandbox with terminal restrictions enabled. |
| `--mode` | Session execution mode: `accept-edits`, `auto`, `plan`. |

An Antigravity session still needs to verify these behaviors with a harmless
temporary workspace:

1. Run a non-interactive worker and confirm its filesystem boundary, including
   whether there is an enforced read-only mode and how unattended approvals work.
2. Capture and inspect structured final output, including schema validation.
3. Record a conversation ID and resume it; confirm the correct conversation
   continues without losing its context or changing its permissions.
4. Verify failure recovery and cleanup after interrupting a worker.

Do not infer these behaviors from flag names. Update this document with
observed results and remove this pending task only when all four are
verified. Dispatch authorization and repository maintenance rules still apply.
