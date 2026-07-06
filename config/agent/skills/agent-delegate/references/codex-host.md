# Codex Host

| Worker | Dispatch |
|---|---|
| Codex | Use native `spawn_agent`. |
| Other family | Use that family's non-interactive CLI. |

Codex-to-Codex is always native. If its API lacks a model selector, do not
claim an exact tier; a separate CLI requires user opt-in after disclosing its
additional session/context boundary.

For any CLI path, read [cli.md](cli.md); read [models.md](models.md) only when
the model or price is not already fixed.
