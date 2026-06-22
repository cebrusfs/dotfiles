#!/usr/bin/env zsh

emulate -L zsh

local cwd=$1
local depth=${2:-10}
local display_limit=${3:-3}
shift 3
local -a strip_prefixes=("$@")

[[ "$depth" == <-> ]] || depth=10
[[ "$display_limit" == <-> ]] || display_limit=3

# Keep zsh/p10k self-contained while matching jj-starship bookmark display.
function _p10k_jj_build_bookmark_template() {
  emulate -L zsh

  local depth=$1
  local distance_expr='if(current_working_copy, "0"'
  local i
  for (( i = 1; i <= depth; i++ )); do
    distance_expr="${distance_expr}, if(self.contained_in(\"parents(@, ${i})\"), \"${i}\""
  done
  distance_expr="${distance_expr}, \"\""
  for (( i = 1; i <= depth; i++ )); do
    distance_expr="${distance_expr})"
  done
  distance_expr="${distance_expr})"

  print -r -- "self.local_bookmarks().map(|b| b.name() ++ \"\\x1e\" ++ ${distance_expr}).join(\"\\n\") ++ \"\\n\""
}

cd "$cwd" || exit

local jj_template='change_id.shortest(8).prefix() ++ "|" ++ change_id.shortest(8).rest() ++ "|" ++ bookmarks.join(", ") ++ "|" ++ if(conflict, "conflict", "") ++ "|" ++ if(divergent, "divergent", "") ++ "|" ++ if(empty, "clean", "dirty") ++ "|" ++ description.first_line() ++ "|" ++ diff.summary()'
local bookmark_template=$(_p10k_jj_build_bookmark_template "$depth")
local bookmark_revset
if (( depth > 0 )); then
  local search_depth=$((depth + 1))
  bookmark_revset="(ancestors(@, ${search_depth}) & bookmarks()) ~ ::parents(immutable_heads() & ancestors(@, ${search_depth}))"
else
  bookmark_revset='@ & bookmarks()'
fi

local info bookmark_rows
info=$(jj --ignore-working-copy log -r @ --no-graph -T "$jj_template") || exit
bookmark_rows=$(jj --ignore-working-copy log -r "$bookmark_revset" --no-graph -T "$bookmark_template") || bookmark_rows=""

local change_prefix change_rest direct_bmarks conflict divergent is_empty desc diff_summary
IFS='|' read -d "" -r change_prefix change_rest direct_bmarks conflict divergent is_empty desc diff_summary <<< "$info"

local rs=$'\x1e'
local -a bookmark_entries bookmark_labels
local row name display_name distance prefix
for row in ${(f)bookmark_rows}; do
  [[ "$row" == *"$rs"* ]] || continue
  name="${row%%$rs*}"
  distance="${row##*$rs}"
  [[ -n "$name" && "$distance" == <-> ]] || continue

  display_name=$name
  for prefix in "${strip_prefixes[@]}"; do
    if [[ -n "$prefix" && "$display_name" == "$prefix"* ]]; then
      display_name="${display_name:${#prefix}}"
      break
    fi
  done

  bookmark_entries+=("$(printf "%06d" "$distance")${rs}${name}${rs}${display_name}")
done

local bmarks=$direct_bmarks
local closest_bookmark=""
if (( ${#bookmark_entries} > 0 )); then
  bookmark_entries=("${(@on)bookmark_entries}")
  closest_bookmark="${${bookmark_entries[1]#*$rs}%%$rs*}"

  local shown=0
  local total=${#bookmark_entries}
  for row in "${bookmark_entries[@]}"; do
    if (( display_limit > 0 && shown >= display_limit )); then
      continue
    fi

    distance="${row%%$rs*}"
    display_name="${row##*$rs}"
    distance=$((10#$distance))
    if (( distance > 0 )); then
      bookmark_labels+=("${display_name}~${distance}")
    else
      bookmark_labels+=("$display_name")
    fi
    (( shown++ ))
  done

  if (( display_limit > 0 && total > shown )); then
    bookmark_labels+=("…+$((total - shown))")
  fi

  bmarks="(${(j:, :)bookmark_labels})"
fi

local remote_unsynced=""
if [[ -n "$closest_bookmark" ]]; then
  local sync_template='self.name() ++ "\x1e" ++ if(self.remote(), self.remote(), "") ++ "\x1e" ++ if(self.normal_target(), self.normal_target().commit_id(), "") ++ "\n"'
  local sync_rows
  sync_rows=$(jj --ignore-working-copy bookmark list --all-remotes "exact:${closest_bookmark}" -T "$sync_template" 2>/dev/null) || sync_rows=""

  local local_target="" has_remote=0 is_synced=0
  local -a remote_targets=()
  local remote target
  for row in ${(f)sync_rows}; do
    [[ "$row" == *"$rs"* ]] || continue
    name="${row%%$rs*}"
    row="${row#*$rs}"
    remote="${row%%$rs*}"
    target="${row#*$rs}"

    if [[ -z "$remote" ]]; then
      local_target=$target
    elif [[ "$remote" != "git" ]]; then
      has_remote=1
      remote_targets+=("$target")
    fi
  done

  if [[ -n "$local_target" ]]; then
    for target in "${remote_targets[@]}"; do
      if [[ "$target" == "$local_target" ]]; then
        is_synced=1
        break
      fi
    done
  fi

  if (( has_remote && ! is_synced )); then
    remote_unsynced="remote"
  fi
fi

print -r -- "${change_prefix}|${change_rest}|${bmarks}|${conflict}|${divergent}|${remote_unsynced}|${is_empty}|${desc}|${diff_summary}"
