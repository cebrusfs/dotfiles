#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: ${0##*/} [--keep] <name> [codex-exec-args...]" >&2
}

keep=false
if [ "${1:-}" = "--keep" ]; then
    keep=true
    shift
fi

if [ "$#" -lt 1 ]; then
    usage
    exit 2
fi

name=$1
shift

create_hook="${HOME}/.dotfiles/config/agent/hooks/jj-workspace-create.sh"
remove_hook="${HOME}/.dotfiles/config/agent/hooks/jj-workspace-remove.sh"
ws=
codex_pid=

# shellcheck disable=SC2329 # Invoked by EXIT/INT/TERM traps.
cleanup() {
    status=$?

    trap - EXIT INT TERM

    if [ -n "$codex_pid" ] && kill -0 "$codex_pid" 2>/dev/null; then
        kill "$codex_pid" 2>/dev/null || true
        wait "$codex_pid" 2>/dev/null || true
    fi

    if [ -n "$ws" ]; then
        if [ "$keep" = true ]; then
            printf 'Kept workspace: %s\n' "$ws" >&2
            printf "Cleanup command: printf '{\"worktree_path\":\"%%s\"}' \"%s\" | \"%s\"\n" "$ws" "$remove_hook" >&2
        elif ! printf '{"worktree_path":"%s"}' "$ws" | "$remove_hook"; then
            printf 'Failed to remove workspace: %s\n' "$ws" >&2
        fi
    fi

    exit "$status"
}

trap 'cleanup' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

ws=$(printf '{"cwd":"%s","name":"%s"}' "$PWD" "$name" | "$create_hook")

set +e
"${CODEX_BIN:-codex}" exec -C "$ws" --skip-git-repo-check "$@" &
codex_pid=$!
wait "$codex_pid"
codex_status=$?
codex_pid=
set -e

exit "$codex_status"
