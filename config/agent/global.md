# Global Agent Instructions

* Respond in Traditional Chinese (Taiwan); use English everywhere else.

* While code review with subagent, use blind review and maximal ignorant.
* Prefer lazy / simple defaults; do not over-engineer. Optimize only when data proves it necessary.
* Prefer single source of truth, relative paths in docs, and `$TMPDIR` over `/tmp`.
* Keep responses concise. For exploratory questions ("would X work?", "vs", "how should we"), answer in 2-3 sentences with a recommendation and the main tradeoff.
* Before large multi-file changes, present a one-paragraph plan and wait for my OK.
* For technology choices, verify current facts and bring concrete numbers: stars, last release, pricing, and maintenance health. I lean toward Rust, but concrete tradeoffs matter more.
* When pushed back on, answer the tradeoff directly before defending the first recommendation, also, push back might make no sense, analysis it and defense if needed.
* Do not invent crate versions, API shapes, or package names.
* Comments should only record purpose, object responsibility, or complex logic that would take time to re-derive, but also avoid leave business logic without comments.
* Default tool preferences, unless a project specifies otherwise: JavaScript/Node.js uses `bun`; Python uses `uv`; use `rg` instead of `grep` and `fd` instead of `find`.

## Version Control

By default, follow belows unless repo preference presents.
* In `jj + git` colocated repos, use `jj` exclusively. Never use `git`. Use `/jj` skill for detail guideline needed.
* One topic = one commit; squash same-topic follow-ups into that local commit.
* In jj, `jj commit`/`jj split` leaves a fresh empty `@`; do not run `jj new` from an empty `@`.
* For large work, commit temporarily for small checkpoints, then squash into a topic for a ready commit after relevant checks, unless I say not to. For small work, commit with a topic directly.
* Leave unrelated dirty files untouched.
* Do not run destructive ops (`git reset --hard`, `git push --force`, `git checkout --`) unless I explicitly instruct or a skill explicitly requires it. `jj abandon`, `jj undo`, `jj squash`, `jj rebase` should be use carefully and should read skill before uses.
* Do not run `jj git *` or `jj op *`; syncing with remotes and operation-log recovery are my job. Never bypass VCS safety or immutability protections, such as `jj --ignore-immutable`.
* Do not use Conventional Commits format (e.g., `feat(...):`, `fix(...):`) for commit messages. Use `coponent: ...` instead.
