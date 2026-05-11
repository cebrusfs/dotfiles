---
name: jj-split-commit
description: Programmatically splits large Jujutsu (jj) commits into smaller logical units using file restoration and reverse editing. Avoids interactive TUI.
---

# Splitting a Jujutsu (`jj`) Commit (Agent-Safe Workflow)

## Goal
Decompose a monolithic commit into smaller, independently verifiable commits programmatically, bypassing TUI constraints (`jj split -i`).

## When to Use This Skill
Trigger this skill ONLY when explicitly tasked to split an existing large commit.

## How to Use It (Decomposition Cycle)

### Step 1: Reconnaissance
Identify `COMMIT_TO_SPLIT` and `PARENT_COMMIT`.
```bash
jj diff --stat -r <COMMIT_TO_SPLIT>
```
Plan logical units (e.g., Unit 1: Refactor, Unit 2: Feature).

### Step 2: Stacking Logical Units
Iterate through each planned unit sequentially:

#### A. Initialize Unit
```bash
jj new <PARENT_COMMIT> -m "Part 1: <Unit Name>"
```
*(Subsequent units build on top using `jj new -m "Part N: ..."`)*

#### B. Populate Content
- **Whole Files**: `jj restore --from <COMMIT_TO_SPLIT> path/to/file`
- **Partial Files**: Restore the whole file first, then manually revert unwanted code blocks using file replacement tools.

#### C. Validate Unit
Verify build/tests pass for this specific isolated commit.

### Step 3: Final Integrity Check
Compare the final stacked state against the original monolithic state:
```bash
jj diff --from <COMMIT_TO_SPLIT> --to @
```
- **Success**: Output must be completely empty.
- **Resolution**: If discrepancies exist, fix them and use `jj absorb`.

### Step 4: Cleanup (Authorized Abandon)
Once full equivalence is verified:
```bash
# Re-point bookmarks if applicable:
jj bookmark set <bookmark_name> -r @

# Abandon the old monolithic duplicate:
jj abandon <COMMIT_TO_SPLIT>
```
*Note: Executing `jj abandon` at this specific cleanup step is globally authorized under the skill protocol.*
