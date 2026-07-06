# Model and Runtime Mapping

Read only when a dispatch needs an explicit runtime or model choice.
[../SKILL.md](../SKILL.md) owns role selection; this file maps roles to
current model aliases and runtimes.

## Runtime choice

- Prefer a native worker when it can select, or will inherit, the cheapest tier
  that fits. Do not pay an agent-CLI prompt tax merely to change process.
- If a native worker inherits an expensive lead and the role is lower-tier,
  use a CLI with an explicit cheaper model. Example: a Fable lead uses Sol for
  strong review, Terra for implementation, and Luna for exploration.
- For required fresh strong review, a native Sol worker is suitable; if the
  lead is Fable and the native API cannot downshift, select `gpt-5.6-sol`
  through the CLI.
- Claude runtime workers must always receive an explicit `model`; omission
  inherits the lead. Use runtime workers for their harness advantage and a CLI
  for a material downshift or cross-family check.
- Which family is effectively cheapest is set by the owner's subscription mix,
  not per-token prices alone. As of 2026-07-11 that mix makes the Codex CLI
  the default worker family (see SKILL.md). Re-verify when plans or prices
  change; concrete plan details stay out of this public repo.

## Claude (aliases verified 2026-07-07; selector verified 2026-07-11)

| Alias | Tier | Roles |
|---|---|---|
| `haiku` | cheap | explore, known-pattern batches |
| `sonnet` | mid | implement, factual verification |
| `opus` | strong | blind review, hard debugging |
| `fable` | judge-tier | taste-shaped judgment only |

A model-less Claude worker inherits its lead. A Fable worker costs 2× Opus at
public API prices (Fable $10/$50, Opus $5/$25 per MTok in/out, verified
2026-07-11), so never inherit it for routine work.

## Codex CLI (verified 2026-07-11)

| Model | Tier | Roles |
|---|---|---|
| `gpt-5.6-luna` | cheap | explore, known-pattern batches, factual read-back |
| `gpt-5.6-terra` | mid | implement, technical research |
| `gpt-5.6-sol` | strong | blind review, hard debugging, deep research |
| `gpt-5.6-sol` + `xhigh`/`max` | judge-tier | plan check, taste-shaped judgment |

Use `-c model_reasoning_effort="low|medium|high|xhigh|max|ultra"`. Effort
ladder (GPT self-guidance, 2026-07-11): `high` is the routine ceiling for
strong work; `xhigh` for high-risk review, conflicting evidence, or
multi-tradeoff plans; `max` only when failure cost dominates and `xhigh` fell
short. `ultra` (Sol/Terra-only) adds automatic subagents, which breaks the
no-recursive-delegation rule — explicit prompt authorization required. Pin
full slugs; the bare `gpt-5.6` alias can be repointed. For any unlisted id,
inspect `~/.codex/models_cache.json` instead of guessing.

Sol at max effort is peer-strength with Fable (user assessment, 2026-07-11).
When the lead judges a plan too complex or taste-shaped, dispatch a parallel
Sol plan review — `xhigh` for the daily case, `max` for the most aggressive
calls — instead of trusting one family's read.

## Gemini CLI

Use only for a requested cross-family second opinion. No model id is verified
in this environment; omit `-m` or check `gemini --help` first.
