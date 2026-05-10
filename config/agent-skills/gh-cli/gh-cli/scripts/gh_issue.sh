#!/bin/bash
#
# gh_issue.sh - Issue CRUD and label management wrapper for GitHub CLI
#
# Wraps common `gh issue` operations so agents don't have to compose raw commands.
# All output uses --json / --jq for deterministic parsing.
#
# TRACKING: Wraps `gh issue` until gh CLI gains full native API parity.

set -euo pipefail

usage() {
	echo "Usage: $0 <operation> <repo> [args...]"
	echo ""
	echo "CRUD:"
	echo "  create      <repo> <title> <body> [<label1,label2,...>] [<assignee>]"
	echo "  list        <repo> [<state=open>] [<limit=20>] [<label_filter>]"
	echo "  view        <repo> <issue_num>"
	echo "  close       <repo> <issue_num> [<reason=completed>]    reason: completed|not_planned"
	echo "  reopen      <repo> <issue_num>"
	echo ""
	echo "Labels:"
	echo "  add-label   <repo> <issue_num> <label1,label2,...>"
	echo "  remove-label <repo> <issue_num> <label1,label2,...>"
	exit 1
}

if [ $# -lt 2 ]; then
	usage
fi

COMMAND="$1"
REPO="$2"

check_auth() {
	if ! gh auth status &>/dev/null; then
		echo "Error: gh CLI is not authenticated. Please run 'gh auth login'." >&2
		exit 1
	fi
}

check_auth

case "${COMMAND}" in
create)
	TITLE="${3:-}"
	BODY="${4:-}"
	LABELS="${5:-}"
	ASSIGNEE="${6:-}"

	if [ -z "${TITLE}" ] || [ -z "${BODY}" ]; then
		echo "Error: create requires <title> and <body>." >&2
		exit 1
	fi

	EXTRA_ARGS=()
	[ -n "${LABELS}" ] && EXTRA_ARGS+=(--label "${LABELS}")
	[ -n "${ASSIGNEE}" ] && EXTRA_ARGS+=(--assignee "${ASSIGNEE}")

	gh issue create -R "${REPO}" \
		--title "${TITLE}" \
		--body "${BODY}" \
		"${EXTRA_ARGS[@]}" \
		--json number,url \
		--jq '"Created #\(.number): \(.url)"'
	;;

list)
	STATE="${3:-open}"
	LIMIT="${4:-20}"
	LABEL_FILTER="${5:-}"

	EXTRA_ARGS=()
	[ -n "${LABEL_FILTER}" ] && EXTRA_ARGS+=(--label "${LABEL_FILTER}")

	gh issue list -R "${REPO}" \
		--state "${STATE}" \
		--limit "${LIMIT}" \
		"${EXTRA_ARGS[@]}" \
		--json number,title,state,labels,assignees \
		--jq '.[] | {number, title, state, labels: [.labels[].name], assignees: [.assignees[].login]}'
	;;

view)
	ISSUE_NUM="${3:-}"
	if [ -z "${ISSUE_NUM}" ]; then
		echo "Error: view requires <issue_num>." >&2
		exit 1
	fi

	gh issue view "${ISSUE_NUM}" -R "${REPO}" \
		--json number,title,state,body,labels,assignees,createdAt,updatedAt \
		--jq '{number, title, state, labels: [.labels[].name], assignees: [.assignees[].login], createdAt, updatedAt, body}'
	;;

close)
	ISSUE_NUM="${3:-}"
	REASON="${4:-completed}"

	if [ -z "${ISSUE_NUM}" ]; then
		echo "Error: close requires <issue_num>." >&2
		exit 1
	fi

	gh issue close "${ISSUE_NUM}" -R "${REPO}" --reason "${REASON}"
	echo "Closed #${ISSUE_NUM} (reason: ${REASON})"
	;;

reopen)
	ISSUE_NUM="${3:-}"
	if [ -z "${ISSUE_NUM}" ]; then
		echo "Error: reopen requires <issue_num>." >&2
		exit 1
	fi

	gh issue reopen "${ISSUE_NUM}" -R "${REPO}"
	echo "Reopened #${ISSUE_NUM}"
	;;

add-label)
	ISSUE_NUM="${3:-}"
	LABELS="${4:-}"

	if [ -z "${ISSUE_NUM}" ] || [ -z "${LABELS}" ]; then
		echo "Error: add-label requires <issue_num> and <labels>." >&2
		exit 1
	fi

	gh issue edit "${ISSUE_NUM}" -R "${REPO}" --add-label "${LABELS}"
	echo "Added labels [${LABELS}] to #${ISSUE_NUM}"
	;;

remove-label)
	ISSUE_NUM="${3:-}"
	LABELS="${4:-}"

	if [ -z "${ISSUE_NUM}" ] || [ -z "${LABELS}" ]; then
		echo "Error: remove-label requires <issue_num> and <labels>." >&2
		exit 1
	fi

	gh issue edit "${ISSUE_NUM}" -R "${REPO}" --remove-label "${LABELS}"
	echo "Removed labels [${LABELS}] from #${ISSUE_NUM}"
	;;

*)
	echo "Unknown operation: ${COMMAND}" >&2
	usage
	;;
esac
