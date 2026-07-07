#!/usr/bin/env bash
# learn-nudge: on UserPromptSubmit, add a one-line reminder to run the learn
# skill when the prompt reads like a correction, an override, or a stated
# preference. Pattern-gated, so it costs nothing on ordinary prompts and never
# calls a model; the shared guidance still owns whether a lesson is reusable.
# Claude Code and Codex send the same `prompt` field and accept the same
# `hookSpecificOutput.additionalContext` shape. Generic: no project layout
# baked in.

hook_input=$(cat)
if command -v jq >/dev/null 2>&1; then
    prompt=$(printf '%s' "$hook_input" | jq -r '.prompt // empty')
else
    prompt=$(printf '%s' "$hook_input" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
fi
[ -n "$prompt" ] || exit 0

# Correction and preference markers in English and Traditional Chinese. False
# positives only cost one reminder line; misses fall back to the always-loaded
# trigger in the shared guidance.
pattern='(^|[^[:alnum:]])(don'\''?t|do not|stop|never|instead|wrong|not what i|should(n'\''?t| not| have)|from now on|remember|rule of thumb|prefer)([^[:alnum:]]|$)|不要|不是這樣|別再|應該|從現在開始|以後都|記住|記得|改成|錯了|不對'
printf '%s' "$prompt" | grep -Eiq "$pattern" || exit 0

message="learn-nudge: this prompt reads like a correction, an override, or a stated preference. Fix the current result first; if the lesson is reusable, run the learn skill in this session."
escaped=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$escaped"
exit 0
