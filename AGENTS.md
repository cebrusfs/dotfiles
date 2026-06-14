# Agent Instructions

This file provides guidance to Claude Code and Codex when working with code in this repository. `CLAUDE.md` delegates here so the repository instructions stay in one format.

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
| `agent/` | `~/.claude/*`, `~/.codex/*`, `~/.agents/skills` | Shared agent instructions plus Claude/Codex adapters; `~/.agents/skills` is the user Agent Skills path for Codex and Gemini CLI |

`config/agent/skills/` is the only skill source of truth. Link it to
`~/.claude/skills` for Claude and `~/.agents/skills` for Codex/Gemini-compatible
user skills. Do not put custom skills under `~/.codex/skills`; Codex uses that
directory for its own state and bundled system skills.

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

# Agent Guidelines for dotfiles repository

## Commit Message Formatting
*   **Prefixes:** Do NOT use conventional commit prefixes like `feat:` or `chore:`.
*   **Component-Based:** ALWAYS use the component or module name as the prefix. For example, use `neovim: ...`, `zsh: ...`, `ssh: ...`, `mise: ...`, `npmrc: ...`.
*   **Format:** `<component>: <title>`, with an optional summary body only when it adds context.
