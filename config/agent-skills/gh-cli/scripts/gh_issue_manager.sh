#!/bin/bash
#
# gh_issue_manager.sh - Advanced issue manipulation for GitHub CLI (gh)
#
# CORE VALUE:
# 1. Atomic Batch Operations: Uses GraphQL for efficient bulk data retrieval.
# 2. Relationship Management: Wraps non-native features (Sub-issues, Dependencies).
# 3. ID Resolution: Maps standard Issue Numbers to internal Database IDs automatically.
#

set -euo pipefail

usage() {
	echo "Usage: $0 <operation> <args...>"
	echo "Operations:"
	echo "  --relations         <issue_nums...>          Fetch relations with details (state, title)"
	echo "  --report            [limit=20]               Generate a Markdown summary table"
	echo "  --add-dependency    <issue> <blockers...>    Mark issue as blocked by others"
	echo "  --remove-dependency <issue> <blockers...>    Remove dependency links"
	echo "  --add-sub-issue     <parent> <children...>   Set issues as sub-issues of parent"
	echo "  --remove-sub-issue  <parent> <children...>   Unlink sub-issues from parent"
	exit 1
}

[ $# -eq 0 ] && usage

OP="$1"
shift

# Helper: Resolve multiple Issue Numbers to their internal Database IDs in one call.
# Returns a JSON map: {"number": databaseId}
resolve_ids() {
    local nums_json
    nums_json=$(printf '%s\n' "$@" | jq -R 'tonumber' | jq -s -c .)
    gh api graphql -F owner="{owner}" -F name="{repo}" -F nums="$nums_json" -f query='
        query($owner: String!, $name: String!, $nums: [Int!]!) {
            repository(owner: $owner, name: $name) {
                issues(numbers: $nums) {
                    nodes { number databaseId }
                }
            }
        }' --jq '[.data.repository.issues.nodes[] | {key: (.number|as_string), value: .databaseId}] | from_entries'
}

case "$OP" in
--relations)
	[ $# -eq 0 ] && usage
	NUMS_JSON=$(printf '%s\n' "$@" | jq -R 'tonumber' | jq -s -c .)
	
	QUERY='query($owner: String!, $name: String!, $nums: [Int!]!) {
        repository(owner: $owner, name: $name) {
            issues(numbers: $nums) {
                nodes {
                    number
                    state
                    title
                    parent { number state title }
                    subIssues(first: 20) { nodes { number state title } }
                    blockedBy(first: 20) { nodes { number state title } }
                }
            }
        }
    }'
	gh api graphql -F owner="{owner}" -F name="{repo}" -F nums="$NUMS_JSON" -f query="$QUERY" \
		--jq '.data.repository.issues.nodes[] | 
            "- #\(.number) [\(.state)] \(.title)\n" +
            "  Parent: " + (if .parent then "#\(.parent.number) [\(.parent.state)] \(.parent.title)" else "None" end) + "\n" +
            "  Sub-issues:\n" + (if .subIssues.nodes | length > 0 then ([.subIssues.nodes[] | "    - #\(.number) [\(.state)] \(.title)"] | join("\n")) else "    - None" end) + "\n" +
            "  Blocked By:\n" + (if .blockedBy.nodes | length > 0 then ([.blockedBy.nodes[] | "    - #\(.number) [\(.state)] \(.title)"] | join("\n")) else "    - None" end) + "\n"'
	;;

--report)
	LIMIT="${1:-20}"
	echo -e "| ID | State | Title | Labels | Assignees |\n|---|---|---|---|---|"
	gh issue list -L "$LIMIT" --json number,state,title,labels,assignees --jq '.[] | "| \(.number) | \(.state) | \(.title) | \(.labels | map(.name) | join(", ")) | \(.assignees | map(.login) | join(", ")) |"'
	;;

--add-dependency | --remove-dependency | --add-sub-issue | --remove-sub-issue)
	[ $# -lt 2 ] && usage
    TARGET_NUM="$1"
    OTHER_NUMS=("${@:2}")
    
    # Batch resolve IDs for the target and all related issues
    ID_MAP=$(resolve_ids "$TARGET_NUM" "${OTHER_NUMS[@]}")
    
    for OTHER_NUM in "${OTHER_NUMS[@]}"; do
        OID=$(echo "$ID_MAP" | jq -r ".\"$OTHER_NUM\" // empty")
        [ -z "$OID" ] && { echo "Error: Could not find Database ID for #$OTHER_NUM" >&2; continue; }

        case "$OP" in
        --add-dependency)
            gh api -X POST "repos/{owner}/{repo}/issues/$TARGET_NUM/dependencies/blocked_by" -F issue_id="$OID" --silent
            echo "SUCCESS: #$TARGET_NUM is now blocked by #$OTHER_NUM"
            ;;
        --remove-dependency)
            gh api -X DELETE "repos/{owner}/{repo}/issues/$TARGET_NUM/dependencies/blocked_by/$OID" --silent
            echo "SUCCESS: Removed dependency link: #$OTHER_NUM -> #$TARGET_NUM"
            ;;
        --add-sub-issue)
            gh api -X POST "repos/{owner}/{repo}/issues/$TARGET_NUM/sub_issues" -F sub_issue_id="$OID" --silent
            echo "SUCCESS: #$OTHER_NUM added as sub-issue of #$TARGET_NUM"
            ;;
        --remove-sub-issue)
            gh api -X DELETE "repos/{owner}/{repo}/issues/$TARGET_NUM/sub_issue" -f sub_issue_id="$OID" --silent
            echo "SUCCESS: #$OTHER_NUM unlinked from parent #$TARGET_NUM"
            ;;
        esac
    done
	;;

*)
	usage
	;;
esac
