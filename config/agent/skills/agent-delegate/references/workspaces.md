# Writable Worker Isolation in jj Repositories

Read only before dispatching a worker that may edit a jj repository. Never let
two workers, or a worker and lead, rewrite the same working copy concurrently;
see the `jj` skill's worker-race warning.

## Claude lead

Prefer a runtime worker with `isolation: "worktree"`. The configured
WorktreeCreate/WorktreeRemove hooks create a jj workspace under
`~/.claude/worktrees/<repo>-<cwd-hash>-<name>` (verified 2026-07-08).

`claude -p --worktree` also creates a home-based jj workspace without colocated
`.git`, but may leave it behind (verified 2026-07-09). Check `jj workspace list`;
cleanup requires `jj workspace forget <name>` plus directory removal. Claude's
ExitWorktree needs `discard_changes: true` because its git check cannot verify a
jj workspace. A Codex worker inside it needs `--skip-git-repo-check`.

## Codex lead or manual CLI

Use the wrapper, which calls the same hooks and cleans up on exit:

```bash
"$HOME/.agents/skills/agent-delegate/scripts/codex-ws.sh" <name> "<prompt>"
"$HOME/.agents/skills/agent-delegate/scripts/codex-ws.sh" --keep <name> "<prompt>"
```

`--keep` preserves the workspace for resume and prints its path plus cleanup
command.

## Raw fallback

Use only when the hooks/wrapper are unavailable; do not assume a generic
worktree is a jj workspace:

```bash
ws="$HOME/.claude/worktrees/<repo>-<name>"
jj workspace add --name <name> "$ws"
codex exec -C "$ws" --skip-git-repo-check "<prompt>"
jj workspace forget <name> && rm -rf "$ws"
```
