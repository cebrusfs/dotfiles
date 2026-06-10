#!/bin/bash
#
# gh_issue.sh - Extended issue operations for GitHub CLI (gh)
#
# Handles operations that `gh issue` doesn't expose natively: blocked-by
# dependencies, sub-issue hierarchy, and bulk thread dumps. Run from inside
# the repository.
#
# TRACKING: Workaround until native support is added to gh CLI.
# ISSUE: https://github.com/cli/cli/issues/10298
#

set -euo pipefail

usage() {
    echo "Usage: $0 <operation> [args...]   (run from inside the repo)"
    echo ""
    echo "Read operations:"
    echo "  --dump              <issue_num...>    Full thread (body + comments) for multiple issues"
    echo "  --list-blocked-by   <issue>           Issues blocking this one (JSON)"
    echo "  --list-blocking     <issue>           Issues this one blocks (JSON)"
    echo "  --list-sub-issues   <issue>           Sub-issues of this issue (JSON)"
    echo "  --show-parent       <issue>           Parent number + sub-issue summary (JSON)"
    echo "  --relations         <issue_num...>    Rich view: parent/sub-issues/blockedBy (GraphQL)"
    echo "  --report            [limit=20] [--human]   Issue list (compact default; --human for table)"
    echo ""
    echo "Write operations (support multiple targets):"
    echo "  --add-dependency    <issue> <blocker...>   Mark as blocked by"
    echo "  --remove-dependency <issue> <blocker...>   Remove blocked-by link"
    echo "  --add-sub-issue     <parent> <child...>    Set as sub-issues"
    echo "  --remove-sub-issue  <parent> <child...>    Unlink sub-issues"
    exit 1
}

[ $# -eq 0 ] && usage

OP="$1"
shift

check_auth() {
    if ! gh auth status &>/dev/null; then
        echo "Error: gh CLI is not authenticated. Please run 'gh auth login'." >&2
        exit 1
    fi
}

fetch_issue_id() {
    local num="$1"
    local id
    id=$(gh api "repos/{owner}/{repo}/issues/${num}" --jq '.id')
    if [ -z "${id}" ] || [ "${id}" == "null" ]; then
        echo "Error: Could not retrieve issue ID for #${num}." >&2
        exit 1
    fi
    echo "${id}"
}

check_auth

case "$OP" in
--dump)
    [ $# -eq 0 ] && usage
    NUMS_JSON=$(printf '%s\n' "$@" | jq -R 'tonumber' | jq -s -c .)
    # $owner/$name/$nums are GraphQL variables, not shell — single quotes are intentional.
    # shellcheck disable=SC2016
    QUERY='query($owner: String!, $name: String!, $nums: [Int!]!) {
        repository(owner: $owner, name: $name) {
            issues(numbers: $nums) {
                nodes {
                    number state title
                    author { login }
                    createdAt
                    body
                    comments(first: 100) {
                        nodes {
                            author { login }
                            createdAt
                            body
                        }
                    }
                }
            }
        }
    }'
    gh api graphql \
        -F owner="{owner}" -F name="{repo}" -F nums="${NUMS_JSON}" \
        -f query="${QUERY}" \
        --jq '.data.repository.issues.nodes[] |
            "## #\(.number) [\(.state)] \(.title)\n" +
            "@\(.author.login) · \(.createdAt)\n\n" +
            .body +
            "\n" +
            (if .comments.nodes | length > 0 then
                "\n" + ([.comments.nodes[] |
                    "---\n@\(.author.login) · \(.createdAt)\n\n" + .body
                ] | join("\n\n"))
            else "" end) +
            "\n\n" + ("=" * 60) + "\n"'
    ;;

--list-blocked-by)
    [ $# -lt 1 ] && usage
    gh api "repos/{owner}/{repo}/issues/$1/dependencies/blocked_by" \
        -H "Accept: application/vnd.github+json" \
        --jq '[.[] | {number, title, state}]'
    ;;

--list-blocking)
    [ $# -lt 1 ] && usage
    gh api "repos/{owner}/{repo}/issues/$1/dependencies/blocking" \
        -H "Accept: application/vnd.github+json" \
        --jq '[.[] | {number, title, state}]'
    ;;

--list-sub-issues)
    [ $# -lt 1 ] && usage
    gh api "repos/{owner}/{repo}/issues/$1/sub_issues" \
        -H "Accept: application/vnd.github+json" \
        --jq '[.[] | {number, title, state}]'
    ;;

--show-parent)
    [ $# -lt 1 ] && usage
    gh api "repos/{owner}/{repo}/issues/$1" \
        -H "Accept: application/vnd.github+json" \
        --jq '{parent: .parent.number, sub_issues_summary: .sub_issues_summary}'
    ;;

--relations)
    [ $# -eq 0 ] && usage
    NUMS_JSON=$(printf '%s\n' "$@" | jq -R 'tonumber' | jq -s -c .)
    # $owner/$name/$nums are GraphQL variables, not shell — single quotes are intentional.
    # shellcheck disable=SC2016
    QUERY='query($owner: String!, $name: String!, $nums: [Int!]!) {
        repository(owner: $owner, name: $name) {
            issues(numbers: $nums) {
                nodes {
                    number state title
                    parent { number state title }
                    subIssues(first: 20) { nodes { number state title } }
                    blockedBy(first: 20) { nodes { number state title } }
                }
            }
        }
    }'
    gh api graphql \
        -F owner="{owner}" -F name="{repo}" -F nums="${NUMS_JSON}" \
        -f query="${QUERY}" \
        --jq '.data.repository.issues.nodes[] |
            "- #\(.number) [\(.state)] \(.title)\n" +
            "  Parent: " + (if .parent then "#\(.parent.number) [\(.parent.state)] \(.parent.title)" else "None" end) + "\n" +
            "  Sub-issues:\n" + (if .subIssues.nodes | length > 0 then ([.subIssues.nodes[] | "    - #\(.number) [\(.state)] \(.title)"] | join("\n")) else "    - None" end) + "\n" +
            "  Blocked By:\n" + (if .blockedBy.nodes | length > 0 then ([.blockedBy.nodes[] | "    - #\(.number) [\(.state)] \(.title)"] | join("\n")) else "    - None" end) + "\n"'
    ;;

--report)
    HUMAN=0
    LIMIT=20
    while [ $# -gt 0 ]; do
        case "$1" in
        --human) HUMAN=1 ;;
        *) LIMIT="$1" ;;
        esac
        shift
    done
    if [ "$HUMAN" -eq 1 ]; then
        echo -e "| ID | State | Title | Labels | Assignees |\n|---|---|---|---|---|"
        gh issue list -L "$LIMIT" --json number,state,title,labels,assignees \
            --jq '.[] | "| \(.number) | \(.state) | \(.title) | \(.labels | map(.name) | join(", ")) | \(.assignees | map(.login) | join(", ")) |"'
    else
        gh issue list -L "$LIMIT" --json number,state,title,labels,assignees \
            --jq '.[] | "#\(.number) [\(.state)] \(.title)" +
			      (if (.labels | length) > 0 then " [\(.labels | map(.name) | join(","))]" else "" end) +
			      (if (.assignees | length) > 0 then " @\(.assignees | map(.login) | join(","))" else "" end)'
    fi
    ;;

--add-dependency | --remove-dependency | --add-sub-issue | --remove-sub-issue)
    [ $# -lt 2 ] && usage
    TARGET_NUM="$1"
    OTHER_NUMS=("${@:2}")

    for OTHER_NUM in "${OTHER_NUMS[@]}"; do
        OID=$(fetch_issue_id "${OTHER_NUM}")

        case "$OP" in
        --add-dependency)
            gh api -X POST "repos/{owner}/{repo}/issues/${TARGET_NUM}/dependencies/blocked_by" \
                -H "Accept: application/vnd.github+json" \
                -F issue_id="${OID}" --silent
            echo "SUCCESS: #${TARGET_NUM} is now blocked by #${OTHER_NUM}"
            ;;
        --remove-dependency)
            gh api -X DELETE "repos/{owner}/{repo}/issues/${TARGET_NUM}/dependencies/blocked_by/${OID}" \
                -H "Accept: application/vnd.github+json" --silent
            echo "SUCCESS: Removed dependency: #${OTHER_NUM} -> #${TARGET_NUM}"
            ;;
        --add-sub-issue)
            gh api -X POST "repos/{owner}/{repo}/issues/${TARGET_NUM}/sub_issues" \
                -H "Accept: application/vnd.github+json" \
                -F sub_issue_id="${OID}" --silent
            echo "SUCCESS: #${OTHER_NUM} added as sub-issue of #${TARGET_NUM}"
            ;;
        --remove-sub-issue)
            gh api -X DELETE "repos/{owner}/{repo}/issues/${TARGET_NUM}/sub_issue" \
                -H "Accept: application/vnd.github+json" \
                -f sub_issue_id="${OID}" --silent
            echo "SUCCESS: #${OTHER_NUM} unlinked from parent #${TARGET_NUM}"
            ;;
        esac
    done
    ;;

*)
    usage
    ;;
esac
