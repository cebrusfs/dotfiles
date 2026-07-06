# Agent CLI Invocation

Read for CLI mechanics beyond the default dispatch form in
[../SKILL.md](../SKILL.md): resume, output capture, or a non-Codex runtime.
Model choice comes from [models.md](models.md).

## Codex

Headless hardening (flags verified against `--help`, codex-cli 0.144.1):

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
- `codex exec resume --last` resumes with edits intact. Run it from the original
  directory; `resume` does not accept `-C`, and still needs
  `--skip-git-repo-check` if the original dispatch did.
- `codex exec review` runs the built-in repo review; `--json` emits JSONL.
- In a jj workspace without colocated `.git`, add `--skip-git-repo-check`.
- On `failed to spawn code-mode host` with mise-installed Codex 0.144.0,
  re-dispatch with `--disable code_mode_host` (observed 2026-07-10).

## Claude

```bash
claude -p --model <model> [--allowedTools <tools>] "<prompt>"
```

Use `--allowedTools` to keep exploration/review read-only. Runtime subagents
are preferable when their harness is the reason for staying in Claude.

## Gemini

```bash
gemini -p "<prompt>" [-m <verified-model>]
```

When adding another CLI, record only its non-interactive form, sandbox/read-only
mode, model selector, output capture, and verified failure recovery.
