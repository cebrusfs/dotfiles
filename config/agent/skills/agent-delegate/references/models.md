# Worker Model and Runtime Mapping

This file owns worker selectors and routing defaults. The host fixes the root
model and effort; this file does not classify or change them.

Choose by thinking demand and cost per accepted result, including retries and
verification. Material volume alone does not justify a stronger worker.
Verify selectors against the session's live route; re-check when the route
changes or rejects a selection. Do not infer price or resolved settings from a
worker label.

## Codex workers

Native schema and routing verified/approved 2026-10-08:

| Work | Model | Effort |
|---|---|---|
| Mechanical search, inventory, batch edits, or tests from a spec | `gpt-6-luna` | `low` |
| Bounded implementation, debugging, or factual verification | `gpt-6.1-sol` | Route default; raise on demonstrated need |
| Blind or non-mechanical review, including judging worker output | `gpt-6.1-sol` | Explicit `xhigh` |
| Investigation requiring capability beyond Sol | `gpt-6-astra` | Explicit, verified for the route |

The native schema also exposes `gpt-6-sol` and `gpt-5.6-sol`; their cost
advantage over these defaults is unverified. The former `gpt-5.6-luna` and
`gpt-5.6-terra` selectors are absent. No pricing or accepted-result benchmark
has been verified for this mapping.

Native efforts are `low`, `medium`, `high`, `xhigh`, and `max`; the
non-Luna selectors also declare `ultra`. Omitted effort need not inherit the
parent's setting when a model override is supplied, so pass both selectors
when pinning a review route. Do not use Luna for ambiguous decisions or review.

Use Sol if Luna is unavailable. For CLI workers, verify the installed CLI's
selectors independently; see [cli.md](cli.md). Native fork and override
constraints live in [codex-host.md](codex-host.md).

## Claude workers

Aliases were verified 2026-07-26; confirm availability on the current route.
An omitted model inherits the caller. Aliases float, so they do not establish
an exact model version or price.

| Alias | Work |
|---|---|
| `haiku` | Known-pattern search, inventory, documentation, tests, mechanical batches |
| `sonnet` | Bounded implementation and factual verification |
| `opus` | Non-mechanical review or difficult debugging with demonstrated need |
| `fable` | Previously exposed; worker capability and cost mapping unverified |

Subscription and runtime determine effective cost; do not infer it from
public per-token prices alone. For other runtimes, verify selectors before
dispatch and follow the approved session boundary.
