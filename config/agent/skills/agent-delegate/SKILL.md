---
name: agent-delegate
description: Use before dispatching a subagent or agent CLI for large-context work or author-independent review. Covers cost-aware routing, bounded prompts, isolation, failure recovery, and verification.
---

# agent-delegate

Cost-aware routing and dispatch contract for delegated workers. Global and
repo guides own the delegation triggers, do-not-delegate list, and caller
ownership. Worker output stays advisory until the lead validates it against
the current state.

## Route

Compare weighted cost: tokens each context ingests × model cost, including the
worker prompt/report, lead verification, and context the lead retains for
later turns. Do not spawn when both contexts ingest the same material without
enough model-cost savings.

| Situation | Route |
|---|---|
| Non-author work below the volume gate on a strong lead | Work inline. |
| Volume gate exceeded | Cheapest capable worker; conclusions and evidence only. |
| Expensive judge-tier lead doing a lower-tier role | Downshift to a cheaper worker. |
| Lead-authored work fully proved by runnable checks | Run the checks; no reviewer. |
| Lead-authored work needing judgment or read-back | Fresh, blind, non-author reviewer. |
| Ambiguous or taste-shaped decision | Judge-tier model or the user. |

| Role | Work | Cheapest fitting strength |
|---|---|---|
| explore | broad read-only scans, logs, docs | cheap |
| implement | bounded patch with explicit acceptance | mid |
| verify | runnable checks or factual read-back | cheap to mid |
| review | non-mechanical correctness, security, conventions | strong |
| judge | ambiguous or taste-shaped choice | judge-tier or user |

For a large diff, use a strong reviewer so the lead receives findings instead
of retaining the diff. For a plan the lead judges too complex, dispatch a
parallel cross-family plan check (judge-tier peer). When the runtime, exact
model id, or judge-tier peer is not already fixed, read
[references/models.md](references/models.md).

## Dispatch

The default worker is the Codex CLI, non-interactive (never a TUI):

```bash
codex -a never exec -m <model> -s <read-only|workspace-write> [-C <dir>] [-o <file>] "<prompt>"
```

Never use `danger-full-access` or approval-bypass flags; never bypass any
callee's sandbox or approval protections. For resume, output-capture caveats,
or another runtime, read [references/cli.md](references/cli.md).

Give each worker a bounded prompt and a disjoint write set. Start from the
matching [templates/](templates/) file — search, implementation, refactor,
research, review, or verification — and carry the dispatch triple:

1. **Goal and motivation** — output and the decision it feeds.
2. **Acceptance criteria** — runnable commands or checkable facts; clarify an
   uncheckable criterion before dispatch.
3. **Report format** — concise return shape plus a path for long artifacts.

Close every prompt with: "Scope, write set, and plan are approved. Do not ask
for permission. On a genuine blocker, stop with one question and
recommendation; the lead will resume." A dispatched worker does not
recursively delegate unless its prompt says so.

Load the remaining references only when their condition applies:

| Condition | Reference |
|---|---|
| Isolating writable work in a jj repo | [references/workspaces.md](references/workspaces.md) |
| A dispatch failed or needs escalation | [references/failures.md](references/failures.md) |

## Verify

- Reports return conclusions, file:line or command evidence, confidence, and
  open questions — never transcripts or file dumps. Long artifacts go to an
  agreed path (prefer `$TMPDIR`); the reply carries the path and a summary.
- Tests and real runs are author-independent evidence even when the author
  launches them. Read-back and judgment never come from the author: the lead
  may review a worker's patch; a worker never grades its own work.
- A blind reviewer gets requirements and the diff — never the author's
  rationale, suspected bugs, or preferred outcome. "No findings" is valid.
