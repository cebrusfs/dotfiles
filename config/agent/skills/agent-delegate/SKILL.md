---
name: agent-delegate
description: Use before dispatching any worker (a native subagent or another agent's CLI), or when deciding whether a lane may go to Codex to save Claude quota. Owns worker scope, owner-approved routes, the Codex CLI recipe, and authority boundaries.
allowed-tools:
  - Read(~/.claude/skills/agent-delegate/**)
  - Read(~/**/config/agent/skills/agent-delegate/**)
---

# agent-delegate

The always-loaded guidance decides when a worker may be dispatched. This skill
owns how: who decides, where the worker runs, what it receives, and what the
root keeps.

## Roles

The root decides. A worker gives a second opinion or carries out a decision the
root has already made; it does not choose the design, widen its scope, or speak
to the user. Ask for a second opinion before deciding when the choice is
consequential and an independent view could change it; for a blind review,
leave your own answer out of the brief.

## Routes

Quota picks the runtime: the owner's Codex quota is larger than the Claude
quota, and a native Claude subagent bills the lead's quota.

| Lead | Lane | Worker |
|---|---|---|
| Claude | Bulk reading, research, mechanical or bounded edits, independent review | Codex CLI; see [codex-cli.md](references/codex-cli.md) |
| Claude | Needs this conversation's context or a Claude-only tool, and the user asked | Native subagent with an explicit `model` |
| Codex | Any the user asked for | Native worker |
| Antigravity | Any the user asked for | Native worker; routes unverified |

Codex models (owner-approved; `gpt-6.1-sol` exercised through the CLI, all
three listed by the live Codex catalog, 2026-11-16, codex-cli 0.169.0):

| Work | Model | Effort |
|---|---|---|
| Mechanical work from a spec | `gpt-6-luna` | `low` |
| Bounded implementation, research, factual verification | `gpt-6.1-sol` | configured default |
| Blind or non-mechanical review, second opinions | `gpt-6.1-sol` | `xhigh` |
| Demonstrated need beyond Sol | `gpt-6-astra` | explicit |

Claude aliases, when a native subagent is requested: `haiku` for known-pattern
work, `sonnet` for bounded implementation, `opus` for non-mechanical review. A
subagent without an explicit model inherits the lead's. Do not use Luna or
`haiku` for ambiguous decisions or review. Check a selector against the running
client before relying on it, and do not claim a saving from a worker's name
alone.

## Lane contract

Give each worker a goal, an explicit read-only scope or bounded write set,
checkable acceptance criteria, the verified facts with their source paths, and
the evidence wanted back. Label inferences as inferences. Large artifacts go in
`$TMPDIR`. Reuse a worker for follow-ups within its lane; start an independent
review with fresh context.

## Authority and isolation

- The root keeps instruction and skill reading, decomposition, integration,
  cross-lane decisions, VCS writes, remote and outward-facing actions,
  destructive decisions, final acceptance, and user-facing claims. It checks
  worker evidence against the current state before relying on it.
- A CLI worker is a separate session at another vendor. The owner has approved
  sending repository and task context to Codex from personal repositories;
  anywhere else, or when unsure whether a repository is personal, disclose the
  boundary and get opt-in first. Never pass credentials or private data the
  lane does not need.
- Workers stay inside their write set and report before expanding it. They
  receive no authority beyond the root's, and sandbox and approval protections
  stay on.
- Concurrent writable workers need separate working copies, even with disjoint
  file lists; for jj see the `jj` skill's
  [workspaces reference](../jj/references/workspaces.md). One writable worker
  may use the root's working copy while the root does not edit.
- The root supervises waits and bounds wall-clock time.

## Verification

Check acceptance with relevant commands and direct read-back. If a required
independent review is unavailable, report the gap; do not claim it happened.
Lessons are persisted only by the root, through the `learn` skill.
