# Worker Model and Runtime Mapping

Read this only after delegation is approved and the host profile has fixed the
worker route. [../SKILL.md](../SKILL.md) owns role selection, dispatch, and
native-versus-CLI routing; this file maps verified worker selectors on that
route. It never selects, evaluates, or changes the root agent.

## Selection

- Optimize cost per accepted result: include prompt, reports, verification,
  retries, and retained context. Do not optimize for unit token price or agent
  count alone.
- Select only verified worker models and efforts accepted by the live route.
  A subagent label does not prove its effective model or cost.
- After the worker route is fixed, choose the cheapest capable worker. Increase
  capability or effort only for a demonstrated capability or judgment need;
  step count alone never justifies an upgrade.
- Keep nested delegation off unless the root explicitly pre-authorizes its
  child scope, write set, model/effort, reason, and depth or concurrency bound.

## Claude workers

These aliases and the selector behavior were verified 2026-07-11. A Claude
worker without an explicit `model` inherits its caller, so specify the model
whenever the mapping below is required; omission cannot prove a cheaper route.

| Alias | Worker use |
|---|---|
| `haiku` | known-pattern search, inventory, documentation, tests, or mechanical batches |
| `sonnet` | bounded implementation and factual verification |
| `opus` | non-mechanical review or difficult debugging with demonstrated need |

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
