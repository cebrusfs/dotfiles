# Letter to Future Sessions

Written 2026-07-07 by a Claude Fable 5 session whose single task was to convert
its judgment into durable institutions for the smaller models (Sonnet, Opus,
gpt-5.5, Gemini) that will run this environment afterwards. If you are reading
this, you are one of those models. The documents this letter cites are the
institution; this letter is the context behind them.

## A. Diagnosis: the three biggest failure modes of this harness

Everything else in the institution refers back to these.

### Leak 1 — The lead agent does the groundwork itself

Root context is long-lived; old instructions said "prefer delegating" without
triggers, a model table, or prompts. Sessions then read everything themselves;
broad scans retained hundreds of lines and crowded out reasoning.

Fix (implemented): the user or host fixes the root authority and model. The
[delegation policy](../config/agent/global.md) and
[delegate skill](../config/agent/skills/agent-delegate/SKILL.md) route explicit,
independently acceptable lanes to capable workers with compact task-local context;
they do not select or upgrade the root. Parallelism needs independent
lanes and disjoint writes. Optimize wall-clock time and accepted-result cost,
not agent count or token price. Fixed overhead remains, but delegation is default.
The skill owns its bounded-lane/fast-path gate; uncertain break-even favors delegation.

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

Fix (implemented): the hard-count escalation ladder in
[failures.md](../config/agent/skills/agent-delegate/references/failures.md).
Runnable checks are author-independent. Read-back and judgment cannot come from
their author: the root reviews worker work, and root-authored work gets fresh
blind review only when checks cannot prove acceptance. The
[delegate skill](../config/agent/skills/agent-delegate/SKILL.md) owns the details,
alongside wrong-direction signals (rubric 4).

## B. Three things nobody asked me, but you should know

1. **Hooks beat prose. Migrate enforcement into hooks over time.** A weak model
   follows a mechanical gate every single time and follows an instruction most
   of the time — and "most" is where incidents live.
   `config/agent/hooks/validate-commit-message.py` is the proof this works. When a
   lesson keeps reappearing in the lessons logs, the correct final form is
   usually a hook or an execpolicy rule, not a longer paragraph. The `jj git`
   / `jj op` bans are already mechanical on both Claude (settings deny) and
   Codex (execpolicy `agent.rules`), and `--ignore-immutable` is guarded by
   the shared `config/agent/hooks/jj-guard.py` PreToolUse hook on both
   (landed 2026-07-08). The remaining gap is Antigravity CLI/Jetski:
   Antigravity CLI 1.1.0 documents CLI plugins with `hooks.json` and `/hooks`,
   but not the full CLI hook payload shape or exit-code/blocking contract.

2. **Acceptance criteria die at the context boundary.** Compaction and long
   sessions silently drop the one thing that defines success. The delegate skill
   owns compact task-local context and report contract; re-read the original
   request before declaring anything done (rubric 2). If you cannot state the
   acceptance criteria verbatim, that is a stop-and-recover signal, not a detail.

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
| Delegation theater | "Delegate" becomes ritual; workers spawned for trivia, reports pasted wholesale | The [delegate skill](../config/agent/skills/agent-delegate/SKILL.md) owns the bounded-lane and fast-path gate |
| Template cargo-culting | Blanks filled with vague words ("make sure it works") | Templates require acceptance criteria to be *runnable commands or checkable facts*; a template with an unverifiable criterion is incomplete |
| Copy drift | Content duplicated across files, then edited in one place | Ownership map in agent-maintenance.md; edits move content to its owner |
| Silent scope growth of always-loaded files | rules/ and global.md accumulate content that belongs in skills/docs | Placement rule: always-loaded = only what changes behavior in most sessions; everything else is on-demand |

## D. Honest limits — what this institution cannot fix

Decomposition, verification, and multi-sample review recover *execution*
quality on weaker models. They do not recover **taste**: judging ambiguous
requirements, sensing that a technically-correct design is the wrong one,
knowing which of two defensible readings the user actually meant. When a task
is taste-shaped, do not simulate confidence. The three honest moves, in order:

1. Frame the choice; keep it with the fixed root if it has authority, otherwise ask the user.
2. Get an independent worker review only when it adds useful evidence, or ask the user.
3. Say plainly that this call exceeds what the current setup can make well, and
   present the options instead of picking one.

Silently picking an interpretation to keep momentum is the only unrecoverable
error in this list.

## E. Unfinished business (handoff)

- Landed 2026-07-11: Antigravity CLI hard command-blocking, via
  `permissions.deny` grant strings in `~/.gemini/antigravity-cli/settings.json`
  (schema captured through the interactive `/permissions` panel; evidence and
  the sync-clobber caveat:
  [agent-config.md](agent-config.md#antigravity-cli-permissions)). Earlier
  probes failed on grant structure, not location. Gemini CLI and Antigravity
  IDE hooks are still not proxies for CLI behavior.
