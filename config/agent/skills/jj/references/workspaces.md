# Writable Worker Isolation — jj Recipes

The VCS-agnostic rule lives in
[agent-delegate](../../agent-delegate/SKILL.md#authority-and-isolation):
concurrent writable workers never share a working copy. This file is only the
jj recipe for obeying it. In another VCS, use that VCS's own worktree mechanism,
and if there is none, run the lanes one at a time rather than sharing. See the
[jj skill](../SKILL.md) for the worker-race warning.

## Claude lead

Prefer a runtime worker with `isolation: "worktree"`. The configured
WorktreeCreate/WorktreeRemove hooks create a jj workspace under
`~/.claude/worktrees/<repo>-<cwd-hash>-<name>` (verified 2026-07-08).

`claude -p --worktree` also creates a home-based jj workspace without colocated
`.git`, but may leave it behind (verified 2026-07-09). Check `jj workspace list`;
cleanup requires `jj workspace forget <name>` plus directory removal. Claude's
ExitWorktree needs `discard_changes: true` because its git check cannot verify a
jj workspace. A Codex worker inside it needs `--skip-git-repo-check`.

## Codex CLI worker

Create a jj workspace explicitly; do not assume a generic worktree is one.
See the [Codex CLI reference](../../agent-delegate/references/codex-cli.md)
for flags.

```bash
name=<name>                       # no slashes, no dots, no spaces
case "$name" in *[!A-Za-z0-9_-]*) echo "bad workspace name"; exit 1;; esac
ws="$HOME/.claude/worktrees/<repo>-$name"

jj workspace add --name "$name" "$ws"
codex exec -C "$ws" --skip-git-repo-check "<prompt>"
```

Teardown deletes a directory, so prove the target before removing it. Never
`rm -rf` a path built from unchecked placeholders:

```bash
ws=$(cd "$ws" && pwd -P) || exit 1                       # canonical, exists
case "$ws" in "$HOME/.claude/worktrees/"?*) ;; *) exit 1;; esac  # inside the root
[ -e "$ws/.jj" ] || exit 1                               # really a workspace
jj -R "$ws" st                                           # LOOK: unintegrated work?

jj workspace forget "$name" && rm -rf "$ws"
```

The `jj st` is not decoration. A worker's last commit may be sitting in that
workspace's `@`; deleting it discards work that was never rebased into the
stack. Integrate first, then tear down.

Claude's WorktreeRemove hook forgets the workspace and deletes its directory,
and keeps the directory when `jj workspace forget` fails.
