# Agent Config

`config/agent/` is the source of truth for shared agent guidance and skills.
Tool-specific home directories are only adapters.

| Path | Purpose |
|---|---|
| `config/agent/global.md` | Shared durable guidance for personal and corp-safe use |
| `config/agent/claude/` | Claude-only settings and hook wiring |
| `config/agent/codex/` | Codex-only hooks, rules, and stable config template |
| `config/agent/gemini/` | Gemini CLI settings needed to read shared project instructions |
| `config/agent/antigravity/` | Antigravity CLI stable config template and sync script |
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

`install-conf/dotbot.conf.yaml` is authoritative for installed home-directory
symlink mappings, including global instruction files, skills, hooks, rules, and
Gemini/Antigravity skill directories. This section records behavior and
rationale that are not directly readable from that file.

| Agent | Auto-load behavior | Adapter decision |
|---|---|---|
| Claude Code | Reads `CLAUDE.md` for global and repo-local instructions. | Root `CLAUDE.md` stays a symlink to `AGENTS.md` so Claude reads the canonical repo instructions without copied prose. |
| Codex | Reads `AGENTS.md` for global and repo-local instructions, and discovers shared skills through the cross-agent skills path. | Use Codex's native instruction filename while keeping shared skills out of Codex-owned state, cache, and bundled system skill directories. |
| Gemini CLI | Reads global `GEMINI.md`; the managed `context.fileName` setting makes it read repo-local `AGENTS.md`. | Avoid per-repo `GEMINI.md` shims while keeping Antigravity from loading duplicate repo rules. |
| Antigravity CLI | Reads the Gemini global guidance, repo-local `AGENTS.md`, and its CLI-specific user skills and settings locations. | Keep it on the same global Gemini guidance while preserving native skill discovery and merging stable settings into CLI-owned runtime config. |
| Antigravity IDE / 2.0 | Reads the Gemini global guidance, repo-local `AGENTS.md`, and IDE/2.0 skill locations. | Keep IDE/2.0 skill adapters separate because those clients check their own skill discovery locations. |

Gemini CLI also supports `~/.gemini/skills`; avoid wiring it here because
`~/.agents/skills` already covers Gemini and Codex. Keeping one Gemini-visible
general skill adapter avoids duplicate skill discovery.

`config/agent/gemini/settings.json` is intentionally sparse. Keep only stable,
non-secret user defaults there, especially `context.fileName`, so Gemini CLI can
read `AGENTS.md` in any repository without requiring per-repo `GEMINI.md`
shims.

## Agent Hooks

`config/agent/hooks/validate-commit-message.py` is the shared commit-message style
validator. `config/agent/hooks/jj-guard.py` is the shared guard for jj
safety-bypass flags (`--ignore-immutable`) that prefix-based deny patterns and
execpolicy rules cannot match; both are wired as PreToolUse hooks for Claude
(`config/agent/claude/settings.json`) and Codex (`config/agent/codex/hooks.json`). Both accept native hook JSON on stdin for global Claude/Codex
PreToolUse hooks; only `validate-commit-message.py` additionally supports
`AGENT_COMMIT_COMMAND` for project wrapper scripts that already extracted a
shell command from hook JSON.

When a project should use the same policy, vendor a project-local copy and
register that Python script directly in each runtime adapter. Use a wrapper only
when the project has a real project-specific pre-check, and forward the native
hook payload to this validator instead of reimplementing command detection. Do
not make a shared project depend on `$HOME/.dotfiles` at runtime; sync the
standalone script manually so collaborators get the same behavior.

Keep this checker generic: it validates `<component>: <title>`, rejects common
Conventional Commit type prefixes, AI attribution trailers, overlong first
lines, and interactive commit-message editors. Project-specific gates such as
`make fmt`, `make lint`, or product-specific examples belong in a wrapper only
when that extra pre-check exists; otherwise keep them in project docs.

The checker intentionally stays short of being a shell parser. It validates
simple inline `-m/--message` values and allows non-inline message sources such
as `jj describe --stdin` and `git commit -F/--file`, but it does not decode
shell-specific multiline quoting such as `$'...\n...'`. For multiline commit
messages, feed the message through stdin or a temporary message file under
`$TMPDIR` instead of relying on shell escape syntax.

Run hook tests through `mise run test:hooks`, or set `PYTHONDONTWRITEBYTECODE=1`
when invoking `python3 -m unittest` directly. Bare Python test runs write
`__pycache__` into `config/agent/hooks/`.

Gemini CLI hooks are not wired here: its official
[hook reference](https://geminicli.com/docs/hooks/reference/) requires hook
declarations in `settings.json`, and `~/.gemini/config/hooks` is not a
documented discovery path (verified 2026-07-10).

## Antigravity CLI Permissions

Antigravity CLI stores user settings at
`~/.gemini/antigravity-cli/settings.json`.
`config/agent/antigravity/settings.json` is a stable template, **not** a symlink
target. It owns the stable `enableTelemetry`, `colorScheme`, and `model`
preferences. Runtime state such as `trustedWorkspaces`, plus unknown top-level
or nested keys added by the CLI, stays local.

Like the [Codex Config Template](#codex-config-template), the sync script is not
directly executable and defaults to a dry-run diff. Apply it with
`mise run sync:antigravity` (which runs
`config/agent/antigravity/sync-config.py` through `uv`); template keys overlay
recursively while every unmanaged local key is preserved.

`./install` and `./update` run this next to the Codex config sync. JSON output is
deterministic, so a second apply makes no change. On first apply, the script
replaces any legacy dotbot symlink with a regular CLI-owned settings file.

The template+sync design exists only because the CLI writes runtime trust
state (`trustedWorkspaces`) into the same `settings.json`. If a future CLI
version moves trust state out of that file, delete `sync-config.py` and switch
the adapter back to a plain dotbot symlink like the Gemini settings.

Hard command-blocking **landed 2026-07-11**: the template's `permissions.deny`
mirrors Claude's jj deny list as `command(<target> *)` grant strings, in
`antigravity-cli/settings.json` itself. The schema was captured by adding one
rule through the interactive `/permissions` panel and diffing the file; a
fresh session then logs
`CLI settings initialized: permissions=&{Allow:[] Deny:[command(jj git *) ...] Ask:[]}`,
and enforcement was verified headless — with a probe rule `command(touch *)`,
`agy -p` refused to run `touch` and created nothing. Earlier probes failed on
grant syntax/structure, not location (invalid entries are dropped with an
`ignoring invalid ... grant string` log warning) — after changing rules, check
the startup log line instead of assuming they loaded.

Caveat: the sync replaces the whole `deny` array with the template's. A rule
added via `/permissions` survives only until the next sync — promote it into
the template if it should persist.

## Codex Config Template

`config/agent/codex/config.toml` is a safe template, **not** a symlink target for
`~/.codex/config.toml`. Keep personal, runtime, and project trust state in the
local Codex config. If copying the template's permission profile into the local
config, do not mix it with legacy `sandbox_mode` / `[sandbox_workspace_write]`
settings; use one sandbox configuration model per session.

The sync script is not directly executable; apply it with `mise run sync:codex`
(which runs `config/agent/codex/sync-config.py` through `uv`) to sync stable
Codex defaults into the local runtime config.

`./install` runs this sync after installing dev tools, and `./update` runs it
after updating dev tools.

The script syncs the permission profile and `[features.network_proxy]`, including
migrating a legacy `[features] network_proxy` value to the managed table. It
preserves other feature toggles and local runtime sections such as `[projects]`,
`[hooks.state]`, `[marketplaces]`, `[plugins]`, `[mcp_servers]`, and `[desktop]`,
and strips the legacy sandbox keys managed by the template.

## Codex Permission Posture

Shared Codex execpolicy rules live in `config/agent/codex/rules/agent.rules`,
which dotbot links to `~/.codex/rules/agent.rules`. Keep
`~/.codex/rules/default.rules` as Codex's local mutable allow-list state.
The shared global guidance selects the repository-documented task runner for
standard verification; this rules file mechanically allows selected routine
verification and recoverable local jj command prefixes. Prefix rules also
match trailing arguments, so they do not guarantee that a command contains
only the named target. Agents must still honor repository guidance and the
shared destructive/outward-action rules.

The default Codex posture is `approval_policy = "on-request"`,
`approvals_reviewer = "auto_review"`, and `default_permissions =
"workspace-tool-caches"`. The `workspace-tool-caches` profile is the built-in
workspace filesystem sandbox plus writable mise, uv, and Bun cache roots. It
does not grant package-registry network access. The synced
`features.network_proxy.enabled = true` activates enforcement of the profile's
`api.github.com` and `github.com` allowlist for sandboxed shell commands; without
the proxy, enabling command networking does not enforce those domain rules.
See the [Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).
`web_search = "live"` controls the agent's
web-search tool, not network access for spawned CLI commands such as `gh`.
