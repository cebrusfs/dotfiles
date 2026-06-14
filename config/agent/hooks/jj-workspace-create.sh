#!/usr/bin/env bash
# Claude WorktreeCreate hook: create an isolated jj workspace and print its path.

set -euo pipefail

payload=$(cat)
cwd=$(printf '%s' "$payload" | jq -r '.cwd')
name=$(printf '%s' "$payload" | jq -r '.name')

if [ -z "$cwd" ] || [ "$cwd" = "null" ] || [ -z "$name" ] || [ "$name" = "null" ]; then
    echo "missing cwd or workspace name" >&2
    exit 1
fi

case "$name" in
*/* | "." | "..")
    echo "invalid workspace name: $name" >&2
    exit 1
    ;;
esac

worktree_path="${cwd}/.claude/worktrees/${name}"

mkdir -p "$(dirname "$worktree_path")"
cd "$cwd"
jj workspace add --name "$name" "$worktree_path" >&2
printf '%s\n' "$worktree_path"
