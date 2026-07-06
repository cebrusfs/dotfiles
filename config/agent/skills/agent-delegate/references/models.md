# Model and Runtime Mapping

Read only when a dispatch needs an explicit runtime or model choice.
[../SKILL.md](../SKILL.md) and its required host profile own role and
native-versus-CLI routing. This file owns price/strength selection after that
path is fixed.

## Selection

- Follow the host profile; select a model only when that path exposes a
  selector. Never claim an unreported tier.
- Prefer a verified native Codex downshift over a separate CLI session. A
  subagent label alone says nothing about its effective model or price.
- For a permitted downshift from a Fable lead, use Sol for solution exploration
  and strong review, Terra for plan-backed implementation and bounded scans,
  and Luna only for simple known-pattern batches.
- Claude runtime workers must always receive an explicit `model`; omission
  inherits the lead.
- Which CLI family is effectively cheapest is set by the owner's subscription
  mix, not per-token prices alone. As of 2026-07-11 that mix makes the Codex CLI
  the default *CLI fallback*, not the default worker. Re-verify when plans or
  prices change; concrete plan details stay out of this public repo.

## Claude (aliases verified 2026-07-07; selector verified 2026-07-11)

| Alias | Tier | Roles |
|---|---|---|
| `haiku` | cheap | bounded scans, known-pattern batches |
| `sonnet` | mid | implement, factual verification |
| `opus` | strong | blind review, hard debugging |
| `fable` | judge-tier | taste-shaped judgment only |

A model-less Claude worker inherits its lead. A Fable worker costs 2× Opus at
public API prices (Fable $10/$50, Opus $5/$25 per MTok in/out, verified
2026-07-11), so never inherit it for routine work. These selectors are aliases,
not pinned model ids; never claim exact-model reproducibility from them.

## Codex (native selector and CLI cache verified 2026-07-24)

| Model | Tier | Roles |
|---|---|---|
| `gpt-5.6-luna` | cheap | known-pattern batches, factual read-back |
| `gpt-5.6-terra` | mid; lower-cost than Sol | bounded scans, plan-backed implementation |
| `gpt-5.6-sol` | strong | solution exploration, blind review, hard debugging |
| `gpt-5.6-sol` + `xhigh`/`max` | judge-tier | plan check, taste-shaped judgment |

The current native collaboration schema exposes Sol and Terra model overrides
plus explicit reasoning effort. Use Luna only when the live route exposes it;
otherwise use Terra for lower-cost native work rather than opening a CLI solely
to reach Luna. For CLI dispatch, pass the exact model with `-m` and effort with
`-c model_reasoning_effort="low|medium|high|xhigh|max|ultra"`.

Routing default (user preference, 2026-07-24): dispatch Terra at `high`
reasoning effort and eligible Luna work at `low`; Sol remains role-dependent.

Effort ladder ([Codex subagent docs](https://developers.openai.com/codex/subagents/),
verified 2026-07-24): use `low` when the task is straightforward and speed
matters, `medium` for routine agents, `high` for complex tracing or review,
`xhigh`/`max` for exceptional demands, and `ultra` only with explicit
nested-delegation authorization. Higher effort increases latency and token
usage. Pin full slugs; the bare `gpt-5.6` alias can be repointed. For any
unlisted id, inspect `~/.codex/models_cache.json` instead of guessing.

### Nested Codex downshift

Prefer lead-to-Luna dispatch when the work is identifiable up front. Permit
Terra-to-Luna only when Terra is already following an approved plan and then
discovers a material batch of independent, known-pattern, low-risk units whose
savings exceed the extra prompt, report, and verification context. Luna must be
available through Terra's live native route, and the lead must have
pre-authorized the nested scope and bounds; never let the worker substitute a
CLI session. Otherwise Terra returns the decomposition for the lead to route.

Do not use Luna for solution exploration, ambiguous decisions, blind review,
hard debugging, or judging Terra's work.

Sol at max effort is peer-strength with Fable (user assessment, 2026-07-11).
When the lead judges a plan too complex or taste-shaped, dispatch a parallel
Sol plan review — `xhigh` for the daily case, `max` for the most aggressive
calls — instead of trusting one family's read.

## Gemini CLI

Use only for a requested cross-family second opinion. No model id is verified
in this environment; omit `-m` or check `gemini --help` first.
