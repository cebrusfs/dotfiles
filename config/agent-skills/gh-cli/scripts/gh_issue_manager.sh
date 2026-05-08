#!/bin/bash
#
# gh_issue_manager.sh - Advanced issue manipulation for GitHub CLI (gh)
#
# Covers operations like safely managing native issue dependencies via the GitHub REST API.
#
# TRACKING: This script is a workaround until native support is added to gh CLI.
# ISSUE: https://github.com/cli/cli/issues/10298
#

set -euo pipefail

usage() {
	echo "Usage: $0 [operation] [repo] [issue_number] [args...]"
	echo ""
	echo "Operations:"
	echo "  --add-dependency <repo> <issue_num> <blocking_repo> <blocking_issue_num>  Adds a native 'blocked by' dependency"
	echo "  --remove-dependency <repo> <issue_num> <blocking_repo> <blocking_issue_num> Removes a 'blocked by' dependency"
	exit 1
}

if [ $# -lt 3 ]; then
	usage
fi

COMMAND="$1"
REPO="$2"
ISSUE_NUM="$3"
shift 3

# Helper to check authentication
check_auth() {
	if ! gh auth status &>/dev/null; then
		echo "Error: gh CLI is not authenticated. Please run 'gh auth login'."
		exit 1
	fi
}

check_auth

case "${COMMAND}" in
--add-dependency)
	if [ $# -lt 2 ]; then
		echo "Error: Missing blocking repository and issue number."
		usage
	fi
	BLOCKING_REPO="$1"
	BLOCKING_ISSUE_NUM="$2"

	# 1. Fetch the global integer ID of the blocking issue
	BLOCKING_ISSUE_ID=$(gh api "repos/${BLOCKING_REPO}/issues/${BLOCKING_ISSUE_NUM}" --jq '.id')

	if [ -z "${BLOCKING_ISSUE_ID}" ] || [ "${BLOCKING_ISSUE_ID}" == "null" ]; then
		echo "Error: Could not retrieve issue ID for ${BLOCKING_REPO}#${BLOCKING_ISSUE_NUM}."
		exit 1
	fi

	# 2. Add the dependency using the native GitHub REST API
	# TODO: Replace with 'gh issue edit --add-dependency' once cli/cli#10298 is resolved.
	gh api -X POST "repos/${REPO}/issues/${ISSUE_NUM}/dependencies/blocked_by" \
		-H "Accept: application/vnd.github+json" \
		-f issue_id="${BLOCKING_ISSUE_ID}" --silent

	echo "Dependency successfully added!"
	;;

--remove-dependency)
	if [ $# -lt 2 ]; then
		echo "Error: Missing blocking repository and issue number."
		usage
	fi
	BLOCKING_REPO="$1"
	BLOCKING_ISSUE_NUM="$2"

	# 1. Fetch the global integer ID of the blocking issue
	BLOCKING_ISSUE_ID=$(gh api "repos/${BLOCKING_REPO}/issues/${BLOCKING_ISSUE_NUM}" --jq '.id')

	if [ -z "${BLOCKING_ISSUE_ID}" ] || [ "${BLOCKING_ISSUE_ID}" == "null" ]; then
		echo "Error: Could not retrieve issue ID for ${BLOCKING_REPO}#${BLOCKING_ISSUE_NUM}."
		exit 1
	fi

	# 2. Remove the dependency using the native GitHub REST API
	# TODO: Replace with 'gh issue edit --remove-dependency' once cli/cli#10298 is resolved.
	gh api -X DELETE "repos/${REPO}/issues/${ISSUE_NUM}/dependencies/blocked_by/${BLOCKING_ISSUE_ID}" \
		-H "Accept: application/vnd.github+json" --silent

	echo "Dependency successfully removed!"
	;;

*)
	echo "Unknown command: ${COMMAND}"
	usage
	;;
esac
