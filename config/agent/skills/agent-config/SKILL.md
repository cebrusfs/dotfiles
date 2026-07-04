---
name: agent-config
description: Design or maintain repo-local agent configuration layout. Use when adding or reviewing AGENTS.md, CLAUDE.md, GEMINI.md, .agents/skills, .codex, .gemini, .claude, MCP files, hooks, or other per-repository config for Claude Code, Codex, Gemini CLI, and Antigravity.
---

# Repo Agent Config

Use this skill to set up agent config inside a normal application, library, or
tooling repository. Keep one canonical source for shared repo instructions, and
use `.agents/skills` as the canonical place for repo-local skills. Add
tool-specific files only when a tool needs a native discovery path or actual
tool-specific behavior.

## Default Layout

Start with this structure:

```text
AGENTS.md                  # Canonical repo instructions.
.agents/
  skills/<skill>/SKILL.md  # Canonical repo-scoped Agent Skills.
```

Add these only when needed:

| Path | Add when | Notes |
|---|---|---|
| `CLAUDE.md` | Claude users need native repo instructions | Prefer symlink or a tiny pointer to `AGENTS.md`; do not duplicate content. |
| `GEMINI.md` | Gemini users cannot rely on `context.fileName = ["AGENTS.md", "GEMINI.md"]` | Prefer symlink or pointer. Avoid if Antigravity would load both `AGENTS.md` and `GEMINI.md`. |
| `.codex/config.toml` | The repo needs Codex-specific settings, MCP, sandbox, fallback instruction filenames, or project hooks | Keep personal model/provider choices out of shared repo config. |
| `.codex/hooks.json` or `.codex/rules/*.rules` | The repo needs Codex lifecycle enforcement or exec-policy rules | Hooks/rules load only for trusted Codex projects. Prefer repo-relative scripts. |
| `.gemini/settings.json` | The repo needs Gemini-specific settings, sandbox profile, context filenames, or MCP config | Keep auth, secrets, and personal UI prefs out. |
| `.gemini/sandbox.Dockerfile` or `.gemini/sandbox-*.sb` | The repo needs Gemini sandbox customization | Mention the command/env required to use it in `AGENTS.md`. |
| `.agents/mcp_config.json` | Antigravity workspace MCP servers are needed | Keep secrets in environment variables, not committed JSON. |
| `.claude/settings.local.json` | A developer needs local Claude permissions or experiments | Usually do not commit; prefer user-local state. |

## Instruction Files

- Put repo-wide durable instructions in root `AGENTS.md`.
- Put subtree-specific instructions in nested `AGENTS.md` only when the subtree
  really differs.
- Use `CLAUDE.md` and `GEMINI.md` as adapters, not second sources of truth.
- If symlinks are acceptable in the repo, use `CLAUDE.md -> AGENTS.md` and,
  only when necessary, `GEMINI.md -> AGENTS.md`.
- If symlinks are undesirable for a cross-platform team, make adapter files
  short pointers that say the canonical instructions are in `AGENTS.md`.

Avoid `.agents/AGENTS.md` as an instruction adapter. Current mainstream
repo-local uses of `.agents/` are skills and Antigravity workspace MCP config;
root `AGENTS.md` is the clearer canonical instruction path.

## Repo Skills

Use `.agents/skills/<name>/SKILL.md` as the canonical repo-scoped skills path.
For a normal repo, this is the right shared location for workflows that should
travel with the codebase. Codex, Gemini CLI, and Antigravity support
`.agents/skills` for workspace skills. Prefer this over tool-specific skill
folders. Add `.gemini/skills` only for legacy Gemini-only compatibility, and
avoid keeping both paths with copied content.

Keep skills focused on reusable workflows. Do not turn `AGENTS.md` into a large
skill catalog; if a workflow has steps, references, scripts, or decision rules,
make it a skill.

## Tool-Specific Dirs

Use hidden tool directories for runtime behavior, not shared instruction prose:

- `.codex/`: Codex project config, hooks, rules, MCP, and Codex-only settings.
- `.gemini/`: Gemini project settings, sandbox files, and legacy Gemini skill
  compatibility.
- `.claude/`: usually local Claude state; commit only deliberate shared Claude
  settings after checking they contain no personal paths or permissions.
- `.agents/`: cross-agent skills and Antigravity workspace MCP config.

When a setting affects all agents, put it in `AGENTS.md`. When it mechanically
enforces behavior for one tool, put it under that tool's directory.

## Review Checklist

1. Is there exactly one canonical repo instruction file?
2. Are adapter files symlinks or tiny pointers instead of copied prose?
3. Are repo skills under `.agents/skills` unless a tool-specific path is truly
   required?
4. Are secrets, auth, trust state, generated files, logs, and personal UI prefs
   excluded?
5. Are tool-specific configs justified by actual behavior, not created for
   symmetry?
6. Are verification commands and project-specific workflow rules in `AGENTS.md`?

Agent path support changes. Before changing claims about Claude, Codex, Gemini,
or Antigravity discovery paths, verify current official docs first.
