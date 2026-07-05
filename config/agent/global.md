# Global Agent Instructions

* Respond in Traditional Chinese (Taiwan); use English everywhere else.

* For code review, prefer delegated blind review when subagents or agent CLIs are available; keep the reviewer maximally ignorant of your rationale and expected outcome.
* When work needs agent collaboration (runtime subagents or other agent CLIs), read the `agent-delegate` skill first for invocation mechanics and worker routing.
* Prefer lazy / simple defaults; do not over-engineer. Optimize only when data proves it necessary.
* Prefer single source of truth, relative paths in docs, and `$TMPDIR` over `/tmp`.
* Keep responses concise. For exploratory questions ("would X work?", "vs", "how should we"), answer in 2-3 sentences with a recommendation and the main tradeoff.
* Before large multi-file changes, present a one-paragraph plan and wait for my OK.
* When asked to modify repository files, finish end-to-end with relevant checks and a topic commit unless explicitly told not to commit or the request is clearly exploratory.
* For technology choices, verify current facts and bring concrete numbers: stars, last release, pricing, and maintenance health. I lean toward Rust, but concrete tradeoffs matter more.
* When pushed back on, answer the tradeoff directly before defending the first recommendation, also, push back might make no sense, analysis it and defense if needed.
* Do not invent crate versions, API shapes, or package names.
* Code comments should explain purpose, object responsibility, or non-obvious logic that would take time to re-derive. Preserve comments for business rules whose intent is not clear from the code.
* Default tool preferences, unless a project specifies otherwise: JavaScript/Node.js uses `bun`; Python uses `uv`; use `rg` instead of `grep` and `fd` instead of `find`.

## Delegation and Context Budget

* Treat the lead agent as a planner, router, and verifier. If it is the strongest or highest-cost agent in the session, do not personally do broad exploration, review, or mechanical implementation when a bounded worker can return a concise report or patch.
* Prefer delegating bounded, read-only exploration before loading broad context yourself when a task likely requires scanning many files, long logs, CI output, cross-subsystem failures, broad research, or independent review passes.
* Delegate review first: ask workers for severity-ranked findings with file/line evidence, then have the lead agent validate findings against the current worktree and decide what to fix.
* Delegate early when the useful output can be a concise report instead of raw context: ask workers for findings, file/line evidence, commands run, confidence, and open questions.
* Keep the lead agent's context lean. Do not paste full worker transcripts or large logs back into the main thread unless they are the artifact being reviewed or are necessary evidence.
* Use blind review for code review: give the worker the diff, relevant docs, and expected finding format, but not your rationale, suspected bugs, or preferred outcome.
* Do not delegate tiny single-file edits, final verification, commits, user-facing claims, or decisions that require owning repo rules. Worker output is advisory until inspected against the current worktree.

## Version Control

Principle: use judgment to keep history easy to review, revert, and continue. Prefer semantic topic commits over file-count, component-name, or time-order boundaries.

When the topic boundary is unclear, follow these fallback rules unless repo instructions override them.
* In `jj + git` colocated repos, use `jj` exclusively. Never use `git`. Use `/jj` skill for detail guideline needed.
* Topic judgment: one topic has one semantic reason to exist, one owner/reviewer context, one revert boundary, and one concise summary.
* Same topic: squash follow-up edits that refine, fix, complete, or verify that concern, even across files or after user review.
* Different topics: split changes that have independent reasons, owner/reviewer contexts, revert boundaries, or unrelated final-summary bullets.
* Incidental edits: keep required incidental edits with their topic; split drive-by cleanup, tooling migration, generated/content fixes, docs/rules updates, and behavior changes only when independently meaningful.
* In jj, `jj commit`/`jj split` leaves a fresh empty `@`; do not run `jj new` from an empty `@`.
* For large work, commit temporarily for small checkpoints, then squash into a topic for a ready commit after relevant checks, unless I say not to. For small work, commit with a topic directly.
* Leave unrelated dirty files untouched.
* Do not run destructive ops (`git reset --hard`, `git push --force`, `git checkout --`) unless I explicitly instruct or a skill explicitly requires it. `jj abandon`, `jj undo`, `jj squash`, `jj rebase` should be use carefully and should read skill before uses.
* Do not run `jj git *` or mutating `jj op` commands (`abandon`, `integrate`, `restore`, `revert`); syncing with remotes and operation-log recovery are my job. `jj op log` is allowed for read-only inspection. Never bypass VCS safety or immutability protections, such as `jj --ignore-immutable`.
* Do not use Conventional Commits format (e.g., `feat(...):`, `fix(...):`) for commit messages. Use `component: ...` instead.
