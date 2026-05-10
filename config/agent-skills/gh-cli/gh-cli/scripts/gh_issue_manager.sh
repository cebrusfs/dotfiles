#!/bin/bash
#
# gh_issue_manager.sh - Advanced issue manipulation for GitHub CLI (gh)
#
# Covers operations like safely managing native issue dependencies / sub-issues
# via the GitHub REST API. Single-repo only (cross-repo intentionally unsupported
# — callers can hit `gh api` directly if needed).
#
# TRACKING: This script is a workaround until native support is added to gh CLI.
# ISSUE: https://github.com/cli/cli/issues/10298
#

set -euo pipefail

usage() {
	echo "Usage: $0 <operation> <repo> <issue_num> [<other_issue_num>]"
	echo ""
	echo "Read operations (3 args) — structured JSON output:"
	echo "  --list-blocked-by   <repo> <issue_num>                       Issues blocking this one"
	echo "  --list-blocking     <repo> <issue_num>                       Issues this one blocks"
	echo "  --list-sub-issues   <repo> <issue_num>                       Sub-issues of this issue"
	echo "  --show-parent       <repo> <issue_num>                       Parent number + sub-issue summary"
	echo ""
	echo "Write operations (4 args):"
	echo "  --add-dependency    <repo> <issue_num> <blocking_issue_num>  Mark issue as blocked by another"
	echo "  --remove-dependency <repo> <issue_num> <blocking_issue_num>  Remove the 'blocked by' link"
	echo "  --add-sub-issue     <repo> <parent_num> <child_num>          Set child as sub-issue of parent"
	echo "  --remove-sub-issue  <repo> <parent_num> <child_num>          Remove the parent/child link"
	exit 1
}

if [ $# -lt 3 ]; then
	usage
fi

COMMAND="$1"
REPO="$2"
ISSUE_NUM="$3"
OTHER_ISSUE_NUM="${4:-}"

# Helper to check authentication
check_auth() {
	if ! gh auth status &>/dev/null; then
		echo "Error: gh CLI is not authenticated. Please run 'gh auth login'."
		exit 1
	fi
}

# Helper to fetch the global integer ID for an issue in ${REPO}
fetch_issue_id() {
	local num="$1"
	local id
	id=$(gh api "repos/${REPO}/issues/${num}" --jq '.id')

	if [ -z "${id}" ] || [ "${id}" == "null" ]; then
		echo "Error: Could not retrieve issue ID for ${REPO}#${num}." >&2
		exit 1
	fi
	echo "${id}"
}

check_auth

case "${COMMAND}" in
--list-blocked-by)
	gh api "repos/${REPO}/issues/${ISSUE_NUM}/dependencies/blocked_by" \
		-H "Accept: application/vnd.github+json" \
		--jq '[.[] | {number, title, state}]'
	;;

--list-blocking)
	gh api "repos/${REPO}/issues/${ISSUE_NUM}/dependencies/blocking" \
		-H "Accept: application/vnd.github+json" \
		--jq '[.[] | {number, title, state}]'
	;;

--list-sub-issues)
	gh api "repos/${REPO}/issues/${ISSUE_NUM}/sub_issues" \
		-H "Accept: application/vnd.github+json" \
		--jq '[.[] | {number, title, state}]'
	;;

--show-parent)
	gh api "repos/${REPO}/issues/${ISSUE_NUM}" \
		-H "Accept: application/vnd.github+json" \
		--jq '{parent: .parent.number, sub_issues_summary: .sub_issues_summary}'
	;;

--add-dependency)
	BLOCKING_ID=$(fetch_issue_id "${OTHER_ISSUE_NUM}")
	# TODO: Replace with 'gh issue edit --add-dependency' once cli/cli#10298 is resolved.
	gh api -X POST "repos/${REPO}/issues/${ISSUE_NUM}/dependencies/blocked_by" \
		-H "Accept: application/vnd.github+json" \
		-F issue_id="${BLOCKING_ID}" --silent
	echo "Dependency added: ${REPO}#${ISSUE_NUM} blocked by ${REPO}#${OTHER_ISSUE_NUM}"
	;;

--remove-dependency)
	BLOCKING_ID=$(fetch_issue_id "${OTHER_ISSUE_NUM}")
	gh api -X DELETE "repos/${REPO}/issues/${ISSUE_NUM}/dependencies/blocked_by/${BLOCKING_ID}" \
		-H "Accept: application/vnd.github+json" --silent
	echo "Dependency removed: ${REPO}#${ISSUE_NUM} no longer blocked by ${REPO}#${OTHER_ISSUE_NUM}"
	;;

--add-sub-issue)
	CHILD_ID=$(fetch_issue_id "${OTHER_ISSUE_NUM}")
	gh api -X POST "repos/${REPO}/issues/${ISSUE_NUM}/sub_issues" \
		-H "Accept: application/vnd.github+json" \
		-F sub_issue_id="${CHILD_ID}" --silent
	echo "Sub-issue added: ${REPO}#${OTHER_ISSUE_NUM} is now a sub-issue of ${REPO}#${ISSUE_NUM}"
	;;

--remove-sub-issue)
	CHILD_ID=$(fetch_issue_id "${OTHER_ISSUE_NUM}")
	# DELETE path is singular /sub_issue per GitHub REST API
	gh api -X DELETE "repos/${REPO}/issues/${ISSUE_NUM}/sub_issue" \
		-H "Accept: application/vnd.github+json" \
		-f sub_issue_id="${CHILD_ID}" --silent
	echo "Sub-issue removed: ${REPO}#${OTHER_ISSUE_NUM} unlinked from ${REPO}#${ISSUE_NUM}"
	;;

*)
	echo "Unknown command: ${COMMAND}"
	usage
	;;
esac
