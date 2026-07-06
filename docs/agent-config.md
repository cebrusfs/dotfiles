# Agent Config

`config/agent/` is the source of truth for shared agent guidance and skills.
Tool-specific home directories are only adapters.

| Path | Purpose |
|---|---|
| `config/agent/global.md` | Shared durable guidance for personal and corp-safe use |
| `config/agent/claude/` | Claude-only settings and hook wiring |
| `config/agent/codex/` | Codex-only hooks, rules, and stable config template |
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
root `GEMINI.md`: Antigravity can read both `AGENTS.md` and `GEMINI.md`, so a
duplicate root adapter can load the same rules twice.

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

Google-agent maintenance targets Antigravity CLI and IDE/2.0. Gemini CLI is
not supported. The remaining `~/.gemini/` adapters serve Antigravity's native
global instruction and skill discovery paths.

`install-conf/dotbot.conf.yaml` is authoritative for installed home-directory
symlink mappings, including global instruction files, skills, hooks, rules, and
Antigravity skill directories. This section records behavior and
rationale that are not directly readable from that file.

| Agent | Auto-load behavior | Adapter decision |
|---|---|---|
| Claude Code | Reads `CLAUDE.md` for global and repo-local instructions. | Root `CLAUDE.md` stays a symlink to `AGENTS.md` so Claude reads the canonical repo instructions without copied prose. |
| Codex | Reads `AGENTS.md` for global and repo-local instructions, and discovers shared skills through the cross-agent skills path. | Use Codex's native instruction filename while keeping shared skills out of Codex-owned state, cache, and bundled system skill directories. |
| Antigravity CLI | Reads the Gemini global guidance, repo-local `AGENTS.md`, and its CLI-specific user skills and settings locations. | Keep it on the same global Gemini guidance while preserving native skill discovery and merging stable settings into CLI-owned runtime config. |
| Antigravity IDE / 2.0 | Reads the Gemini global guidance, repo-local `AGENTS.md`, and IDE/2.0 skill locations. | Keep IDE/2.0 skill adapters separate because those clients check their own skill discovery locations. |

## Agent Hooks

Claude settings stay symlinked to the managed
[settings source](../config/agent/claude/settings.json); no separate config sync
is needed. Its iTerm2 lifecycle hooks call `$HOME/.config/iterm2/cc-status`
directly, with an executable check that quietly skips installations without
the utility. The native event payload passes through stdin. iTerm2 owns the
utility binary; the settings source owns the event wiring and guard.

iTerm2 3.7.4 only recognizes literal absolute `cc-status` paths and replaces
settings symlinks during installation, so its health check can report these
portable hooks as missing even while they work. The
[upstream installer](https://github.com/gnachman/iTerm2/blob/master/sources/ClaudeCode/ClaudeCodeOnboarding.swift)
recognizes guarded `$HOME` commands and resolves settings symlinks before
writing. Reapply the dotbot link to restore a detached settings file; dotbot
backs it up before restoring the managed symlink.

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
Conventional Commit type prefixes, AI attribution and agent metadata trailers,
overlong first lines, and interactive commit-message editors. The
[shared VCS policy](../config/agent/global.md#version-control) owns which
authorship metadata belongs in commit messages. Project-specific gates such as
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

## Claude Permission Posture

The [shared guidance](../config/agent/global.md) owns the daily approval
boundary. User settings keep `permissions.defaultMode = "auto"` and enable
the Bash sandbox with `autoAllowBashIfSandboxed = true`. Routine commands
inside its filesystem/network boundary need no extra approval. Native
background safety checks and protected-path checks still apply.

The settings list tool cache/install directories and common GitHub/package
hosts explicitly. New network destinations follow Claude's native Auto
per-command host review. Writes outside the allowed directories can use the
native unsandboxed retry, reviewed by the Auto classifier. Keep
`allowUnsandboxedCommands = true`; do not add a blanket Bash allow rule,
excluded task runner, or a custom approval hook. `failIfUnavailable = true`
prevents a missing sandbox from silently becoming unrestricted execution.

The narrow `gh` inspection allow rules preserve the everyday authenticated
CLI workflow, including a native unsandboxed retry when necessary. They do
not pre-approve GitHub mutations. Old project-local Bash allow rules are not
part of the managed baseline; remove them when migrating so broad rules such
as `Bash(gh run *)` cannot skip review for mutations.

Credential file denies protect shell commands; matching `Read(...)` denies
also protect Claude's file tools. Named credential environment variables are
removed from sandboxed commands. This does not isolate MCP servers, hooks,
LSP servers, browsers, or the whole Claude process. Claude's local-address
guard is not Codex's private-network guard: an approved intranet hostname
can resolve to a private address. Sensitive or unattended work needs a
separately chosen outer boundary. See [Claude sandboxing](https://code.claude.com/docs/en/sandboxing)
and [permission modes](https://code.claude.com/docs/en/permission-modes).

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
the adapter back to a plain dotbot symlink.

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

The script syncs the permission profile, `[features.network_proxy]`, and shell
environment inheritance/filter settings, including migrating a legacy
`[features] network_proxy` value to the managed table. It
preserves other feature toggles and local runtime sections such as `[projects]`,
`[hooks.state]`, `[marketplaces]`, `[plugins]`, `[mcp_servers]`, and `[desktop]`,
and strips the legacy sandbox keys managed by the template.

## Codex Permission Posture

Shared Codex execpolicy rules live in `config/agent/codex/rules/agent.rules`,
which dotbot links to `~/.codex/rules/agent.rules`. Keep
`~/.codex/rules/default.rules` as Codex's local mutable allow-list state.
The [shared guidance](../config/agent/global.md) owns the daily approval
boundary. Build and test runners have no outside-sandbox allow rules: their
repository-defined code runs inside the permission profile, without an extra
review. Missing access goes through native approval instead of making the
whole task runner an unrestricted host process.

The remaining allow rules are deliberate exceptions for recoverable local jj
operations, read-only GitHub CLI inspection, and the commit-nudge hook. Codex
protects `.git` even in writable workspaces, so routine jj snapshots and
commits may need this exception. These matching commands can run outside the
sandbox without review. Prefix rules also match trailing arguments; they are
not an isolation boundary. Destructive/outward-action rules still apply.

The default Codex posture is `approval_policy = "on-request"`,
`approvals_reviewer = "auto_review"`, and `default_permissions =
"workspace-tool-caches"`. The `workspace-tool-caches` profile is the built-in
workspace filesystem sandbox plus the listed tool cache/install directories.
The listed GitHub and package/tool distribution hosts are allowed for ordinary
dependency downloads; the enabled proxy retains its local/private-network
guard. Other destinations use the native approval flow. Local services,
SSH-agent/Docker sockets, and additional write locations are not globally
opened. Explicit credential read denies and child-environment filters reduce
the login material available to sandboxed commands. The agent client retains
its own login, and the existing GitHub CLI inspection exception retains its
normal authenticated workflow.

Access beyond this profile follows `on-request` approval with the native
`auto_review` reviewer. Full command escalation can run outside the sandbox;
it is broader than a narrow permission grant. Do not add a broad runner allow
rule to suppress that review. Read-only/headless workers keep their explicitly
selected profile and approval policy.

Verified with Codex CLI 0.161.0 on 2026-10-09: the network proxy is experimental;
fine-grained permission-request features remain disabled. This setup does not
depend on those features or promise per-command domain grants. An allowed
destination can still receive readable project data; this is not a
download-only policy. The proxy does not cover MCP, apps, browsers, or the
client's service traffic. See [Codex permissions](https://learn.chatgpt.com/docs/permissions)
and [Auto-review](https://learn.chatgpt.com/docs/sandboxing/auto-review).
`web_search = "live"` separately controls the hosted web-search tool.
