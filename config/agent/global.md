# Global Agent Instructions

* Respond in Traditional Chinese (Taiwan); use English everywhere else.

* Prefer lazy / simple defaults; do not over-engineer. Optimize only when data proves it necessary.
* Prefer single source of truth, relative paths in docs, and `$TMPDIR` over `/tmp`.
* Keep responses concise. For exploratory questions ("would X work?", "vs", "how should we"), answer in 2-3 sentences with a recommendation and the main tradeoff.
* Before large multi-file changes, present a one-paragraph plan and wait for my OK.
* For technology choices, verify current facts and bring concrete numbers: stars, last release, pricing, and maintenance health. I lean toward Rust, but concrete tradeoffs matter more.
* When pushed back on, answer the tradeoff directly instead of defending the first recommendation.
* Do not invent crate versions, API shapes, or package names.
* Comments should only record purpose, object responsibility, or complex logic that would take time to re-derive.
* Default tool preferences, unless a project specifies otherwise: JavaScript/Node.js uses `bun`; Python uses `uv`; use `rg` instead of `grep` and `fd` instead of `find`.

## Version Control

* In `jj + git` colocated repos, use `jj` exclusively. Never use `git add`, `git commit`, or `git stash`.
* Follow repo jj guidance when present, such as `config/agent/rules/jj.md`.
* One topic = one commit; squash same-topic follow-ups into that local commit.
* In jj, `jj commit`/`jj split` leaves a fresh empty `@`; do not run `jj new` from an empty `@`.
* Checkpoint only completed implementation topics after relevant checks, unless I say not to. Report the change id or why no checkpoint was created.
* Do not checkpoint exploration, planning, review-only work, failed experiments, or incomplete work.
* Leave unrelated dirty files untouched.
* Do not run destructive ops (`git reset --hard`, `git push --force`, `git checkout --`, `jj abandon`, `jj undo`, `jj squash`, `jj rebase`) unless I explicitly instruct or a skill explicitly requires it.
* Never bypass VCS safety or immutability protections, such as `jj --ignore-immutable`.
* Do not run `jj git *` or `jj op *`; syncing with remotes and operation-log recovery are my job.
* When a hook fails, fix the root cause - never skip with `--no-verify`.
* Do not use Conventional Commits format (e.g., `feat(...):`, `fix(...):`) for commit messages.
