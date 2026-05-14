# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot). Files in `config/` are symlinked into `~` by dotbot; `install-conf/dotbot.conf.yaml` is the single source of truth for all symlink mappings.

Version control uses **jj (Jujutsu)** in colocated mode. See `config/agent/rules/jj.md` for jj baseline rules.

## Key Commands

```bash
# Fresh install
./install

# Pull updates + refresh submodules + update vim plugins
./update

# Re-run dotbot only (re-create symlinks, no package installs)
./install-conf/dotbot.conf.yaml   # not directly; run via:
bin/dotbot -d . -c install-conf/dotbot.conf.yaml

# macOS: install Homebrew packages
brew bundle install -v --no-lock --file="homebrew/Brewfile.home"
```

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
| `fish/` | (manual) | Fish shell config |
| `vim/` | `~/.vim`, `~/.config/nvim` | Vim + Neovim (shared config) |
| `git/` | `~/.config/git/` | Git config, ignore, themes |
| `jj/` | `~/.config/jj/` | Jujutsu config |
| `ssh/` | `~/.ssh/config`, `~/.ssh/authorized_keys` | SSH config |
| `mise/` | `~/.config/mise/` | mise tool version manager |
| `tmux/` | `~/.tmux.conf` | Tmux config |
| `agent/` | (not symlinked) | Personal Claude Code rules + skills |

### Homebrew

Four Brewfiles for different contexts:

| File | Use |
|------|-----|
| `Brewfile.home` | Personal macOS setup |
| `Brewfile.work` | Work machine |
| `Brewfile.min` | Minimal/server setup |
| `Brewfile.ctf` | CTF / security tools |

### Submodules

| `modules/` | Purpose |
|-----------|---------|
| `dotbot` | Install manager |
| `prezto` | Zsh framework |

