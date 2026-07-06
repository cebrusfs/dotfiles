---
name: agent-delegate
description: Use before dispatching a subagent or agent CLI for large-context work or author-independent review. Covers cost-aware routing, bounded prompts, isolation, failure recovery, and verification.
---

# agent-delegate

Cost-aware routing and dispatch contract for delegated workers. Global and
repo guides own the delegation triggers, do-not-delegate list, and caller
ownership. Worker output stays advisory until the lead validates it against
the current state. Delegation never transfers final judgment, VCS writes,
remote actions, or user-facing claims from the lead.

## Route

Decide two axes independently before choosing a worker:

1. **Execution reason** — latency/parallelism, context isolation, or independent
   judgment.
2. **Cost tier** — inline lead, same-tier worker, or a verified lower-cost
   model/effort through a native or CLI selector.

A native subagent is not inherently cheaper or same-tier. Resolve its effective
model and effort from the live dispatch schema, selected custom agent, configured
subagent defaults, or documented inheritance. If that path is not verifiable,
do not claim a model-cost saving. Context inheritance controls token volume, not
model strength or per-token price.

Compare weighted cost: tokens each context ingests × model cost, including the
worker prompt/report, lead verification, and context the lead retains for
later turns. Do not spawn when both contexts ingest the same material without
enough latency, isolation, independent-judgment, or verified cost value.

| Situation | Route |
|---|---|
| Non-author work below the volume gate on a strong lead | Work inline. |
| User requests a cheaper/smaller/dumber worker | Use the cheapest capable verified native tier; if unavailable, use a verified CLI tier only after its boundary is approved, otherwise disclose the limit and work inline. |
| Volume gate exceeded | Use the cheapest capable verified worker; return conclusions and evidence only. |
| Expensive judge-tier lead doing a lower-tier role | Downshift only through a verified model/effort route. |
| Lead-authored work fully proved by runnable checks | Run the checks; no reviewer. |
| Lead-authored work needing judgment or read-back | Fresh, blind, non-author reviewer. |
| Ambiguous or taste-shaped decision | Judge-tier model or the user. |

| Role | Work | Cheapest fitting tier when selectable |
|---|---|---|
| scan | bounded evidence gathering against a known question | cheap to mid |
| explore | open-ended solution, architecture, or hypothesis search | strong |
| implement | bounded patch from an approved high-level plan | mid |
| verify | runnable checks or factual read-back | cheap to mid |
| review | non-mechanical correctness, security, conventions | strong |
| judge | ambiguous or taste-shaped choice | judge-tier or user |

For a large diff, use a strong reviewer so the lead receives findings instead
of retaining the diff. For a plan the lead judges too complex, dispatch a
parallel cross-family plan check (judge-tier peer). When the runtime, exact
model id, or judge-tier peer is not already fixed, read
[references/models.md](references/models.md).

## Dispatch

Detect the host from its surfaced native tools, then read exactly one profile:

| Current host | Required profile |
|---|---|
| Codex with `collaboration.spawn_agent` | [references/codex-host.md](references/codex-host.md) |
| Claude Code with a native subagent tool | [references/claude-host.md](references/claude-host.md) |
| Any host without a native worker API | [references/cli.md](references/cli.md) |

The profile owns native-versus-CLI routing and native context inheritance. Load
[references/models.md](references/models.md) only when a model or price choice
remains. Before claiming a downshift, verify both that the route accepts the
selector and that the selected model/effort is lower cost. Never bypass any
callee sandbox or approval protection.

Give each worker a bounded prompt and a disjoint write set. Start from the
matching [templates/](templates/) file — search, implementation, refactor,
research, review, or verification — and carry the dispatch triple:

1. **Goal and motivation** — output and the decision it feeds.
2. **Acceptance criteria** — runnable commands or checkable facts; clarify an
   uncheckable criterion before dispatch.
3. **Report format** — concise return shape plus a path for long artifacts.

Close every prompt with: "Scope, write set, and plan are approved. Do not ask
for permission. On a genuine blocker, stop with one question and
recommendation; the lead will resume. Do not spawn or delegate to another agent
unless the lead explicitly authorizes nested delegation." Only the lead decides
whether another delegation layer is worth its cost.

Keep nested delegation off by default. If the lead authorizes it, name the
allowed model/effort, execution reason, child scope and write set, concurrency
or depth bound, and stop/report condition. When fan-out is known before the
first dispatch, the lead dispatches those workers directly; reserve a nested
layer for material independent work discovered only inside worker context.

Load the remaining references only when their condition applies:

| Condition | Reference |
|---|---|
| An agent CLI is selected | [references/cli.md](references/cli.md) |
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

## Lessons

- 2026-07-24: Once authorized, delegate read-only review early for cross-repo
  work above the volume gate. (evidence: Aureus/dotfiles hook refactor)
