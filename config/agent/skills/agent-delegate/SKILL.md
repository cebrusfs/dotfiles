---
name: agent-delegate
description: Lead delegated agent workers for complex or multi-part work — invoke another agent CLI non-interactively (claude -p, codex exec) or runtime subagents for blind review, code exploration, or bounded implementation help. Use when coordinating work that benefits from parallel workers, when a repo workflow says to lead subagent/CLI workers, or before calling another agent CLI.
---

# agent-delegate

Invocation mechanics for delegated agent workers. The delegation contract —
what may be delegated, caller ownership, blind-review protocol — belongs to
the repo's agent guide (e.g. AGENTS.md); read it first. The caller always
owns repo rules, final edits, verification, commits, and user-facing claims;
worker output is advisory until inspected against the current worktree.

## General rules (any agent CLI)

- Always use the CLI's non-interactive mode; never open a TUI.
- Flags rot as CLIs update: when an invocation fails, re-verify with
  `--help` instead of retrying variations from memory.
- Choose worker strength by role, not by model name: strongest available for
  correctness-sensitive review, balanced/cheap for routine or read-only work.
  If it is unclear which model or runtime the requestor wants to spend, ask
  before spawning.
- Never bypass a callee's sandbox or approval protections.
- Give each worker a bounded prompt (task, scope, expected report format) and
  a disjoint write set; capture the final report to a file when it feeds
  later steps.
- For blind review, the prompt carries no self-rationale: give the diff and
  context docs, ask for severity plus file/line findings; "No findings" is
  acceptable.

## claude

```bash
claude -p [--model <model>] [--allowedTools <tools>] "<prompt>"
```

- Strongest model for blind review; balanced model for routine help.
- Restrict with `--allowedTools` for read-only exploration/review work.

## codex

```bash
codex exec [-m <model>] [-s <sandbox>] [-C <dir>] [-o <file>] "<prompt>"
```

- Prompt as argument or stdin; default model comes from `~/.codex/config.toml`.
- Sandbox: `-s read-only` for review/exploration, `-s workspace-write` for
  bounded edits. Never `danger-full-access` or
  `--dangerously-bypass-approvals-and-sandbox`.
- `-o <file>` writes the worker's final message to a file; `--json` streams
  JSONL events.
- `codex exec resume --last` continues the previous session with context;
  `codex exec review` runs Codex's built-in repo review.
- If it refuses to start outside a git repo (e.g. a jj workspace without a
  colocated `.git`), add `--skip-git-repo-check`.

## Adding a new agent CLI

Add a section with the same shape: non-interactive invocation form,
sandbox / read-only mode, model selection, and output capture.
