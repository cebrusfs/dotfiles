# Claude Host

| Worker | Dispatch |
|---|---|
| Claude | Use the native subagent tool with an explicit model. |
| Other family | Use that family's non-interactive CLI. |

Claude-to-Claude is always native; never omit the model and silently inherit an
expensive lead. A same-family CLI requires an unavailable native tool and user
opt-in to the separate fallback.

Read [models.md](models.md) for the model/price choice. For any CLI path, also
read [cli.md](cli.md); skip `models.md` when the model and price are fixed.
