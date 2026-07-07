---
name: learn
description: Persist a reusable lesson from this session into the guidance that owns it. Use when the user corrects or overrides the agent, states a preference, says "remember this", "from now on", "don't do that again", or "learn"; when a non-obvious fix should not be repeated; or to audit the shared guidance and skills for rot. Routes the lesson to global guidance, a skill, a repository's AGENTS.md, or a host adapter, applies it within the approved authority, verifies, and commits. Not for one-off requirements, transient failures, or private details.
allowed-tools:
  - Read(~/.claude/skills/learn/**)
  - Read(~/**/config/agent/skills/learn/**)
---

# learn

Policy layer only: the host's own tools do the mechanics (see
[Hosts](#hosts)). This skill decides where a lesson lives, what may change
without asking, and how it lands in the shared repository.

## Rules

- Fix the current task's result first; then persist, in the same session.
- A lesson is reusable when it would change behavior in a later task. Skip
  one-offs, transient failures, and incident narratives, and say so. If current
  guidance already covers it, treat the event as a missed application:
  remediate (re-present the change as a proposal, or reverse your own unpushed
  edit) and reword only what misled.
- Persist the scope the user stated; offer any generalization as a proposal.
- Replace stale text in place; no diaries or lessons lists. English, ~80
  columns, `~/…` or `<repo>/…` placeholders, volatile facts dated with their
  evidence (`verified 2026-10-08 with codex-cli 0.161.0 --help`), no private
  or corp details in shared files.
- Host memories (Claude auto memory, Codex memories) are recall aids, not
  owners; promote a candidate only through this skill.
- Design every change for Claude Code, Codex, and Antigravity together: the
  same behavior on all three, through each host's native mechanism. A host-only
  path is a last resort; report the gap instead of silently accepting it.
- Only the root agent persists; workers report candidates with evidence.

## Authority

The most restrictive matching tier wins. A preference says how to do something
already allowed; policy changes what is allowed, required, or always loaded.

- Apply: a narrow preference correction as expressed; verified factual rot
  (paths, flags, selectors, versions); wording without a meaning change.
- Propose first: safety, permission, sandbox, or approval behavior; model
  routing, thresholds, or ceilings; new policy or restructuring always-loaded
  guidance; unclear scope.
- Never: one-offs as policy; secrets or private, corp, or personal details;
  bypassing a repository's checks or VCS protections.

An approval given in this task for a shown diff or stated scope covers that
scope. The instruction that prompted the lesson is not that approval, even
when it asks for the guidance to change.

## Routing

Resolve the shared dotfiles checkout; the adapters under `~/.claude`,
`~/.codex`, `~/.agents`, and `~/.gemini` are symlinks into it. Stop and report
if this fails rather than editing a guessed path:

```bash
src=$(cd "$(readlink -f ~/.agents/skills)/../../.." && pwd) &&
    test -f "$src/config/agent/global.md" || echo "shared source not found" >&2
```

| Lesson is about | Owner (under `$src` unless stated) |
|---|---|
| A preference or constraint for every repository and host | `config/agent/global.md`, under the `##` heading it refines |
| A tool's mechanics or recipes (jj, delegation, GitHub issues, repository agent config) | that skill under `config/agent/skills/` |
| How lessons are captured, routed, or applied | `config/agent/skills/learn/SKILL.md` |
| Adapter wiring, permission posture, hooks | `docs/agent-config.md` and `config/agent/<host>/`. A rule stated in prose and enforced by a hook changes in both; adding or relaxing enforcement is policy |
| One repository only | Its `AGENTS.md` (create it with `repo-agent-config` if absent) or `.agents/skills/<name>/`; if agent config is unwelcome there, a host-local uncommitted file, reported as such |
| Private, corp, or personal context | A private local file outside the shared repository |

A repository-vendored copy of a shared skill is that repository's runtime
source: update the copy for repository-specific behavior and the shared source
for general behavior.

## Apply

Edit through `$src` and run `mise run check` there; it includes the hook tests
and the size ceilings (`mise.toml` holds the numbers: always-loaded text and
skill descriptions are strict, skill bodies have a tripwire). Read the result
back and validate a behavior change with a case proportional to its risk.
Commit per that repository's `AGENTS.md` (`agent:` for cross-agent guidance,
otherwise the file's component such as `jj:`) following the `jj` skill flow;
preserve unrelated dirty files; do not push. Report the lesson, the file and
section, the authority relied on, and anything proposed but not applied. The
VCS log of the owning file is the history of lessons.

## Hosts

| Host | Invoke | Native mechanics |
|---|---|---|
| Claude Code | `/learn [lesson]` | `skill-creator` plugin scaffolds a skill; `/doctor prompt-audit [path]` (v2.1.283+) finds stale or contradictory instructions; auto memory `feedback` notes under `~/.claude/projects/<project>/memory/` are candidates |
| Codex | `$learn` | `$skill-creator` scaffolds a skill; local memories (`/memories`) are candidates |
| Antigravity | `learn` skill, or the host's proposal flow | Use the host's proposal UI when it offers one |

Audit on request or after a misfire: run the host's audit first, read its
captured candidates, then check what hosts do not: a fact with two owners,
always-loaded text a skill or hook should own, descriptions that no longer
state when to trigger (Codex trims the skills list to a context share), and
ceiling headroom. Lessons about learning itself follow the same rules with
this file as the owner; changes to Authority are policy.
