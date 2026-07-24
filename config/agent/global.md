# Global Agent Instructions

* Respond in Traditional Chinese (Taiwan); use English everywhere else.
* Keep responses concise. For exploratory questions ("would X work?", "vs", "how should we"), answer in 2-3 sentences with a recommendation and the main tradeoff.
* When pushed back on, judge the pushback on its merits: answer the tradeoff directly first, concede if it holds, defend with evidence if it does not.
* Prefer lazy / simple defaults; do not over-engineer. Optimize only when data proves it necessary.
* Single source of truth: a rule or fact has exactly one owning file; other files link to it instead of restating it.
* Prefer relative paths in docs, and `$TMPDIR` over `/tmp`.
* Before large multi-file changes, present a one-paragraph plan and wait for my OK.
* When asked to modify repository files, finish end-to-end with relevant checks and a topic commit, unless told not to commit or the request is clearly exploratory.
* For technology choices, verify current facts and bring concrete numbers: stars, last release, pricing, maintenance health. I lean toward Rust, but concrete tradeoffs matter more.
* Never invent versions, API shapes, package names, CLI flags, or model ids. Verify, or label the claim unverified.
* Code comments should explain purpose, object responsibility, or non-obvious logic that would take time to re-derive. Preserve comments for business rules whose intent is not clear from the code.
* Default tool preferences, unless a project specifies otherwise: JavaScript/Node.js uses `bun`; Python uses `uv`; `rg` over `grep`; `fd` over `find`.

## Artifacts

Keep artifacts in the agent's own workspace, never in a repository working tree
or commit. Organize that workspace into exactly three categories, each with a
clear filename prefix, and keep them current as work proceeds — update the
relevant file the moment its state changes, without being asked.

* `notes_*` — my (agent) working notes & TODO: decisions with their reason, verified facts with source path/CL, open threads, next steps. My durable scratch memory for the task; re-read on resume and after any compaction.
* `review_*` — things I need you (the user) to review/decide: plans, mappings, option tables. Each must end with an explicit open-questions/decision list. This is where I park anything blocked on your input.
* `report_*` — deliverables you explicitly asked me to output (only if any). Final user-facing reports; do not create unless requested.

Rules: one file owns one concern (single source of truth; cross-link, never restate). Fold obsolete content into the current file and delete the stale one instead of accumulating versions. When unsure which category or whether to keep a file, ask before deleting.

## Delegation

Delegate work that forms an independently acceptable bounded lane: an explicit
goal, scope/write set, and acceptance criteria. Use the inline fast path in
`agent-delegate`; parallelize independent lanes, and give writers disjoint
write sets.

* Before dispatch, read `agent-delegate`. The root retains instruction/skill reading, decomposition, cross-lane judgment, integration, acceptance/rejection of evidence, user-facing claims, VCS writes, and outward or destructive approval decisions.
* Workers return concise evidence; long artifacts go to files. The root validates current state and owns final claims.
* Root-authored work needs a fresh blind reviewer only when runnable checks cannot prove acceptance; a non-author root may review worker output directly.

## Judgment

Canonical rubrics with worked examples: `~/.dotfiles/config/agent/rules/judgment.md`. Claude Code auto-loads it; Codex and Gemini must open that path themselves when a trigger below fires.

* Stop and ask the user when an instruction has two readings whose outcomes differ materially, when an action is irreversible or outward-facing and was not explicitly requested, or when the acceptance criteria cannot be verified as stated.
* After a failed attempt, escalate or change approach instead of retrying blindly; the escalation ladder lives in the `agent-delegate` skill.
* When a failure reveals missing or stale reusable guidance, update its owning skill; ignore transient environment failures.
* "Done" means acceptance criteria proved by runnable checks or non-author read-back — never by the author's impression.

## Version Control

Principle: use judgment to keep history easy to review, revert, and continue. Prefer semantic topic commits over file-count, component-name, or time-order boundaries.

When the topic boundary is unclear, follow these fallback rules unless repo instructions override them.
* In `jj + git` colocated repos, use `jj` exclusively; never use `git`. Use the `jj` skill (Claude slash form `/jj`) for detailed guidance.
* Before editing in a jj repo, pick the flow: `@` clean → `jj new -m "<component>: <title>"` first, work lands above `@`; `@` holding sticky local junk → edit, then `jj split <files> -m "..."` per topic. Full working model: `~/.dotfiles/config/agent/rules/jj.md` (auto-loaded in Claude Code; other agents read it on demand).
* Topic judgment: one topic has one semantic reason to exist, one owner/reviewer context, one revert boundary, and one concise summary.
* Same topic: squash follow-up edits that refine, fix, complete, or verify that concern, even across files or after user review.
* Different topics: split changes that have independent reasons, owner/reviewer contexts, revert boundaries, or unrelated final-summary bullets.
* Incidental edits: keep required incidental edits with their topic; split drive-by cleanup, tooling migration, generated/content fixes, docs/rules updates, and behavior changes only when independently meaningful.
* In jj, `jj commit`/`jj split` leaves a fresh empty `@`; do not run `jj new` from an empty `@`.
* For large work, commit small checkpoints, then squash into a topic commit after relevant checks pass, unless I say not to. For small work, commit the topic directly.
* Leave unrelated dirty files untouched.
* Do not run destructive ops (`git reset --hard`, `git push --force`, `git checkout --`) unless I explicitly instruct or a skill explicitly requires it. Use `jj abandon`, `jj squash`, `jj rebase` carefully and read the `jj` skill before using them.
* Do not run `jj git *`, `jj undo`, or mutating `jj op` subcommands (`jj op abandon`, `jj op integrate`, `jj op restore`, `jj op revert`) unless I explicitly ask; syncing with remotes and operation-log recovery are my job. `jj op log` is allowed for read-only inspection. Never bypass VCS safety or immutability protections, such as `jj --ignore-immutable`.
* Do not use Conventional Commits format (e.g., `feat(...):`, `fix(...):`). Use `component: title` instead.
