---
name: agent-delegate
description: Use before dispatching a subagent or agent CLI. Covers role-first cost routing, bounded prompts, isolation, failure recovery, and verification.
---

# agent-delegate

Cost-aware routing and dispatch contract for delegated workers. Apply the lead
responsibilities in [../../global.md](../../global.md): worker output is
advisory until the lead accepts or rejects the evidence.

## Route

Choose by role before volume. Decide these axes independently:

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
worker prompt/report, lead verification, and context the lead retains. A
verified materially cheaper capable worker changes the default: a judge-tier
lead dispatches every lower-tier execution role to it, even for a tiny patch or
one command. Current Sol-lead/Terra-worker is one example, not shared policy.

| Situation | Route |
|---|---|
| Judge-tier lead; scan, explore, implement, or verify | Dispatch the cheapest verified capable worker. |
| No verified cheaper capable worker | Use the global volume gate as the fallback. |
| User requests a cheaper/smaller/dumber worker | Use the cheapest capable verified native tier; if unavailable, use a verified CLI tier only after its boundary is approved, otherwise disclose the limit and work inline. |
| Volume gate exceeded | Use the cheapest capable verified worker; return conclusions and evidence only. |
| Lead-authored work fully proved by runnable checks | No independent reviewer; route routine check execution under this tier policy. |
| Lead-authored work needing judgment or read-back | Fresh, blind, non-author reviewer. |
| Ambiguous or taste-shaped decision | Judge-tier model or the user. |

| Role | Work | Minimum capability; never force an upgrade |
|---|---|---|
| scan | bounded evidence gathering against a known question | cheap; increase only for demonstrated task complexity |
| explore | open-ended solution, architecture, or hypothesis search | cheapest verified capable tier; do not assume strong |
| implement | bounded patch from an approved high-level plan | mid |
| verify | runnable checks or factual read-back | cheap to mid |
| review | non-mechanical correctness, security, conventions | strong |
| judge | ambiguous or taste-shaped choice | judge-tier or user |

Apply the global responsibility through final acceptance, not routine tool
execution or authorship. Workers inspect, edit their bounded write set,
diagnose, test, and verify; the lead accepts or rejects their evidence. A
read-only explore/plan dispatch never satisfies implementation or verification:
at every phase transition, reroute the next role independently. Bounded file
edits remain permitted under the global VCS safety policy.

For a large diff, use a strong reviewer so the lead receives findings instead
of retaining the diff. For a plan the lead judges too complex, dispatch a
parallel cross-family plan check (judge-tier peer). Read
[references/models.md](references/models.md) only when the runtime, exact
model id, or judge-tier peer is not already fixed.

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

At every phase transition, repeat Route and dispatch the role again; do not
reuse explore or plan allocation for implementation or verification. Give each
worker a bounded prompt and a disjoint write set. Start from the matching
[templates/](templates/) file — search, implementation, refactor, research,
review, or verification — and carry the dispatch triple:

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
- Tests and real runs are author-independent evidence even when the patch
  author launches them; route routine execution under Route. Read-back and
  judgment never come from the author: the lead or a separate worker reviews a
  worker's patch; a worker never grades its own work.
- A blind reviewer gets requirements and the diff — never the author's
  rationale, suspected bugs, or preferred outcome. "No findings" is valid.
