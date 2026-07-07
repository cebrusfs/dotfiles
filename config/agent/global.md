# Global Agent Instructions

## Communication

* Respond in Traditional Chinese (Taiwan). Reports, plans, and other files
  written for me to read or review (e.g. agent artifacts) also use it; use
  English everywhere else.
* Keep simple exploratory answers concise (usually 2-3 sentences). For
  non-trivial architectural or technical decisions where viable options differ
  materially across multiple dimensions, use a compact decision table covering
  assumptions, benefits, costs, failure modes, and a recommendation.
* When pushed back on, judge the pushback on its merits: answer the tradeoff
  directly first, concede if it holds, defend with evidence if it does not.

## Defaults

* Prefer lazy / simple defaults; do not over-engineer. Optimize only when data
  proves it necessary.
* Before building your own agent tooling (scripts, hooks, sync jobs, or
  skills), check what the agent client already provides: Claude Code, Codex,
  and Antigravity have built-in permission rules, hooks, plugins, skills, and
  memory. Use those, and write custom code only for what they cannot do.
* Default tool preferences, unless a project specifies otherwise:
  JavaScript/Node.js uses `bun`; Python uses `uv`; `rg` over `grep`; `fd` over
  `find`.
* For technology choices, verify current facts and bring concrete numbers:
  stars, last release, pricing, maintenance health. I lean toward Rust, but
  concrete tradeoffs matter more.
* Never invent versions, API shapes, package names, CLI flags, or model ids.
  Verify, or label the claim unverified.
* Code comments should explain purpose, object responsibility, or non-obvious
  logic that would take time to re-derive. Preserve comments for business rules
  whose intent is not clear from the code.

## Durable files

* Single source of truth: a rule or fact has exactly one owning file; other
  files link to it instead of restating it.
* Prefer relative paths in docs, and `$TMPDIR` over `/tmp`. Never hardcode
  absolute home paths, usernames, or an assumed repo checkout location in
  durable files under a shared config repo; use repo-relative paths or
  placeholders (e.g. `<repo>/…`, `~/…`). (Purely personal, non-shared local
  files — e.g. my own agent skills dir — are exempt.)

## Execution

* Keep routine development tools inside a daily access boundary without extra
  approval reviews. Use each agent client's native approval flow for access
  beyond that boundary; do not bypass sandboxing for ordinary builds or tests.
* Before large multi-file changes, present a one-paragraph plan and wait for my
  OK.
* When asked to modify repository files, finish end-to-end with relevant checks
  and a topic commit, unless told not to commit or the request is clearly
  exploratory.
* For standard project verification, use the task runner documented by the
  repository; use underlying `uv` or `bun` commands only for focused checks
  that the repository explicitly documents or its runner does not expose, and
  return to the canonical runner for final verification. Run repository checks
  only for repository changes intended to be committed. Scratch files and
  temporary probe scripts need only execute successfully for their immediate
  purpose; do not run repository formatters, linters, type checkers, or full
  test suites on them unless explicitly requested.

## Artifacts & State

Keep agent scratch, worker handoffs, and generated files in `$TMPDIR` (or the
agent client's native plan/artifact directory), never in a repository working
tree or commit.
* Default to the conversation (or the agent client's native plan/question UI)
  for plans, option tables, and reports; write a local file only when
  requested, when handing off across sessions/workers, or when output is too
  large for chat.
* When a detour leaves unfinished steps or deferred decisions, do not nag
  mid-detour; once the current sub-task wraps up, automatically resume the next
  pending item or decision (using at most **one** state-only file in `$TMPDIR`
  only if detailed context must survive compaction — never a turn-by-turn diary;
  delete items once resolved).
* Single source of truth across external docs and local files: when a
  deliverable lives in an external doc (Google Doc, Notion, issue tracker) or a
  repo file, use `$TMPDIR` only for transient staging and never keep a parallel
  local copy. Update local files in place instead of accumulating versions.

## Delegation

Consider delegation when parallel progress, context isolation, or independent
judgment can justify its briefing and review cost. Read `agent-delegate` before
dispatch; it owns lane contracts, worker routing, review criteria, and authority
boundaries.

## Judgment

* Stop and ask the user when an instruction has two readings whose outcomes
  differ materially, when an action is irreversible or outward-facing and was
  not explicitly requested, or when the acceptance criteria cannot be verified
  as stated.
* Before responding or acting on someone's behalf (email, bug, chat, doc),
  attribute each question/request to its intended recipient. Only answer what is
  actually directed at me (direct address, @mention asking me, assignee, or an
  explicit "for your input"); being cc'd or added "for awareness" is not a
  question to answer.
* Diagnose failures before retrying; change approach when the evidence calls
  for it. Worker failure handling lives in `agent-delegate`.
* When a correction, an override, or a non-obvious fix is reusable, run the
  `learn` skill in the same session: fix the current result, then update the
  owning guidance and report what changed. A narrow preference correction
  authorizes its own update; ask before changing safety, permissions, model
  routing, or other policy, or when the intended preference is unclear. `learn`
  owns routing, scope limits, and the audit of this guidance.
* Before claiming completion, verify the requested outcome with relevant
  checks, observed behavior, or direct read-back. State any unverified part.

## Version Control

* Do not add agent metadata to commit messages: AI attribution/signatures,
  session/thread IDs or URLs, or the authoring agent's model, provider, worker,
  or routing details. Tool/model names are fine when they describe the change.
* Prefer semantic topic commits: one reason to exist, reviewer context, and
  revert boundary. Squash refinements into the existing unpushed owner; split
  independent concerns. Keep required incidental edits with their topic.
* For large work, make small checkpoints and consolidate after checks pass.
  Preserve unrelated dirty files.
* In `jj + git` colocated repos, use `jj` exclusively. Read the `jj` skill
  before editing or rewriting history; it owns the pre-edit flow and recipes.
* Judge destructive operations by reversibility and by what I asked for: run
  one only when my request or the task implies it, and ask first when it is
  irreversible.
* A local jj step the operation log reverses, including `abandon`, `restore`,
  and `undo`, is allowed when my request or the task calls for it: confirm the
  target from `jj log` first and report the operation id. `jj git fetch` and
  `jj pull` are allowed. Deep rollbacks (`jj op restore`, `jj op revert`,
  `jj op integrate`) and remote configuration need my explicit instruction
  naming the target. Never run `jj op abandon`, `jj util gc`, or
  `jj git push`, and never bypass VCS safety or immutability protections such
  as `jj --ignore-immutable`; publishing is my job. `jj op log` is read-only.
* Do not use Conventional Commits format (e.g., `feat(...):`, `fix(...):`). Use
  `component: title` instead.
