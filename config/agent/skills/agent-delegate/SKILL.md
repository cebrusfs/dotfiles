---
name: agent-delegate
description: Use before dispatching a subagent or agent CLI. Covers bounded lanes, isolation, failure recovery, and verification.
---

# agent-delegate

Host- and model-agnostic dispatch contract. The root is a fixed external input:
do not select, rank, or judge its host, model, or effort. Apply the root
responsibilities in [../../global.md](../../global.md); worker output is
advisory until the root accepts or rejects its evidence.

## Route

Inline only when all of these hold:

1. The root already knows the exact target and change.
2. No substantive new context must be loaded.
3. The work is at most one direct action plus one focused check.
4. It has no parallelism, context-isolation, or non-author-evidence value.

This narrow fast path accounts for fixed prompt, scheduling, report-review, and
targeted-verification overhead; do not broaden it with file, line, or
step-count proxies.

Otherwise, delegate if the work forms an independently acceptable lane: an
explicit goal, scope/write set, and acceptance criteria. If break-even is
uncertain and the lane can run concurrently with useful root work, bias to
delegate. Keep coupled or unbounded decisions with the root.

The root owns decomposition, cross-lane judgment, integration, acceptance,
user-facing claims, VCS writes, and outward or destructive decisions. A worker
owns its lane end-to-end: inspect, implement when needed, test or verify, and
report. Escalate to the root on ambiguity, coupling with another lane, missing
capability, or failed evidence; do not re-route work merely for its next step.

Parallelize independent lanes. Writable lanes require disjoint write sets; if
they overlap or share an unresolved interface, keep them together or resolve
the boundary before dispatch. Use a separate non-author reviewer when
independent judgment is required.

Use a surfaced native worker route when it fits; otherwise use an approved CLI
route. The route-specific references own invocation and inheritance details.
If a cost or capability property matters to the decision, verify the effective
route from live dispatch information or its reference before claiming it.
Never bypass callee sandboxing or approval protections.

## Dispatch

Give workers only the plan slice, relevant paths or symbols, constraints,
acceptance criteria, and report contract; default to no full conversation.
Use a matching [template](templates/) when it helps express the lane without
adding unrelated context. The prompt must state:

1. **Goal** — the bounded output and decision it supports.
2. **Scope and write set** — including explicit exclusions.
3. **Acceptance** — runnable commands or checkable facts.
4. **Report** — concise conclusion, evidence, confidence, open questions, and
   a path for any long artifact.

For independent design or blind review, prepare a factual context packet before
dispatch. Include the complete relevant verified facts, user requirements,
constraints, source paths or citations, and open questions so the worker need
not rediscover broad context. Exclude the caller's hypotheses, suspected bugs,
preferred outcome or solution, rationale, and in-progress conclusions unless
the lane explicitly tests them. Label facts, user requirements, open questions,
and any included hypotheses separately; never present an interpretation as a
fact. Persist the packet under the caller's artifact rules when reuse is
planned.

Reuse one live worker process for follow-ups inside the same lane. Start every
new blind lane with a fresh transcript, reusing the factual packet rather than
another worker's answer.

Close every prompt with: "Scope, write set, and plan are approved. Do not ask
for permission. On a genuine blocker, stop with one question and
recommendation; the root will resume. Do not spawn or delegate to another agent
unless the root explicitly authorizes nested delegation."

Keep nested delegation off by default. If authorized, state the execution
reason, child goal, scope/write set, worker model/effort when the route exposes
selectors, concurrency or depth bound, and stop/report condition. When fan-out
is already known, the root dispatches the workers directly. Reserve nesting for
material independent work discovered inside a worker's bounded context.

Load references only when their condition applies. For a native worker route,
read exactly one matching profile:

| Condition | Reference |
|---|---|
| Native Codex route details are needed | [references/codex-host.md](references/codex-host.md) |
| Native Claude route details are needed | [references/claude-host.md](references/claude-host.md) |
| An agent CLI is selected | [references/cli.md](references/cli.md) |
| A route or cost choice needs runtime facts | [references/models.md](references/models.md) |
| Isolating writable work in a jj repo | [references/workspaces.md](references/workspaces.md) |
| A dispatch failed or needs escalation | [references/failures.md](references/failures.md) |

## Verify

- Reports return conclusions, file:line or command evidence, confidence, and
  open questions — never transcripts or file dumps. Long artifacts go to an
  agreed path (prefer `$TMPDIR`); the reply carries the path and summary.
- Runnable checks and real runs are author-independent evidence even when the
  author launches them. Read-back and judgment cannot come from the author:
  the root or a separate worker reviews the patch; workers do not grade their
  own work.
- Root-authored work needs a fresh blind, non-author reviewer only when
  runnable checks cannot prove acceptance. Give that reviewer requirements and
  the diff under the factual-context rule above. "No findings" is valid.
