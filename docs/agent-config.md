# Agent Config

`config/agent/` is the source of truth for shared agent guidance and skills.
Tool-specific home directories are only adapters.

| Path | Purpose |
|---|---|
| `config/agent/global.md` | Shared durable guidance for personal and corp-safe use |
| `config/agent/claude/` | Claude-only settings and hook wiring |
| `config/agent/codex/` | Codex-only hooks, rules, and stable config template |
| `config/agent/skills/` | Shared Agent Skills source |
| `~/.claude/skills` | Claude skill adapter |
| `~/.agents/skills` | User-level Agent Skills adapter for Codex and Gemini CLI |

`config/agent/skills/` is the only skill source of truth. Do not put custom
skills under `~/.codex/skills`; Codex keeps its own state, cache, and bundled
system skills there.

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
