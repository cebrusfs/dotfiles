# Review (blind, non-author)

Blind means the caller's hypothesis, suspected cause, and preferred answer stay
out — see the briefing rule in [../SKILL.md](../SKILL.md). The closing block
below is the one from [../references/checklist.md](../references/checklist.md).

```text
Goal: review <diff/files> for <correctness / security / conventions>.
Facts: <verified facts with source paths, requirements, constraints, open
questions, and the diff>. No hypotheses about what is wrong.
Scope: read-only.
Acceptance: each finding has severity, file:line, and a concrete failure
scenario or violated rule. "No findings" is valid.
Report: findings by severity, one-line verdict, confidence, unchecked areas,
and a path for any long artifact.

The goal, scope, write set, and acceptance above are approved; choose your own
approach within them and do not ask for permission to proceed. Stop and report
before touching anything outside the write set. On a genuine blocker, stop with
one question and a recommendation; the root will resume. Do not spawn a
writable worker, and do not wait indefinitely on anything — if you cannot bound
a wait, stop and report instead.
```
