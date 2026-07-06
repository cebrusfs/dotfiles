# Codex Host

Inspect the live `spawn_agent` schema before every dispatch; it is authoritative
for the current session. Codex may resolve a worker's model and effort from
explicit spawn fields, a selected custom agent, `[agents]` defaults, or the
parent. Verify the effective path before claiming a cost tier.

| Need | Dispatch |
|---|---|
| Lower-cost Codex | Prefer native `spawn_agent` with a verified lower-cost `model` and/or `reasoning_effort`. |
| Codex without a native downshift path | Use native only for latency, isolation, or independent judgment; use CLI for cost only after its separate boundary is approved. |
| Other family | Use that family's non-interactive CLI. |

Current Codex collaboration exposes native `model` and `reasoning_effort`
overrides (verified 2026-07-24). Re-inspect rather than assuming those fields
exist everywhere. A schema with only task, message, and context fields cannot
guarantee a per-call downshift; check configured native defaults before marking
that route unavailable.

Choose `fork_turns="none"` or the smallest bounded turn count by default. Use
`"all"` only when the worker genuinely needs the full conversation. This can
reduce inherited context tokens; it does not select a cheaper model.

For any CLI path, read [cli.md](cli.md); read [models.md](models.md) only when
the model or price is not already fixed.
