#!/usr/bin/env bash
# commit-nudge: on turn end, nudge to commit when @ piles up across >1 directory
# (a proxy for >1 concern, per the one-component-per-commit convention). Generic —
# no project layout baked in. jj repos only; silent below threshold; non-blocking.
#
# Optional per-project ignore: <project>/.claude/commit-nudge-ignore
#   one path prefix per line, e.g. sticky local junk like `config/iterm2/`.

jj root >/dev/null 2>&1 || exit 0

paths=$(jj st 2>/dev/null | sed -n 's/^[A-Z] //p')
[ -n "$paths" ] || exit 0

ignore="${CLAUDE_PROJECT_DIR:-.}/.claude/commit-nudge-ignore"
[ -f "$ignore" ] && paths=$(printf '%s\n' "$paths" | grep -vFf "$ignore")

n=$(printf '%s\n' "$paths" | sed '/^$/d' | xargs -r -n1 dirname | sort -u | wc -l | tr -d ' ')

if [ "$n" -gt 1 ]; then
    message="jj: @ spans ${n} directories - likely multiple concerns. Commit per component (rules/jj.md split-down), or ignore if it is genuinely one task."
    case "${AGENT_HOOK_FORMAT:-claude}" in
    codex)
        printf '%s\n' "$message"
        ;;
    claude | *)
        printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"%s"}}' "$message"
        ;;
    esac
fi
exit 0
