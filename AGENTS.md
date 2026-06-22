# Agent Instructions

## Overview

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot). Files in `config/` are symlinked into `~` by dotbot; `install-conf/dotbot.conf.yaml` is the single source of truth for all symlink mappings.

VCS use `jj` in colocated mode (Use /jj skill when needed)

## Key Commands

```bash
# Run the same lint + format checks CI runs (do this before committing)
mise run check

# Re-run dotbot after editing symlink mappings
bin/dotbot -d . -c install-conf/dotbot.conf.yaml
```

Before committing any change, run `mise run check` and ensure it passes — CI
(`.github/workflows/lint.yaml`) runs the identical task, so a skipped check
becomes a red build.

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
| `fish/` | `~/.config/fish/config.fish`, `~/.config/fish/functions`, etc. | Fish shell config |
| `starship/` | `~/.config/starship.toml` | Starship prompt theme |
| `vim/` | `~/.vim`, `~/.config/nvim` | Vim + Neovim (shared config) |
| `git/` | `~/.config/git/` | Git config, ignore, themes |
| `jj/` | `~/.config/jj/` | Jujutsu config |
| `ssh/` | `~/.ssh/config`, `~/.ssh/authorized_keys` | SSH config |
| `mise/` | `~/.config/mise/` | mise tool version manager |
| `tmux/` | `~/.tmux.conf` | Tmux config |
| `agent/` | `~/.claude/*`, `~/.codex/*`, `~/.agents/skills` | Shared agent instructions plus Claude/Codex adapters; `~/.agents/skills` is the user Agent Skills path for Codex and Gemini CLI |

`config/agent/` is the source of truth for shared agent guidance and skills; the
tool-specific home dirs are only adapters. `config/agent/skills/` is the only
skill source of truth — do not put custom skills under `~/.codex/skills` (Codex
owns that dir). `config/agent/codex/config.toml` is a template, not a symlink
target; sync it with `config/agent/codex/sync-config.py --apply`. Full details in
[docs/agent-config.md](docs/agent-config.md).

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
