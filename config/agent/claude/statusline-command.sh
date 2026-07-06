#!/usr/bin/env bash
# Claude Code statusLine.
#
# Layout mirrors the user's Codex `[tui].status_line`
# (../codex/config.toml), mapped onto the fields the Claude Code statusLine
# JSON payload actually provides. Codex-only segments (run-state,
# approval-mode, task-progress) have no equivalent in the payload and are
# omitted rather than faked.
#
#   Opus 5 high · ~/working/bw_dedrm · bw_dedrm · main · ctx 43% left · 5h 66% left · 7d 50% left

set -u

input=$(cat)

# Truecolor, no dim attribute — dim renders muddy in most terminal themes.
R=$'\033[0m'
C_MODEL=$'\033[38;2;217;119;87m' # Claude coral
C_EFFORT=$'\033[38;2;150;123;114m'
C_DIR=$'\033[38;2;125;170;235m'
C_PROJ=$'\033[38;2;186;148;240m'
C_BRANCH=$'\033[38;2;140;190;140m'
C_SEP=$'\033[38;2;110;110;120m'
C_OK=$'\033[38;2;126;192;126m'
C_WARN=$'\033[38;2;222;184;100m'
C_CRIT=$'\033[38;2;224;108;108m'

get() { printf '%s' "$input" | jq -r "$1"; }

# Percentage left → color. Fewer resources remaining is more urgent.
level_color() {
    if [ "$1" -ge 50 ]; then
        printf '%s' "$C_OK"
    elif [ "$1" -ge 20 ]; then
        printf '%s' "$C_WARN"
    else
        printf '%s' "$C_CRIT"
    fi
}

# --- model + reasoning effort ------------------------------------------------
model_name=$(get '.model.display_name // empty')
effort=$(get '.model.effort.level // .effort.level // empty')

model_part=""
if [ -n "$model_name" ]; then
    model_part="${C_MODEL}${model_name}${R}"
    [ -n "$effort" ] && model_part="${model_part} ${C_EFFORT}${effort}${R}"
fi

# --- current dir (home-relative, like the Codex status line) -----------------
cwd=$(get '.workspace.current_dir // .cwd // empty')
dir_part=""
if [ -n "$cwd" ]; then
    tilde='~'
    dir_part="${C_DIR}${cwd/#$HOME/$tilde}${R}"
fi

# --- project name ------------------------------------------------------------
repo_name=$(get '.workspace.repo.name // empty')
project_dir=$(get '.workspace.project_dir // empty')

project_part=""
if [ -n "$repo_name" ]; then
    project_part="${C_PROJ}${repo_name}${R}"
elif [ -n "$project_dir" ]; then
    project_part="${C_PROJ}$(basename "$project_dir")${R}"
fi

# --- branch + line changes ---------------------------------------------------
# Not in the payload, so read git directly. --no-optional-locks avoids
# contending with a concurrent git/jj process on every status line refresh.
branch_part=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [ -n "$branch" ] && branch_part="${C_BRANCH}${branch}${R}"
fi

# --- context remaining -------------------------------------------------------
ctx_left=$(get '.context_window.remaining_percentage // empty')
ctx_part=""
if [ -n "$ctx_left" ]; then
    ctx_int=$(printf '%.0f' "$ctx_left")
    ctx_part="$(level_color "$ctx_int")ctx ${ctx_int}% left${R}"
fi

# --- rate limits (payload reports used %, status line shows what is left) ----
limit_part() {
    local pct label int left
    pct=$(get "$1")
    label=$2
    [ -z "$pct" ] && return
    int=$(printf '%.0f' "$pct")
    left=$((100 - int))
    printf '%s' "$(level_color "$left")${label} ${left}% left${R}"
}

five_part=$(limit_part '.rate_limits.five_hour.used_percentage // empty' '5h')
week_part=$(limit_part '.rate_limits.seven_day.used_percentage // empty' '7d')

# --- assemble, skipping empty segments ---------------------------------------
out=""
for part in "$model_part" "$dir_part" "$project_part" "$branch_part" \
    "$ctx_part" "$five_part" "$week_part"; do
    [ -z "$part" ] && continue
    if [ -z "$out" ]; then
        out="$part"
    else
        out="${out} ${C_SEP}·${R} ${part}"
    fi
done

printf '%s\n' "$out"
