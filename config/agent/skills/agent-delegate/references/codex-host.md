# Codex Host

Use the live `collaboration.spawn_agent` schema as the session authority.
Verify it when selecting a route; re-check after a route change or rejection.
The host fixes the root model and effort.

Prefer native workers. For a different runtime or missing native capability,
follow the CLI boundary in [../SKILL.md](../SKILL.md) and invocation guidance
in [cli.md](cli.md). Worker defaults and selectors live in [models.md](models.md).

Use `fork_turns="none"` with compact task-local facts by default. Use a bounded
turn count when specific conversation evidence is needed. Full-history forks
(`fork_turns="all"`) inherit the parent's model and effort; explicit overrides
require `"none"` or a bounded fork (verified 2026-10-08).

Resolve effective settings from explicit spawn fields and documented defaults
or inheritance before claiming a cost reduction. Reduced conversation context
changes input volume, not the model's per-token price.
