---
name: agent-delegate
description: Use before dispatching a subagent or agent CLI, and before starting broad search/log triage, bulk disassembly/decompiler/xref tracing, or non-author review that could be delegated. Covers the trade, lane contracts, worker choice, and rails.
---

# agent-delegate

Host- and model-agnostic. The root is fixed: never select, rank, or judge its own host, model, or effort; judge only the space between the trade and rails, never the **Rails**.

**Check this first.** If your model is below the judgment tier in
[references/models.md](references/models.md), or unknown, read the **Rails**,
then follow [references/checklist.md](references/checklist.md) instead of the
judgment calls between. It is the self-sufficient, countable fallback.

## The trade

Delegation buys exactly three things:

- **Wall-clock parallelism** — N lanes finish in about the time of the longest.
- **Context isolation** — the root never loads what the worker had to read.
- **Non-author evidence** — judgment an author cannot supply about their own work.

It costs one cold start *per lane*: briefing, re-deriving context, and review.
Cold start is paid N times while wall-clock divides by N. A single lane rarely
repays it unless its intermediate material would flood the root; context
isolation alone can then cover the cost. Several lanes almost always repay it.

Ask not "is this big?" but "are there multiple lanes, or context to isolate?"

## When to reach for it

Any one of these is enough:

- **Lanes already exist.** The plan, the ticket graph, or the file layout
  already shows two or more pieces that could run at once. Grinding through
  them serially is the failure this skill exists to prevent.
- **The root's context would flood.** Broad search, log triage, unfamiliar-tree
  inventory, or disassembly/decompiler/xref tracing — work whose intermediate
  material the root must not keep. Delegate bounded reverse traces before loading
  bulk output; require addresses, decisive evidence, conclusions, and open gaps.
- **The author cannot be the judge.** Blind review, or a design that must not
  inherit the root's hypothesis.

None present: work inline. If unsure and it can run beside useful root work,
dispatch it — an idle root is costlier.

## What a lane is

A goal, a scope with an explicit write set, and acceptance criteria that are
runnable or checkable. If you cannot write those three, the work is not
separable yet — that is a decomposition problem, and it stays with the root.

A worker owns its lane end to end: inspect, implement, verify, report. It comes
back to the root for ambiguity, coupling with another lane, a missing
capability, or failed evidence — not for permission to take its next step.

## Briefing

Most of a worker's cold start is re-deriving what the root already knows, so
the root owes it a briefing: the plan slice, the verified facts with their
source paths, the relevant symbols, the constraints, the acceptance criteria,
and what the report must contain. Size it so the worker need not rediscover
ground the root has already covered — under-briefing is not frugality, it is
paying the cold start twice. A worker sent to execute or research one
sub-problem should never have to reconstruct the project's overview to do it;
sparing it that reconstruction is most of why the briefing exists. The
conversation itself never goes in; a
[template](templates/) helps express the lane without dragging in context that
does not belong to it.

**Summarize facts, not inferences.** What you verified goes in with its source.
Your own reading may go in too — it often saves real time — but only labeled as
yours and never mixed into the facts. When you include one, say in the same
breath that it is a starting point and not a boundary: the worker should test
it, look for what would disconfirm it, and report if the evidence points
somewhere else. An unlabeled hypothesis just comes back as the worker's
conclusion.

**Blind lanes go further**, because the withholding is what makes independent
judgment worth buying. For blind review or independent design, brief the facts,
the user's requirements, the constraints, the source paths, and the open
questions — and keep your hypothesis, your suspected cause, and your preferred
answer out entirely, unless testing them *is* the lane. A worker handed your
conclusion returns your conclusion.

Keep one worker process alive for follow-ups within a lane. Start every new
blind lane cold, reusing the facts rather than another worker's answer.

## Choosing a worker

Choose by thinking demand, never volume. Known-pattern selector/xref/call-path tracing is mechanical; reserve stronger workers for ambiguous crypto/protocol semantics or judgment. See [references/models.md](references/models.md).

## Rails

Not judgment calls. These hold however capable the root or the worker is.

- **The root keeps** decomposition, cross-lane judgment, integration, VCS
  writes, remote and outward-facing actions, destructive decisions, final
  acceptance of evidence, and every user-facing claim. Worker output is
  advisory until the root has checked it against the current tree.
- **Concurrent writable workers never share a working copy**, in any VCS —
  disjoint file lists still collide through generated files and build output.
  Give each its own checkout, worktree, or workspace, by whatever mechanism that
  VCS provides; [references/workspaces.md](references/workspaces.md) holds the
  jj recipe. Needing to land in one commit does not make work one lane; the root
  squashes disjoint diffs at integration.
- **The write set is a boundary, not a suggestion.** Only the root knows the
  other lanes, so only it can resolve a collision. A worker needing to touch
  anything outside its write set — its own hand or a child's — stops and reports
  instead of widening its own scope; the root then extends it, re-partitions, or
  takes the work.
- **Nothing blocks indefinitely.** The root supervises wall-clock; a worker
  waiting on a child or an unbounded command stops and reports rather than waits.
- **Workers do not grade their own work.** Runnable checks are
  author-independent even when the author launches them; read-back and judgment
  are not.
- **Never bypass a callee's sandbox or approval protections**, and never grant a
  worker an authorization the root does not itself hold.
- **A CLI worker is a separate session.** Disclose that boundary and get the
  user's opt-in before passing private repository or conversation context to
  one; never silently substitute a CLI for a native worker.
- **A worker may spawn read-only helpers inside its lane**, within whatever
  bound the brief states, and none concurrently if it states none. Writable
  children need the root's authorization, because the root cannot promise
  disjointness for workers it does not know exist.
- **Never invent** a model id, alias, selector, effort value, or flag. Verify it
  against the live route, or state that it is unverified.

## Verification

Reports carry conclusions, `file:line` or command evidence, confidence, and
open questions — never transcripts or file dumps. Long artifacts go to an
agreed path (prefer `$TMPDIR`) and the reply carries that path.

Root-authored work needs a fresh blind, non-author reviewer exactly when
runnable checks cannot prove acceptance — not when the change is large. Size is
the same bad proxy this skill refuses elsewhere: a wide refactor under a passing
suite needs no reviewer, a three-line rule change only a reader can judge does.
The trigger is not optional once it fires, and the reviewer must be blind per
the briefing rule. A non-author root reviews worker output directly, and "No
findings" is a valid result.

## References

Read one only when its condition applies.

| Condition | Reference |
|---|---|
| Native Claude route details are needed | [references/claude-host.md](references/claude-host.md) |
| Native Codex route details are needed | [references/codex-host.md](references/codex-host.md) |
| An agent CLI is selected | [references/cli.md](references/cli.md) |
| Checking your own judgment tier, or the worker model or cost choice is open | [references/models.md](references/models.md) |
| Isolating writable work in a jj repo | [references/workspaces.md](references/workspaces.md) |
| A dispatch failed or repeated an error | [references/failures.md](references/failures.md) |
| The prescriptive form is wanted | [references/checklist.md](references/checklist.md) |
