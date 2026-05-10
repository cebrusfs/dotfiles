# GitHub CLI — Reference Examples

Advanced patterns for filtering, jq formatting, GraphQL, and PR queries.

## 1. Advanced Issue Filtering

### Filter Issues by Label and State
Find all closed `bug` issues in a repository:
```bash
gh issue list -R <owner>/<repo> --state closed --label "bug" --json number,title,closedAt
```

### Search Issues by Author
Get all open issues authored by a specific developer:
```bash
gh issue list -R <owner>/<repo> --author "octocat" --json number,title
```

### Search Issues with Complex Queries (using `--search`)
Find issues containing a specific phrase and tagged with both `high-priority` and `bug`:
```bash
gh issue list -R <owner>/<repo> --search "out of memory label:high-priority label:bug" --json number,title
```

---

## 2. Custom Output Formatting with `jq`

### Extract a Simple Flat List of Labels
List all unique labels present in the last 30 issues:
```bash
gh issue list -R <owner>/<repo> -L 30 --json labels --jq '.[].labels[].name' | sort -u
```

### Format Issues list into a Markdown Table
Generate a nicely formatted markdown table of the latest 5 issues:
```bash
echo -e "| ID | Title | State |\n|---|---|---|"
gh issue list -R <owner>/<repo> -L 5 --json number,title,state --jq '.[] | "| \(.number) | \(.title) | \(.state) |"'
```

### Export Issues with Assigned Developers to TSV
Ideal for copy-pasting into sheets/docs:
```bash
gh issue list -R <owner>/<repo> --json number,title,assignees --jq '.[] | [.number, .title, (.assignees | map(.login) | join(", "))] | @tsv'
```

---

## 3. Querying Pull Request Metadata

### List PRs Targeting a Specific Base Branch (e.g. `main`)
```bash
gh pr list -R <owner>/<repo> --base main --json number,title,headRefName
```

### Check Open PRs that Have Failing Status Checks
```bash
gh pr list -R <owner>/<repo> --state open --json number,title,statusCheckRollup --jq '.[] | select(.statusCheckRollup.state == "FAILURE") | [.number, .title] | @tsv'
```

### List All Merged PRs in the Last 7 Days
```bash
gh pr list -R <owner>/<repo> --state merged --json number,title,mergedAt --jq '.[] | select(.mergedAt > (now - 7*24*3600 | strflocaltime("%Y-%m-%dT%H:%M:%SZ"))) | [.number, .title, .mergedAt] | @tsv'
```

---

## 4. GraphQL (ad-hoc, no script)

Use only when REST endpoints are insufficient. Relationships are better handled via `gh_issue_manager.sh`.

```bash
# Fetch node IDs (needed for mutations)
gh api graphql -f query='{ repository(owner:"X",name:"Y"){ a:issue(number:1){id} b:issue(number:2){id} } }'

# Mutations
#   addBlockedBy(input:{issueId:"<ID>", blockingIssueId:"<ID>"})
#   addSubIssue(input:{issueId:"<PARENT_ID>", subIssueId:"<CHILD_ID>", replaceParent:true})
#   ⚠️ addSubIssue without replaceParent:true fails if child already has a parent

# Read connections (require first:/last: for pagination)
#   issue { parent{number} blockedBy(first:10){nodes{number}} subIssues(first:10){nodes{number}} subIssuesSummary{completed total} }
```
