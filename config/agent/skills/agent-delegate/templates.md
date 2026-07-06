# Worker Prompt Templates

Fill-in templates for the five common dispatch shapes. Every template carries
the dispatch triple (goal/motivation, acceptance criteria, report format) from
[routing.md](routing.md). Rules that apply to all five:

- Acceptance criteria must be runnable commands or checkable facts. If you
  cannot write one, the task is not ready to dispatch — clarify it first.
- Give each worker a disjoint write set; state it explicitly. Read-only tasks
  have write set `none` and report inline; a worker writes an artifact file
  only when the caller names the path.
- `<paths>` scope what the worker may read/touch; wider scope = more tokens
  and less focus.

## Search / exploration (read-only, cheap worker)

```text
Goal: find <what> in <repo/dir>, because <how the answer will be used>.
Scope: read-only. Look under <paths>; also check <naming variants/conventions>.
Acceptance: every claim carries file:line; say explicitly if nothing was
found, and list where you looked.
Report: bullet list of findings (file:line + one-line meaning each),
then open questions. No file dumps. Max ~30 lines.
```

## Implementation (bounded patch, mid worker)

```text
Goal: implement <change> in <files/module>, because <motivation>.
Context: <constraints, invariants, project conventions that apply>.
Write set: only <paths>. Do not touch anything else. Do not commit.
Acceptance: <command(s) that must pass, e.g. `mise run check`, specific
tests>; <observable behavior that must hold>.
Report: files changed with a one-line rationale each, commands you ran
with their results, anything you noticed but deliberately did not do.
```

## Refactor (behavior-preserving, mid worker)

```text
Goal: refactor <what> toward <target shape>, because <motivation>.
Behavior must not change: <tests/commands that prove it —
run them before and after>.
Write set: only <paths>. Do not commit. If preserving behavior requires
touching files outside the write set, stop and report instead.
Acceptance: before/after check output identical; <lint/check command> passes.
Report: what moved where and why, before/after command results, any
behavior-relevant thing you were forced to touch.
```

## Research (web or docs, cheap-to-mid worker)

```text
Goal: answer <question>, because <decision it feeds>.
Method: verify against primary sources (official docs, release notes,
repos); bring concrete numbers (versions, dates, stars, pricing) with
their source. Distinguish verified facts from inference; never invent
names, versions, or APIs — mark gaps as "not found".
Acceptance: each key claim has a source; the question is answered with a
recommendation, or the blockers to answering are listed.
Report: recommendation first, then evidence table (claim / number / source),
then open questions. Write full notes to <file path>; reply with the path
and a 3-line summary.
```

## Review (blind, strong worker, fresh context)

```text
Goal: review <diff/files> for <correctness / security / conventions>.
Context: <what the change is supposed to do — the requirements, NOT the
author's rationale, suspected bugs, or preferred outcome>.
Scope: read-only.
Acceptance: every finding has severity (high/medium/low), file:line, and a
concrete failure scenario or rule it violates. "No findings" is an
acceptable result — do not manufacture issues.
Report: findings ordered by severity, then a one-line overall verdict,
then confidence and what you could not check.
```

## Verification / read-back (fresh context, any tier fits the artifact)

```text
Goal: verify <deliverable> against these acceptance criteria, as a fresh
reader with no knowledge of how it was produced:
<numbered criteria — commands to run or facts to check>.
Scope: read-only (plus running the listed commands).
Report: per criterion — pass/fail with evidence (command output or
file:line); then anything incomplete, contradictory, or unresolved
(broken cross-references, TODOs, placeholder text).
```
