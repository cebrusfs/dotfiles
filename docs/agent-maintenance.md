# Agent Instruction Maintenance

This file owns maintenance of shared agent guidance. Adapter layout and wiring
live in [agent-config.md](agent-config.md).

## Ownership and placement

| File | Owns |
|---|---|
| `config/agent/global.md` | Cross-agent preferences, authorization, completion, and VCS policy |
| `config/agent/skills/jj/**` | jj pre-edit flow, command recipes, and recovery |
| `config/agent/skills/agent-delegate/SKILL.md` | Delegation contracts, authority, isolation, and review criteria |
| `agent-delegate/references/models.md` | Worker selectors and routing defaults |
| `agent-delegate/references/{claude,codex}-host.md` | Native dispatch mechanics |
| `agent-delegate/references/cli.md` | CLI invocation and resume |
| `agent-delegate/references/workspaces.md` | Writable jj worker isolation |
| `agent-delegate/references/failures.md` | Worker failure handling |
| `config/agent/hooks/*` and runtime permission rules | Mechanical enforcement |
| `docs/agent-maintenance.md` | Content ownership and maintenance boundaries |

Keep one owner per fact or rule; callers link to it. Always-loaded guidance
should contain preferences and constraints needed across tasks. Put specialized
recipes in skills or references, with a trigger that loads them before use.
Safety-critical guidance must be shared across runtimes or mechanically
enforced; the optional Claude rules directory cannot be its sole owner.

Write for a capable agent: keep non-obvious context, user preferences, and
operational invariants. Remove generic reasoning tutorials, duplicate
instructions, and incident narratives already represented by the current rule.

## Authorized updates

- Fix verified factual rot, such as paths, flags, or selectors; date volatile
  facts and retain their evidence source.
- Fix wording without changing meaning.
- Apply preference corrections under
  [global.md](../config/agent/global.md#judgment), including version-controlled
  custom skills. That file owns the trigger and authorization limits.

Other policy changes, model routing defaults, operational thresholds, size
budgets, or restructuring always-loaded guidance require user approval.
An explicit approval in the current task already covers its stated scope;
do not ask again for routine implementation within it.

For reusable failures, fix the immediate result and update the owning guidance
within that authority. Propose any required policy change. Replace stale
content in place; do not accumulate a separate Lessons diary. Use the available
skill-authoring tool when helpful, and validate meaningful behavior changes
with a realistic case proportional to their risk.

## Vendored skills

A repo-vendored skill is that repository's runtime source. A global copy may
serve as an explicit maintenance upstream, but never overwrites a repository
at runtime. Keep repo-specific behavior local and independent of home paths.

## Size and verification

Word limits (`wc -w`) are ceilings, not targets:

| File | Budget |
|---|---|
| `global.md` | 1,600 words |
| Each `agent-delegate` file | 1,500 words |

When an edit exceeds a budget, remove or merge content, or ask to change it.
Before committing, run `mise run check`, read back the result, and verify
references resolve. For adapter or symlink changes, follow
[agent-config.md](agent-config.md) and `repo-agent-config`. Use topic commits
under the shared VCS policy.
