# Model Routing and Dispatch Rules

Canonical dispatch policy for delegated work. `SKILL.md` owns invocation
mechanics; this file owns who does what, at what strength, and how results
come back. The hard delegate/do-not-delegate triggers live in
`~/.dotfiles/config/agent/global.md` (Delegation section).

## Roles before names

Pick the worker by role first, then map to the cheapest model that fills it:

| Role | Work | Strength |
|---|---|---|
| explore | read-only scans: repo layout, call sites, long logs, docs | cheapest capable |
| implement | bounded patch with clear acceptance criteria | mid |
| review / verify | blind review, acceptance checks, read-back | strong; fresh context, never the author |
| judge | ambiguous or taste-shaped decisions | strongest available, or the user |

## Model table (CLI flags verified via `--help`, model ids from local config, 2026-07-07 — re-verify both before relying)

**Claude Code sessions** — subagent `model` param, or `claude -p --model <alias>`:

| Alias | Tier | Use for |
|---|---|---|
| `haiku` | cheap | explore, batch pattern application |
| `sonnet` | mid | implement, routine review |
| `opus` | strong | blind review, hard debugging, judge |
| `fable` | judge-tier | only when the session's harness lists it |

`claude -p` also accepts `--effort low|medium|high|xhigh|max` and
`--allowedTools` (restrict to read-only tools for explore/review roles).
Prefer runtime subagents over the CLI for Claude→Claude work (see SKILL.md).

**Codex CLI** — `codex exec -m gpt-5.5 ...`:

- The cost dial on Codex is reasoning effort, not the model id:
  `-c model_reasoning_effort="low|medium|high|xhigh"` (user default: `xhigh`
  from `~/.codex/config.toml`). Drop to `low`/`medium` for explore, keep
  `high`+ for review.
- `gpt-5.5` is the only model id verified in this environment. Do not guess
  other ids; if a different tier seems needed, check `codex exec --help` and
  the config, or ask the user.

**Gemini CLI** — `gemini -p "<prompt>" [-m <model>]`:

- Headless via `-p`. Use as a cross-family second opinion. No model id is
  verified in this environment; omit `-m` for the default or check
  `gemini --help` first.

## Dispatch triple — every worker prompt carries all three

1. **Goal and motivation** — what to produce and why it is needed, so the
   worker can make sane micro-decisions.
2. **Acceptance criteria** — checkable facts or runnable commands. "Make sure
   it works" is not a criterion; "`mise run check` passes and the new test
   fails on the old code" is.
3. **Report format** — what comes back (see report contract) and the file path
   for any long artifact.

Templates for the five common task shapes are in
[templates.md](templates.md); start from those.

## Report contract

- Workers return conclusions, findings with `file:line` evidence, commands
  run, confidence, and open questions — never raw file dumps or transcripts.
- Long artifacts (reports, diffs, generated docs) are written by the worker to
  an agreed path (prefer `$TMPDIR` for throwaway, repo paths for
  deliverables); the reply carries the path plus a 3-line summary.
- The lead validates findings against the current worktree before acting on
  them. Worker output is advisory.

## Escalation and downgrade ladder

- **Cheap worker (haiku / low effort) fails once** → escalate one tier
  immediately. Do not debug a cheap model's confusion.
- **Mid worker (sonnet / gpt-5.5 medium) fails twice on the same subtask** →
  escalate to the strongest available, attaching the full failure trail:
  attempts made, exact error output, hypotheses already ruled out. Escalating
  without the trail forces re-derivation and wastes the stronger model.
- **After the strong model solves it** → extract the now-known pattern and
  downgrade: batch-apply with a cheap worker using the solved instance as the
  worked example in its prompt.
- **Hard cap** — a subtask never gets a third attempt at the same tier (and
  the cheap tier never gets a second). When the strongest available model has
  failed twice on it, stop, report what was tried, and ask the user.
- These counts also bind the lead model itself: a lead stuck twice on the same
  subtask recruits a stronger worker or asks, instead of retry number three.

## Verification is never self-verification

- Acceptance checks go to a **fresh-context** worker — never the context that
  produced the work, and for blind review not even the author's rationale.
- Files/docs: fresh worker read-back — does the file exist, is it complete,
  does it satisfy each acceptance criterion, do its cross-references resolve?
- Code: tests or a real run; command output is the evidence, not prose.
- High-risk judgment calls: a second opinion (prefer cross-family: Codex or
  Gemini checking Claude work, and vice versa), or generate N candidate
  answers and have a strong judge pick with reasons.
- The lead inspects the evidence and owns the final accept/reject and every
  user-facing claim.
