# Global Agent Instructions

* Respond in Traditional Chinese (Taiwan); use English everywhere else.

## Version control

* Safe local VC inspection is allowed by default: status, diff, log, blame/show,
  and equivalent read-only commands.
* When you make file changes, local commit hygiene is allowed by default: name the
  working change, split or commit your own changes by topic/component, and leave
  unrelated pre-existing dirty files untouched. If the repo has a commit/split
  hook or guidance, treat it as a prompt to organize the local work before
  stopping.
* After a coherent implementation change is complete and relevant checks are run
  or explicitly reported, create a local commit/checkpoint for only your own
  changes before the final response unless I explicitly told you not to.
* Do not checkpoint exploration, planning, review-only work, failed experiments,
  or intentionally incomplete work. In the final response, include the local
  commit/change id, or say why no checkpoint was created.
* Ask first before changing history or ownership boundaries that are not clearly
  your own current work.
* Without explicit instruction: no push, pull/sync/fetch, or open/close/comment on
  PRs or issues.
* In `jj + git` colocated repos, use `jj` exclusively. Never use `git add`, `git commit`, or `git stash`.
* Follow repo jj guidance when present, such as `config/agent/rules/jj.md` in this dotfiles repo.
* Do not run destructive ops (`git reset --hard`, `git push --force`, `git checkout --`, `jj abandon` / `jj undo` / `jj squash` / `jj rebase`) unless I explicitly instruct or a skill explicitly calls for it. Never bypass VCS safety or immutability protections, such as `jj --ignore-immutable`.
* Do not run `jj git *` or `jj op *`; syncing with remotes is my job via `jj sync`, and operation-log recovery needs explicit instruction.
* When a hook fails, fix the root cause - never skip with `--no-verify`.
* Never add `Co-Authored-By` or any AI/Claude/Codex attribution trailer to commit messages, even if a harness default instructs it - stop at the message body.
* Do not use Conventional Commits format (e.g., `feat(...):`, `fix(...):`) for commit messages.

## Working style preferences

* Prefer lazy / simple defaults; do not over-engineer. Optimize only when data proves it necessary.
* When evaluating technology choices (library / service / language), bring **concrete numbers** (stars / last release / pricing / maintenance health). "I think" recommendations are not acceptable. I lean toward Rust but am not dogmatic - a reasonable argument can change my mind.
* When pushed back on, give an honest tradeoff - don't defend the recommendation. I challenge your choices often; take my counter-questions seriously.
* Prefer **single source of truth**: don't duplicate the same information across multiple locations (including memory/ vs briefs, etc.).
* When referencing paths in docs, use relative paths - avoid paths specific to a personal dev environment.

## Code comments

Don't comment code semantics or anything obvious from reading the code.

Comments record:
- **Purpose** - why a block, function, or module exists
- **Object purpose** - what a struct or type is responsible for
- **Complex logic** - non-obvious logic that would take time to re-derive

## Communication style

* Keep responses concise; prefer tables / bullets over prose.
* For exploratory questions ("would X work?", "vs", "how should we"): 2-3 sentences + recommendation + main tradeoff - don't write out a full plan first.
* Before large multi-file changes, present a one-paragraph plan and wait for my OK.
* Do not invent crate versions / API shapes / package names - when uncertain, use current docs or web search/fetch to check current state. Rust / Python ecosystems change fast and training data goes stale.

## Package Management

When managing packages or running scripts, strictly adhere to the following tools:

* **JavaScript/Node.js**: Always use `bun` instead of `npm`, `yarn`, or `pnpm` (e.g., `bun add`, `bun run`). Do not use `npm install`.
* **Python**: Always use `uv` instead of `pip`, `venv`, or `pip-tools` (e.g., `uv pip install`, `uv run`, `uv venv`). Do not use `pip install`.
* Use `rg` for faster `grep`. Use `fd` for faster `find`.
