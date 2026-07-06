# Worker Model and Runtime Mapping

Read this once the worker route is fixed. [../SKILL.md](../SKILL.md) owns the
delegation decision, dispatch, and native-versus-CLI routing; this file maps
verified worker selectors on that route, and defines the judgment tier that
decides whether the root improvises or follows the fallback procedure. It never
selects, evaluates, or changes the root agent.

## Judgment tier

[../SKILL.md](../SKILL.md) leaves routing to the root's judgment and keeps only
its Rails hard. That works for a root that can actually price cost against
value. A root at or above this tier improvises; a root below it works from
[checklist.md](checklist.md), which converts the same policy into countable
steps.

| Runtime | At or above | Below |
|---|---|---|
| Claude | `opus`, `fable` | `sonnet`, `haiku` |
| Codex | `gpt-5.6-sol` | `gpt-5.6-terra`, `gpt-5.6-luna` |

Decide from your own model identity as the runtime reports it, not from your
impression of your own capability — an agent's self-assessment is exactly the
judgment this switch exists to avoid relying on. If the runtime does not
surface the model, treat yourself as below the tier.

This table rates a root's *routing* judgment only. It is unrelated to the
worker-cost mappings below, and the root's model is a given input — never a
selection (see [../SKILL.md](../SKILL.md)). Placement of `fable` here reflects
its stated root capability; its worker cost tier remains unverified.

## Selection

- Optimize cost per accepted result: include prompt, reports, verification,
  retries, and retained context. Do not optimize for unit token price or agent
  count alone.
- Select only verified worker models and efforts accepted by the live route.
  A subagent label does not prove its effective model or cost.
- After the worker route is fixed, choose the cheapest capable worker. Increase
  capability or effort only for a demonstrated capability or judgment need;
  step count alone never justifies an upgrade.
- Judge that need by thinking demand, not volume. Mechanical or known-pattern
  work — search, inventory, batch edits, documentation, tests written from a
  spec — takes the cheapest tier however many files or steps it spans. Reserve a
  strong worker for ambiguity, design choice, non-mechanical review, and
  difficult debugging.

## Claude workers

These aliases and the selector behavior were verified 2026-07-11; the live
selector set was re-checked 2026-07-26. A Claude worker without an explicit
`model` inherits its caller, so specify the model whenever the mapping below is
required; omission cannot prove a cheaper route.

| Alias | Worker use |
|---|---|
| `haiku` | known-pattern search, inventory, documentation, tests, or mechanical batches |
| `sonnet` | bounded implementation and factual verification |
| `opus` | non-mechanical review or difficult debugging with demonstrated need |
| `fable` | present in the live selector set (verified 2026-07-26); worker mapping unverified — do not claim a cost tier or capability from it until a dispatch confirms one |

Aliases are not pinned model identifiers; do not claim exact-model
reproducibility from them. Subscription mix determines effective CLI cost; do
not infer it from public per-token prices alone.

## Codex workers

The native collaboration schema currently exposes explicit
`gpt-5.6-sol` and `gpt-5.6-terra` worker overrides plus reasoning effort
(verified 2026-07-24). Use `gpt-5.6-luna` only when the live worker route
explicitly exposes it. Re-check the live schema rather than guessing an alias,
model identifier, or effort value.

| Selector | Worker mapping |
|---|---|
| `gpt-5.6-luna` + `low` | eligible known-pattern search, inventory, documentation, tests, and mechanical work, when available |
| `gpt-5.6-terra` + `high` | plan-backed bounded implementation, debugging, and verification |
| `gpt-5.6-sol` | use only when evidence shows a need beyond the applicable Terra route, especially for non-mechanical judgment or difficult investigation |

When Luna is unavailable, use the verified Terra route for eligible native
work rather than opening a CLI solely to reach Luna. For a Codex CLI worker,
pass the exact verified model and effort selectors; consult [cli.md](cli.md)
for invocation and boundary requirements.

Do not use Luna for ambiguous decisions, blind review, difficult debugging, or
judging another worker's work. A worker that discovers separable low-risk work
returns the decomposition for the root to route unless that nested delegation
was pre-authorized.

## Other runtimes

Use an unlisted runtime only when its live CLI or native schema verifies the
selector and the approved boundary permits it. Do not invent model IDs,
aliases, pricing, or inheritance behavior.
