#!/usr/bin/env bash
# commit-nudge: on turn end, continue once when a jj working copy has tracked
# changes that may need a local checkpoint. Generic: no project layout baked in.
#
# Optional per-project ignore:
#   <project>/.agents/commit-nudge-ignore
#   <project>/.claude/commit-nudge-ignore
#   one path prefix per line, e.g. sticky local junk like `config/iterm2/`.

hook_input=$(cat)
stop_hook_active=false
if printf '%s' "$hook_input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
    stop_hook_active=true
fi

project_root=$(jj root 2>/dev/null) || exit 0
cd "$project_root" || exit 0

paths=$(jj st 2>/dev/null | sed -n 's/^[A-Z] //p')
[ -n "$paths" ] || exit 0

apply_ignore_file() {
    local ignore_file=$1
    local patterns

    [ -f "$ignore_file" ] || return 0
    patterns=$(sed '/^[[:space:]]*$/d; /^[[:space:]]*#/d' "$ignore_file")
    [ -n "$patterns" ] || return 0

    paths=$(
        printf '%s\n' "$paths" |
            PATTERNS="$patterns" awk '
                BEGIN {
                    n = split(ENVIRON["PATTERNS"], ignored, "\n")
                }
                {
                    keep = 1
                    for (i = 1; i <= n; i++) {
                        if (index($0, ignored[i]) == 1) {
                            keep = 0
                            break
                        }
                    }
                    if (keep) {
                        print
                    }
                }
            '
    )
}

[ -n "${AGENT_COMMIT_NUDGE_IGNORE:-}" ] && apply_ignore_file "$AGENT_COMMIT_NUDGE_IGNORE"
apply_ignore_file "$project_root/.agents/commit-nudge-ignore"
apply_ignore_file "$project_root/.claude/commit-nudge-ignore"

paths=$(printf '%s\n' "$paths" | sed '/^$/d')
[ -n "$paths" ] || exit 0

path_count=$(printf '%s\n' "$paths" | wc -l | tr -d ' ')
tracked_paths=()
while IFS= read -r path; do
    tracked_paths+=("$path")
done <<<"$paths"

dir_count=$(
    printf '%s\n' "$paths" |
        while IFS= read -r path; do
            dirname "$path"
        done |
        sort -u |
        wc -l |
        tr -d ' '
)

hash_stdin() {
    if command -v shasum >/dev/null 2>&1; then
        shasum | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum | awk '{print $1}'
    else
        cksum | awk '{print $1}'
    fi
}

state_base=${AGENT_HOOK_STATE_HOME:-}
if [ -z "$state_base" ]; then
    if [ -n "${XDG_STATE_HOME:-}" ]; then
        state_base="$XDG_STATE_HOME/agent-hooks"
    elif [ -n "${HOME:-}" ]; then
        state_base="$HOME/.local/state/agent-hooks"
    else
        state_base="${TMPDIR:-/tmp}/agent-hooks"
    fi
fi

project_key=$(printf '%s' "$project_root" | hash_stdin)
fingerprint=$(
    {
        printf '%s\n' "$paths"
        jj diff --git -- "${tracked_paths[@]}" 2>/dev/null ||
            jj diff -- "${tracked_paths[@]}" 2>/dev/null ||
            true
    } | hash_stdin
)
state_dir="$state_base/commit-nudge"
state_file="$state_dir/$project_key"
previous=""
[ -f "$state_file" ] && previous=$(sed -n '1p' "$state_file")
mkdir -p "$state_dir" 2>/dev/null && printf '%s\n' "$fingerprint" >"$state_file"

[ "$stop_hook_active" = true ] && exit 0
[ "$previous" = "$fingerprint" ] && exit 0

dir_word=directories
[ "$dir_count" = 1 ] && dir_word=directory

message="Commit checkpoint: jj @ has ${path_count} tracked change(s) across ${dir_count} ${dir_word}. If this turn completed a coherent implementation change and relevant checks are done or reported, create a local jj commit/checkpoint for only your changes before the final response. If committing is unsafe or inappropriate, leave it uncommitted and say why. Never include unrelated pre-existing user changes."
escaped_message=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')

printf '{"decision":"block","reason":"%s"}\n' "$escaped_message"
exit 0
