#!/usr/bin/env bash
# Claude WorktreeCreate hook: create an isolated jj workspace and print its path.
# Workspaces live under ~/.claude/worktrees (the official non-git hook pattern),
# not inside the repo, so tree-walking tools never scan checkout copies.

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

hash_stdin() {
    if command -v shasum >/dev/null 2>&1; then
        shasum | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum | awk '{print $1}'
    else
        cksum | awk '{print $1}'
    fi
}

# Same repo basename can exist at different paths; a cwd hash keeps each
# working directory's worktrees in its own namespace.
repo_base=$(basename "$cwd")
cwd_hash=$(printf '%s' "$cwd" | hash_stdin | cut -c1-8)
worktree_path="${HOME}/.claude/worktrees/${repo_base}-${cwd_hash}-${name}"

mkdir -p "$(dirname "$worktree_path")"
cd "$cwd"
jj workspace add --name "$name" "$worktree_path" >&2
printf '%s\n' "$worktree_path"
