#!/usr/bin/env bash
# Claude WorktreeRemove hook: forget and remove workspaces created by jj-workspace-create.

set -euo pipefail

payload=$(cat)
worktree_path=$(printf '%s' "$payload" | jq -r '.worktree_path')

if [ -z "$worktree_path" ] || [ "$worktree_path" = "null" ]; then
    echo "missing worktree path" >&2
    exit 1
fi

case "$worktree_path" in
*/.claude/worktrees/*)
    ;;
*)
    echo "refusing to remove non-Claude jj workspace path: $worktree_path" >&2
    exit 1
    ;;
esac

repo_root=${worktree_path%/.claude/worktrees/*}
workspace_name=${worktree_path#"$repo_root"/.claude/worktrees/}

case "$workspace_name" in
"" | */* | "." | "..")
    echo "invalid workspace name in path: $worktree_path" >&2
    exit 1
    ;;
esac

if [ -d "$worktree_path" ]; then
    jj -R "$repo_root" workspace forget "$workspace_name" >&2 2>&1 || true
    rm -rf "$worktree_path"
fi
