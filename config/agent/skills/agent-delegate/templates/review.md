# Review (blind, non-author)

Use the factual-context and required prompt-closing rules in
[../SKILL.md](../SKILL.md).

```text
Goal: review <diff/files> for <correctness / security / conventions>.
Context: <factual context packet and diff>.
Scope: read-only.
Acceptance: each finding has severity, file:line, and a concrete failure
scenario or violated rule. "No findings" is valid.
Report: findings by severity, one-line verdict, confidence, unchecked areas,
and a path for any long artifact.
<append the required closing block from ../SKILL.md>
```
