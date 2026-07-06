# Codex Host

Inspect the live `collaboration.spawn_agent` schema before every worker
dispatch; it is authoritative for the current session. The user and host fix
the root identity, model, and reasoning effort outside this profile. This
profile never selects, evaluates, or changes them.

Resolve a worker's effective model and effort from the live schema, explicit
spawn fields, a selected custom agent, configured worker defaults, and any
documented inheritance. Verify that path before claiming a cost tier or a
downshift. Context inheritance changes token volume, not model strength or
per-token price.

| Need | Worker dispatch |
|---|---|
| Lower-cost Codex worker | Prefer native `spawn_agent` with verified lower-cost explicit `model` and/or `reasoning_effort`. |
| No native downshift path | Use native only for latency, isolation, or independent judgment; use a CLI for cost only after its separate boundary is approved. |
| Other family | Use that family's non-interactive CLI after its boundary is approved. |

The current collaboration schema exposes explicit worker `model` and
`reasoning_effort` overrides (verified 2026-07-24). Re-inspect rather than
assuming fields or accepted values across hosts. A schema with only task,
message, and context fields cannot establish a per-call downshift; inspect
configured worker defaults before deciding whether such a route exists.

Use `fork_turns="none"` by default and pass a compact task-local plan and
context. Use a smallest bounded turn count only when that evidence is needed.
Full-history forks (`fork_turns="all"`) inherit the parent's model and effort,
so they cannot downshift a worker and are only for a genuine full-conversation
need. Explicit model or effort overrides require `fork_turns="none"` or a
bounded fork; do not combine them with a full-history fork.

Keep effective-route verification at the dispatch boundary: check both that
the native call accepts the selector and that the resolved worker model/effort
supports the claimed cost route. Do not bypass any worker sandbox or approval
protection. For a CLI path, read [cli.md](cli.md); read
[models.md](models.md) only when the worker model or price choice remains open.
