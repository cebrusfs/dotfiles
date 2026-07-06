# Agent Config

`config/agent/` is the source of truth for shared agent guidance and skills.
Tool-specific home directories are only adapters.

| Path | Purpose |
|---|---|
| `config/agent/global.md` | Shared durable guidance for personal and corp-safe use |
| `config/agent/claude/` | Claude-only settings and hook wiring |
| `config/agent/codex/` | Codex-only hooks, rules, and stable config template |
| `config/agent/gemini/` | Gemini CLI settings needed to read shared project instructions |
| `config/agent/hooks/` | Shared hook implementations used by Claude and Codex adapters |
| `config/agent/skills/` | Shared Agent Skills source |

`config/agent/skills/` is the only skill source of truth. Do not put custom
skills under `~/.codex/skills`; Codex keeps its own state, cache, and bundled
system skills there.

## Instruction Layers

Keep durable instruction content in one of two places:

- `config/agent/global.md`: personal defaults for every repository and agent.
- `AGENTS.md`: instructions that only apply to this dotfiles repository.

Adapters should point at those files instead of copying their contents. In this
repo, `CLAUDE.md` is a symlink to `AGENTS.md` for Claude Code. Do not add a
root `GEMINI.md` unless Gemini CLI stops honoring the managed
`context.fileName` setting; Antigravity can read both `AGENTS.md` and
`GEMINI.md`, so a duplicate root adapter can load the same rules twice.

## This Repo's Local Layout

The root of this repository should stay minimal:

| Path | Purpose |
|---|---|
| `AGENTS.md` | Canonical repo-local instructions for every agent |
| `CLAUDE.md -> AGENTS.md` | Claude Code adapter for the same repo-local instructions |

Do not add `.agents/AGENTS.md`; `.agents/` is for repo-scoped skills and
Antigravity workspace MCP config, not instruction shims. Do not add
`.agents/skills -> config/agent/skills` in this repo either: `config/agent/skills`
is the source for managed user-global skills, not repo-local skills. Symlinking
it into `.agents/skills` would make the same skills appear as both user and
workspace skills.

## Adapter Map

| Agent | Global instruction adapter | Project instruction adapter | Skills adapter |
|---|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md -> config/agent/global.md` | `CLAUDE.md -> AGENTS.md` | `~/.claude/skills -> config/agent/skills` |
| Codex | `~/.codex/AGENTS.md -> config/agent/global.md` | `AGENTS.md` | `~/.agents/skills -> config/agent/skills` |
| Gemini CLI | `~/.gemini/GEMINI.md -> config/agent/global.md` | `AGENTS.md` via `context.fileName` in `~/.gemini/settings.json` | `~/.agents/skills -> config/agent/skills` |
| Antigravity CLI | `~/.gemini/GEMINI.md -> config/agent/global.md` | `AGENTS.md` | `~/.gemini/antigravity-cli/skills -> config/agent/skills` |
| Antigravity IDE / 2.0 | `~/.gemini/GEMINI.md -> config/agent/global.md` | `AGENTS.md` | `~/.gemini/antigravity/skills` and `~/.gemini/config/skills` -> `config/agent/skills` |

Gemini CLI also supports `~/.gemini/skills`; avoid wiring it here because
`~/.agents/skills` already covers Gemini and Codex. Keeping one Gemini-visible
general skill adapter avoids duplicate skill discovery.

`config/agent/gemini/settings.json` is intentionally sparse. Keep only stable,
non-secret user defaults there, especially `context.fileName`, so Gemini CLI can
read `AGENTS.md` in any repository without requiring per-repo `GEMINI.md`
shims.

## Agent Hooks

`config/agent/hooks/commit-message-check.py` is the shared commit-message style
validator. `config/agent/hooks/jj-guard.py` is the shared guard for jj
safety-bypass flags (`--ignore-immutable`) that prefix-based deny patterns and
execpolicy rules cannot match; both are wired as PreToolUse hooks for Claude
(`config/agent/claude/settings.json`) and Codex (`config/agent/codex/hooks.json`). Both accept native hook JSON on stdin for global Claude/Codex
PreToolUse hooks; only `commit-message-check.py` additionally supports
`AGENT_COMMIT_COMMAND` for project wrapper scripts that already extracted a
shell command from hook JSON.

When a project should use the same policy, keep a project-local copy of this
script and call that copy from the project's hook wrapper. Do not make a shared
project depend on `$HOME/.dotfiles` at runtime; sync the standalone script
manually so collaborators get the same behavior.

Keep this checker generic: it validates `<component>: <title>`, rejects common
Conventional Commit type prefixes, AI attribution trailers, overlong first
lines, and interactive commit-message editors. Project-specific gates such as
`make fmt`, `make lint`, or product-specific examples belong in the project
wrapper script or project docs, not in this shared checker.

The checker intentionally stays short of being a shell parser. It validates
simple inline `-m/--message` values and allows non-inline message sources such
as `jj describe --stdin` and `git commit -F/--file`, but it does not decode
shell-specific multiline quoting such as `$'...\n...'`. For multiline commit
messages, feed the message through stdin or a temporary message file under
`$TMPDIR` instead of relying on shell escape syntax.

Run hook tests through `mise run test:hooks`, or set `PYTHONDONTWRITEBYTECODE=1`
when invoking `python3 -m unittest` directly. Bare Python test runs write
`__pycache__` into `config/agent/hooks/`.

## Codex Config Template

`config/agent/codex/config.toml` is a safe template, **not** a symlink target for
`~/.codex/config.toml`. Keep personal, runtime, and project trust state in the
local Codex config. If copying the template's permission profile into the local
config, do not mix it with legacy `sandbox_mode` / `[sandbox_workspace_write]`
settings; use one sandbox configuration model per session.

Sync stable Codex defaults into the local runtime config with:

```sh
uv run --no-project --managed-python --python cpython python config/agent/codex/sync-config.py --apply
```

`./install` runs this sync after installing dev tools, and `./update` runs it
after updating dev tools.

The script preserves local runtime sections such as `[projects]`, `[hooks.state]`,
`[marketplaces]`, `[plugins]`, `[mcp_servers]`, and `[desktop]`, and strips the
legacy sandbox keys managed by the template.

## Codex Permission Posture

Shared Codex execpolicy rules live in `config/agent/codex/rules/agent.rules`,
which dotbot links to `~/.codex/rules/agent.rules`. Keep
`~/.codex/rules/default.rules` as Codex's local mutable allow-list state.

The default Codex posture is `approval_policy = "on-request"`,
`approvals_reviewer = "auto_review"`, and `default_permissions =
"workspace-mise"`. The `workspace-mise` profile is the built-in workspace
filesystem sandbox plus a writable `mise` cache. It also grants scoped shell
network access to `api.github.com` and `github.com`, so sandboxed read-only
GitHub CLI inspection works without broad network access. `web_search = "live"`
controls the agent's web-search tool, not network access for spawned CLI commands
such as `gh`.
