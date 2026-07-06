# Claude Host

| Worker | Dispatch |
|---|---|
| Claude | Native subagent, routed by `subagent_type`. |
| Other family | That family's non-interactive CLI. |

Claude-to-Claude is native. A same-family CLI requires an unavailable native
tool and user opt-in to the separate fallback.

Whether to delegate is the root's own call from the cost test in
[../SKILL.md](../SKILL.md); there is no permission step. If a host declines the
dispatch, do not turn that into a question for the user — run the lane inline
per the fast path and record in the report that delegation was declined.

One lane cannot fall back to inline: a review the root is required to obtain
because runnable checks cannot prove its own work. Running that inline makes
the author the judge, which no host refusal authorizes. Reach for another
non-author route — a different agent type, or an approved CLI worker — and if
none is available, say so and leave the work unaccepted rather than
self-accepting it.

## Routing by agent type

Confirm the type appears in the live agent list before naming it: the set is
configuration-dependent, and a type documented elsewhere may not be offered.

| `subagent_type` | Lane it fits | Worker model |
|---|---|---|
| `Explore` | read-only fan-out: search, inventory, "where does X live" | inherits unless set |
| `Plan` | design or planning lane that needs architecture judgment | set explicitly |
| `general-purpose` | bounded implementation, or multi-step research carrying a write set | set explicitly |
| `fork` | continues the caller's conversation instead of starting cold | **ignored** — a fork always inherits the parent model and can never downshift (the same constraint as Codex `fork_turns="all"`) |

A worker without an explicit `model` inherits its caller, so an explicit worker
model is required whenever a downshift is claimed.

Read [models.md](models.md) for the model/price choice. For any CLI path, also
read [cli.md](cli.md); skip `models.md` when the model and price are fixed.
