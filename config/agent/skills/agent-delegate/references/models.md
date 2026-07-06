# Worker Model and Runtime Mapping

Read this to check your own judgment tier, and again once the worker route is
fixed to pick a selector on it. [../SKILL.md](../SKILL.md) owns the
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

At or above the tier: `claude-opus-5`, `claude-fable-5`, `gpt-5.6-sol`.
Everything else is below it.

Read that as **model ids, not aliases**. An alias like `opus` floats — it can
resolve to an older model depending on provider and configuration, so knowing
only your alias does not establish which model answered. If all you have is an
alias, or the runtime surfaces no model at all, you are below the tier. Decide
this from the reported id, never from your impression of your own capability:
self-assessment is the judgment this switch exists to avoid relying on.

The tier rates a root's *routing* judgment only. It is unrelated to the
worker-cost mappings below, and the root's model is a given input — never a
selection (see [../SKILL.md](../SKILL.md)). `claude-fable-5` sits here on its
stated root capability; its worker cost tier remains unverified.

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

### Reasoning effort — verified per route, 2026-07-27

The two routes do not declare the same set, so do not carry a value from one to
the other.

| Route | Declared values | How established |
|---|---|---|
| Native `spawn_agent` | `low` `medium` `high` `xhigh` `max` `ultra` | The live schema's own `reasoning_effort` description, read in-session. `none` and `minimal` are **not** listed. |
| Codex CLI | `none` `minimal` `low` `medium` `high` `xhigh` `max` `ultra` | The `ReasoningEffort` variant list in the codex-cli 0.145.0 binary, plus `max` confirmed live — echoed back as `reasoning effort: max` in the session header of a `codex exec --strict-config` run. |

The native field is typed `string` with no machine-checkable enum, so an
unlisted value cannot be *proven* rejected — but an unlisted value is also not
verified, so do not send one. Omitting `reasoning_effort` inherits the parent's;
the field does exist, so a worker downshift is available on this route. The
schema likewise declares only `gpt-5.6-sol` and `gpt-5.6-terra` as `model`
overrides. `ultra` is untested on either route.

Pass a CLI value with `-c model_reasoning_effort="<value>"`.

**`xhigh` is not the ceiling.** This ladder has grown before, and a config file
left at `xhigh` is evidence of that setting's age, not of the maximum available.
Re-read the live schema or the variant list rather than inferring the top from
what happens to be configured.

| Selector | Worker mapping |
|---|---|
| `gpt-5.6-luna` + `low` | eligible known-pattern search, inventory, documentation, tests, and mechanical work, when available |
| `gpt-5.6-terra` | plan-backed bounded implementation, debugging, and verification. Leave effort at the route's default and raise it only on demonstrated need, per the selection rule above — `high` is not automatic for this row |
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
