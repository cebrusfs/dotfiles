---
name: agent-delegate
description: Lead delegated agent workers for complex or multi-part work. Prefer same-runtime subagent APIs for same-family delegation; use agent CLIs only for cross-family or fallback delegation. Use for blind review, code exploration, bounded implementation help, repo workflows that call for workers, or before invoking another agent CLI.
---

# agent-delegate

Invocation mechanics for delegated agent workers. Read the companion files
before dispatching: [routing.md](routing.md) owns the model table, dispatch
triple, report contract, escalation ladder, and verification protocol;
[templates.md](templates.md) owns per-task-shape worker prompts. The
delegation contract — what may be delegated, caller ownership, blind-review
protocol — belongs to the global/repo agent guide; read it first. The caller
always owns repo rules, final edits, commits, and user-facing claims; worker
output is advisory until inspected against the current worktree.

## Route first

- Same family + runtime subagent tool available: use the subagent API, not the
  CLI. Examples: Codex→Codex uses `spawn_agent`/`send_input`/`wait_agent`;
  Claude→Claude uses Task/subagent tools.
- Use CLI only for cross-family delegation, missing/insufficient subagent
  tools, or an explicit user request. State the fallback reason briefly.

## General rules (subagents or agent CLI)

- When using a CLI, use non-interactive mode; never open a TUI.
- CLI flags rot: when an invocation fails, re-verify with
  `--help` instead of retrying variations from memory.
- Choose worker strength by role via [routing.md](routing.md)'s model table.
  If it is unclear which model or runtime the requestor wants to spend, ask
  before spawning.
- Never bypass a callee's sandbox or approval protections.
- Give each worker a bounded prompt carrying the dispatch triple — start from
  [templates.md](templates.md) — and a disjoint write set; capture the final
  report to a file when it feeds later steps.
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
- `-o <file>` captures only the worker's *last* message; repo Stop hooks can
  replace that message (e.g. with a one-line disclaimer), losing the report.
  When the report feeds later steps, instruct the worker to write it to an
  agreed file path itself before ending.
- `codex exec resume --last` continues the previous session with context; a
  killed worker resumes with its file edits intact. `resume` does not accept
  `-C` (run from the working directory) but still needs
  `--skip-git-repo-check` wherever the original run did.
- `codex exec review` runs Codex's built-in repo review; `--json` streams
  JSONL events.
- If it refuses to start outside a git repo (e.g. a jj workspace without a
  colocated `.git`), add `--skip-git-repo-check`.

## Workspace isolation (jj repos)

- Preferred (Claude as lead): spawn workers with `isolation: "worktree"` —
  the WorktreeCreate/WorktreeRemove hooks in
  `config/agent/claude/settings.json` auto-provision a jj workspace under
  `~/.claude/worktrees/<repo>-<cwd-hash>-<name>` — outside the repo, so tree-walking
  tools never scan checkout copies (provisioning verified end-to-end
  2026-07-08; `claude -p --worktree` verified 2026-07-09 creates this
  home-based jj workspace with `.jj` and no colocated `.git`, but can leave it
  after exit — after workers finish, check `jj workspace list` and clean
  leftovers with `jj workspace forget <name>` plus removing the directory;
  Claude's ExitWorktree tool needs `discard_changes: true` on these, since its
  git-based state check cannot verify a jj workspace).
  A Codex worker can run inside one via
  `codex exec -C <path> --skip-git-repo-check` (the workspace has no
  colocated `.git`).
- Preferred manual path (Codex as lead, or outside Claude): use the wrapper,
  which calls the same jj workspace hooks as Claude and cleans up on exit:

  ```bash
  config/agent/skills/agent-delegate/scripts/codex-ws.sh <name> "<prompt>"
  config/agent/skills/agent-delegate/scripts/codex-ws.sh --keep <name> "<prompt>"
  ```

  `--keep` preserves the workspace for `codex exec resume --last` and prints
  the kept path plus cleanup command.
- Raw fallback: do not assume a worker's worktree is a jj workspace; manage it
  yourself and remove it after the worker exits:

  ```bash
  ws="$HOME/.claude/worktrees/<repo>-<name>"
  jj workspace add --name <name> "$ws"
  codex exec -C "$ws" --skip-git-repo-check "<prompt>"
  jj workspace forget <name> && rm -rf "$ws"
  ```
- Never let two workers (or a worker and the lead) rewrite the same working
  copy concurrently — see the `jj` skill's worker-race warning.

## Adding a new agent CLI

Add a section with the same shape: non-interactive invocation form,
sandbox / read-only mode, model selection, and output capture.
