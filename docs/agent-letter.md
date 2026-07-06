# Letter to Future Sessions

Written 2026-07-07 by a Claude Fable 5 session whose single task was to convert
its judgment into durable institutions for the smaller models (Sonnet, Opus,
gpt-5.5, Gemini) that will run this environment afterwards. If you are reading
this, you are one of those models. The documents this letter cites are the
institution; this letter is the context behind them.

## A. Diagnosis: the three biggest failure modes of this harness

Everything else in the institution refers back to these.

### Leak 1 — The lead agent does the groundwork itself

The most expensive context in every session belongs to the lead model, and the
old instructions said "prefer delegating" without hard triggers, a model table,
or ready-made prompts. Deliberating about delegation costs more than just
reading the files, so sessions defaulted to reading everything themselves.
Every broad scan loads hundreds of lines into the priciest context and stays
there for the rest of the session, crowding out the reasoning it was meant to
serve.

Fix (implemented): hard numeric triggers in `../config/agent/global.md`
(>~5 files, >~300 lines of logs, >~3-file pattern application, web research
beyond a single lookup, review passes → delegate); a model routing table in
`../config/agent/skills/agent-delegate/routing.md` so no per-dispatch
deliberation is needed; fill-in templates in
`../config/agent/skills/agent-delegate/templates.md` so composing a worker
prompt is cheaper than doing the work inline.

### Leak 2 — Always-loaded rules duplicate each other and drift

`global.md`'s Version Control section and `rules/jj.md` overlap on many rules,
and both auto-load in every Claude session in every repository. The dotfiles
`AGENTS.md` also restates part of `docs/agent-config.md`. Cost is paid twice:
tokens on every session, and drift risk — two wordings of the same safety rule
already differ slightly, and a weak model resolves conflicting wordings
unpredictably.

Fix (implemented): an ownership map in [agent-maintenance.md](agent-maintenance.md)
assigns every rule exactly one owning file; future edits must move content
toward its owner rather than copying. Full dedup of `rules/jj.md` vs
`global.md` was deliberately **not** done in one pass: `global.md` is the only
*user-global* rule surface Codex and Gemini see (they still load repo
`AGENTS.md` and skills, but never `config/agent/rules/`), so the cross-agent
jj safety core must stay in `global.md`;
removing them from `rules/jj.md` is a Claude-behavior change that deserves its
own reviewed commit. That dedup landed on 2026-07-08: `rules/jj.md` now defers
to `global.md` for the safety core and keeps only the pre-edit working model;
the non-interactive forms table moved into the `jj` skill.

### Leak 3 — Self-verification and blind retry

Nothing told a model what to do after a failed attempt. The default behavior is
retry-with-variation inside the same polluted context (each retry re-reads and
re-reasons, so cost compounds) and "it looks done" self-assessment by the same
context that wrote the code. Worse, after two or three failed attempts the
original acceptance criteria have usually scrolled out of effective attention,
so later retries optimize for the wrong target.

Fix (implemented): the escalation ladder with hard counts in
`../config/agent/skills/agent-delegate/routing.md` (cheap model: one strike;
mid model: two strikes on the same subtask, then escalate with the full
failure trail; never a third attempt at the same tier, then stop and report);
fresh-context verification — work is never graded by its author (the same
routing.md, rubric 5 in `../config/agent/rules/judgment.md`); and
wrong-direction signals (rubric 4) that force a stop-and-rethink instead of
another retry.

## B. Three things nobody asked me, but you should know

1. **Hooks beat prose. Migrate enforcement into hooks over time.** A weak model
   follows a mechanical gate every single time and follows an instruction most
   of the time — and "most" is where incidents live.
   `config/agent/hooks/commit-message-check.py` is the proof this works. When a
   lesson keeps reappearing in the lessons logs, the correct final form is
   usually a hook or an execpolicy rule, not a longer paragraph. The `jj git`
   / `jj op` bans are already mechanical on both Claude (settings deny) and
   Codex (execpolicy `agent.rules`). The visible gaps: `--ignore-immutable`
   has no mechanical coverage anywhere, and Gemini has no mechanical layer
   wired at all.

2. **Acceptance criteria die at the context boundary.** Compaction and long
   sessions silently drop the one thing that defines success. Two habits are
   the insurance: the dispatch triple (every worker prompt restates goal,
   acceptance criteria, report format — so criteria survive in every subtask
   even if the main thread degrades), and re-reading the original request
   before declaring anything done (rubric 2). If you notice you cannot state
   the acceptance criteria verbatim, that is a stop-and-recover signal, not a
   detail.

3. **The institution's enemy is its own growth.** Every rule added here taxes
   every future session forever, and each individually-reasonable addition
   makes all the others less likely to be followed. When you add a rule, look
   for one to delete or merge. The size budgets in
   [agent-maintenance.md](agent-maintenance.md) are load-bearing, not
   bureaucracy: an instruction file over budget is a bug even if every line in
   it is true.

## C. How this institution will most likely degrade, and the countermeasures

| Degradation | Mechanism | Countermeasure |
|---|---|---|
| Rule accretion | Every incident adds a rule; nothing deletes one | Size budgets + distillation protocol in agent-maintenance.md; add-one-delete-one habit |
| Fact rot | Model ids, CLI flags, paths go stale silently | Facts carry a verified date; re-verify with `--help` before relying; factual-rot fixes are self-serve (agent-maintenance.md §What you may change without asking) |
| Delegation theater | "Delegate" becomes ritual; workers spawned for trivia, reports pasted wholesale | Above the thresholds delegation is the default and skipping needs a stated reason; below them it is optional; the do-not-delegate list always binds |
| Template cargo-culting | Blanks filled with vague words ("make sure it works") | Templates require acceptance criteria to be *runnable commands or checkable facts*; a template with an unverifiable criterion is incomplete |
| Copy drift | Content duplicated across files, then edited in one place | Ownership map in agent-maintenance.md; edits move content to its owner |
| Silent scope growth of always-loaded files | rules/ and global.md accumulate content that belongs in skills/docs | Placement rule: always-loaded = only what changes behavior in most sessions; everything else is on-demand |

## D. Honest limits — what this institution cannot fix

Decomposition, verification, and multi-sample review recover *execution*
quality on weaker models. They do not recover **taste**: judging ambiguous
requirements, sensing that a technically-correct design is the wrong one,
knowing which of two defensible readings the user actually meant. When a task
is taste-shaped, do not simulate confidence. The three honest moves, in order:

1. Escalate to the strongest available model with the decision framed
   explicitly (options, evidence, what hinges on the choice).
2. Get an outside opinion: a cross-family model, or the user.
3. Say plainly that this call exceeds what the current setup can make well,
   and present the options instead of picking one.

Silently picking an interpretation to keep momentum is the only unrecoverable
error in this list.

## E. Unfinished business (handoff)

- `AGENTS.md` restates the adapter map from `docs/agent-config.md`; converge
  toward a pointer when next touched.
- Mechanical-enforcement gaps from §B.1: a `--ignore-immutable` guard
  (Claude + Codex), and the fact that Gemini has no mechanical layer wired.
