# Agent Institution Maintenance

How to update the agent instruction files safely. Applies to any model, any
session. Layout and adapter wiring are owned by
[agent-config.md](agent-config.md); this file owns content changes.
Background and design rationale: [agent-letter.md](agent-letter.md).

## Ownership map

Every rule and fact has exactly one owning file. Edits move content toward its
owner; never copy content between these files — link instead.

| File | Owns | Loaded |
|---|---|---|
| `config/agent/global.md` | interaction rules; delegate/judgment *triggers*; cross-agent VCS safety core | every session, all agents |
| `config/agent/rules/jj.md` | jj invariant, mental model, pre-edit flow choice | every Claude session |
| `config/agent/skills/jj/**` | jj recipes: skeleton, messages, split, recovery, non-interactive forms | on jj tasks |
| `config/agent/hooks/*`, Claude `permissions.deny`, `config/agent/codex/rules/agent.rules` | mechanical enforcement: commit-message format, commit nudge, worktree↔workspace wiring, `jj git`/`jj op` bans | at the moment of action |
| `config/agent/rules/judgment.md` | judgment rubrics with examples | every Claude session; on-demand elsewhere |
| `config/agent/skills/agent-delegate/SKILL.md` | worker invocation mechanics | on delegation |
| `config/agent/skills/agent-delegate/routing.md` | model table, dispatch triple, report contract, escalation ladder, verification protocol | on delegation |
| `config/agent/skills/agent-delegate/templates.md` | worker prompt templates | on delegation |
| `docs/agent-maintenance.md` | this protocol; lessons format; size budgets | on demand |
| `docs/agent-letter.md` | diagnosis, degradation modes, handoff notes | on demand |

Placement rules:

- Always-loaded files carry only what changes behavior in most sessions;
  everything else goes in skills or docs, reachable by a pointer.
- Layer by trigger reliability × frequency: content goes to the latest layer
  whose load timing still precedes its moment of need. No reliable trigger
  (safety bans, pre-edit flow choice) → always-on; reliable trigger (commit,
  split, conflict, dispatch) → skill; mechanically checkable → hook / deny /
  execpolicy, with a self-teaching message so the prose can stay one line.
- `config/agent/rules/` is a Claude-only amplifier: nothing safety-critical may
  live only there; the safety core stays in `global.md` or a mechanical layer.
- Tool-agnostic policy (e.g. commit topic rules) never moves into a
  tool-specific skill.

## What you may change without asking

- Fix factual rot — a dead path, renamed flag, or stale model id — when you
  have direct evidence (`--help` output, filesystem state). Update the
  verified date next to the fact.
- Append a lesson entry (format below) to the owning file's `## Lessons`
  section after an actual incident in the session.
- Add one example to an existing rubric when a real case showed the rubric
  was ambiguous.
- Wording fixes that cannot change meaning (typos, grammar).

## What requires asking the user first

- Changing any threshold or count: delegate triggers, escalation strikes,
  retry caps, size budgets.
- Adding, removing, or weakening a rule — especially VCS safety rules and the
  do-not-delegate list.
- Restructuring `global.md` or adding any new always-loaded file (both tax
  every future session).
- Changing model routing defaults or the model table beyond verified fact
  updates.
- Distilling a Lessons section into the rules body (it rewrites rules).

## Lessons: where and how

- After a real failure or correction, append to a `## Lessons` section at the
  bottom of the *owning* file (create the section on first use):
  `- YYYY-MM-DD: <one-line lesson> (evidence: <command/path/incident>)`
- One line per lesson. No essays — if it needs a paragraph, it is probably a
  rule-change proposal; ask the user instead.
- When a Lessons section exceeds 10 entries or ~30 lines, propose a
  distillation to the user: which entries become rule wording, which get
  deleted. Do not distill unilaterally.
- Recurring lessons (same theme 3+ times) are hook candidates — propose
  mechanical enforcement, not more prose (see agent-letter.md §B.1).

## Size budgets (a file over budget is a bug)

| File | Budget |
|---|---|
| `global.md` | 60 lines |
| `rules/judgment.md` | 100 lines |
| `rules/jj.md` | 80 lines |
| each `agent-delegate` file | 130 lines |

When adding pushes a file over budget, remove or merge something, or ask.

## Every change, before commit

1. `mise run check` passes.
2. Read-back: a fresh look at the final file confirms it is complete and
   its cross-references resolve (files exist, paths correct).
3. If the change touches adapter wiring or symlinks, follow
   [agent-config.md](agent-config.md) and the `agent-config` skill.
4. Topic commit as `agent: <title>`.
