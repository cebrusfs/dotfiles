#!/usr/bin/env bash
# Claude WorktreeRemove hook: forget and remove workspaces created by jj-workspace-create.

set -euo pipefail

payload=$(cat)
worktree_path=$(printf '%s' "$payload" | jq -r '.worktree_path')

if [ -z "$worktree_path" ] || [ "$worktree_path" = "null" ]; then
    echo "missing worktree path" >&2
    exit 1
fi

# Accept the current home layout and the legacy repo-local layout.
case "$worktree_path" in
"${HOME}/.claude/worktrees/"?* | */.claude/worktrees/?*) ;;
*)
    echo "refusing to remove non-Claude jj workspace path: $worktree_path" >&2
    exit 1
    ;;
esac

base=${worktree_path##*/}
case "$base" in
"" | "." | "..")
    echo "invalid workspace directory in path: $worktree_path" >&2
    exit 1
    ;;
esac

if [ -d "$worktree_path" ]; then
    # A workspace directory knows its main repo; forget it from inside.
    jj -R "$worktree_path" workspace forget >&2 2>&1 || true
    rm -rf "$worktree_path"
fi
