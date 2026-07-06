# Agent Instructions

## Overview

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot). Files in `config/` are symlinked into `~` by dotbot; `install-conf/dotbot.conf.yaml` is the single source of truth for all symlink mappings.

VCS use `jj` in colocated mode (Use /jj skill when needed)

## Key Commands

```bash
# Run the same lint + format checks CI runs (do this before committing)
mise run check

# Run agent hook tests without writing __pycache__ into the repo
mise run test:hooks

# Re-run dotbot after editing symlink mappings
modules/dotbot/bin/dotbot -d . -c install-conf/dotbot.conf.yaml --only create link
```

Before committing any change, run `mise run check` and ensure it passes — CI
(`.github/workflows/lint.yaml`) runs the identical task, so a skipped check
becomes a red build. Judge success by the exit status, never by skimming
output: piping into `tail`/`head` swallows the failure code (redirect to a
file first if the output needs trimming).

For direct hook-test probes, set `PYTHONDONTWRITEBYTECODE=1` when invoking
`python3 -m unittest`; bare Python test runs write `__pycache__` into
`config/agent/hooks/`.

For Neovim smoke tests and ad hoc headless probes, isolate state under `$TMPDIR`,
disable plugin loading, disable ShaDa, and disable swapfiles so headless runs do
not write `nvim.log` into the repo, touch the real `~/.local/state/nvim`, or
emit swapfile warnings:

```bash
env XDG_CONFIG_HOME="$PWD/config" \
  XDG_DATA_HOME="$TMPDIR/nvim-data" \
  XDG_STATE_HOME="$TMPDIR/nvim-state" \
  XDG_CACHE_HOME="$TMPDIR/nvim-cache" \
  nvim --headless -n --cmd 'set noloadplugins' --cmd 'set shada=' +qa
```

`./install`, `./update`, and `brew bundle install` are user workflow commands;
run them only when explicitly requested.

## Architecture

### Symlink Layout (`install-conf/dotbot.conf.yaml`)

Dotbot reads this YAML and creates symlinks. To add a new dotfile:
1. Place the file under `config/<tool>/`
2. Add a `link:` entry in `dotbot.conf.yaml` mapping `~/.target` → `config/<tool>/file`

Platform-conditional links use `if:` clauses:
```yaml
- link:
    ~/bin:
        path: bin/osx
        if: '[[ "$OSTYPE" == darwin* ]]'
```

### Directory Map

| `config/` subdir | Symlinked to | Purpose |
|-----------------|--------------|---------|
| `zsh/` | `~/.zshenv`, `~/.zshrc`, etc. | Zsh + prezto config |
| `fish/` | — (not linked by dotbot) | Fish shell config — experimental mirror, not in active use |
| `starship/` | `~/.config/starship.toml` | Starship prompt theme |
| `vim/` | `~/.vim` | Vim config |
| `nvim/` | `~/.config/nvim` | Neovim config (standalone `init.lua`) |
| `git/` | `~/.config/git/` | Git config, ignore, themes |
| `jj/` | `~/.config/jj/` | Jujutsu config |
| `ssh/` | `~/.ssh/config`, `~/.ssh/authorized_keys` | SSH config |
| `mise/` | `~/.config/mise/` | mise tool version manager |
| `tmux/` | `~/.tmux.conf` | Tmux config |
| `agent/` | `~/.claude/*`, `~/.codex/*`, `~/.gemini/*`, `~/.agents/skills` | Shared agent instructions, settings adapters, hooks, and skills for Claude, Codex, Gemini CLI, and Antigravity |

`config/agent/` is the source of truth for shared agent guidance and skills; the
tool-specific home dirs are only adapters. Keep custom skills in
`config/agent/skills/`; do not put them under `~/.codex/skills`,
`~/.gemini/skills`, or tool-owned cache directories.
`config/agent/codex/config.toml` is a template, not a symlink target; sync it
with `mise run sync:codex` (details in
[docs/agent-config.md](docs/agent-config.md)). See
[docs/agent-config.md](docs/agent-config.md) for adapter layout and rationale.
Use the `agent-config` skill when changing cross-agent layout, instruction
files, or agent symlink mappings.
Before changing the *content* of `config/agent/global.md`, `config/agent/rules/`,
`config/agent/skills/agent-delegate/`, `docs/agent-maintenance.md`, or
`docs/agent-letter.md`, read
[docs/agent-maintenance.md](docs/agent-maintenance.md) — it defines ownership,
what may change without asking, and size budgets.

### Homebrew

Four Brewfiles for different contexts:

| File | Use |
|------|-----|
| `Brewfile.home` | Personal macOS setup |
| `Brewfile.work` | Work machine |
| `Brewfile.min` | Minimal/server setup |
| `Brewfile.ctf` | CTF / security tools / Full setup |

### Submodules

| `modules/` | Purpose |
|-----------|---------|
| `dotbot` | Install manager |
| `prezto` | Zsh framework |

# Agent Guidelines for dotfiles repository

## Commit messages

Use `<component>: <title>` for dotfiles changes; prefer real component names such as `zsh`, `vim`, `jj`, `agent`, `mise`, or `ssh`. Add a summary body only when it adds context; the commit-message hook shows examples when the format is wrong.
