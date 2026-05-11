# GitHub Issues Advanced Query Cookbook (Phase 3)

Use these templates only when native `gh` commands or the `gh_issue_manager.sh` wrapper do not provide the specific formatting or filtering you need.

## 1. Advanced Filtering

### Complex Search with Labels
Find issues containing a specific phrase and tagged with multiple specific labels:
```bash
gh issue list --search "out of memory label:high-priority label:bug" --json number,title
```

### Filter by Author and State
```bash
gh issue list --state open --author "octocat" --json number,title
```

---

## 2. Formatting with `jq`

### Markdown Table Export
Generate a formatted Markdown table for a summary report:
```bash
echo -e "| ID | Title | Labels |\n|---|---|---|"
gh issue list -L 10 --json number,title,labels --jq '.[] | "| \(.number) | \(.title) | \(.labels | map(.name) | join(", ")) |"'
```

### Unique Labels Analysis
List all unique labels currently in use across the latest 50 issues:
```bash
gh issue list -L 50 --json labels --jq '.[].labels[].name' | sort -u
```

### TSV Export for Spreadsheets
```bash
gh issue list --json number,title,assignees --jq '.[] | [.number, .title, (.assignees | map(.login) | join(", "))] | @tsv'
```
